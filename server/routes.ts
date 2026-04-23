
import type { Express } from "express";
import type { Server } from "http";
import { storage } from "./storage";
import { api } from "@shared/routes";
import { z } from "zod";
import { PAYMENT_MONTHS, type InsertOilSale, type InsertHelmetSale, type InsertSaddleSale } from "@shared/schema";
import { setupAuth } from "./auth";
import { importCSVFromBuffer } from "./csv-import";
import { generateAllBackups, listBackups, getBackupFilePath } from "./backup";
import { readFileSync } from "fs";
import { db } from "./db";
import { sql } from "drizzle-orm";

export async function registerRoutes(
  httpServer: Server,
  app: Express
): Promise<Server> {
  setupAuth(app);

  // DB health check — no auth required
  app.get("/api/health", async (_req, res) => {
    try {
      await db.execute(sql`SELECT 1`);
      res.json({ status: "ok" });
    } catch (e: any) {
      res.status(500).json({ status: "error", message: e.message });
    }
  });

  // Middleware to protect routes
  const isAuthenticated = (req: any, res: any, next: any) => {
    if (req.isAuthenticated()) return next();
    res.status(401).json({ message: "Non autorisé" });
  };

  // Manager-only middleware: applies after isAuthenticated.
  const isManager = (req: any, res: any, next: any) => {
    if (!req.isAuthenticated()) return res.status(401).json({ message: "Non autorisé" });
    if (req.user?.role !== "manager") {
      return res.status(403).json({ message: "Action réservée au gérant" });
    }
    next();
  };

  app.get(api.sales.list.path, isAuthenticated, async (req, res) => {
    const sales = await storage.getSales();
    res.json(sales);
  });

  app.get("/api/sales/:id", isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    
    const sale = await storage.getSale(id);
    if (!sale) return res.status(404).json({ message: "Sale not found" });
    res.json(sale);
  });

  app.get("/api/notifications", isAuthenticated, async (req, res) => {
    const notifications = await storage.getNotifications((req.user as any).id);
    res.json(notifications);
  });

  app.post("/api/notifications/mark-read", isAuthenticated, async (req, res) => {
    await storage.markNotificationsAsRead((req.user as any).id);
    res.json({ success: true });
  });

  app.delete("/api/notifications", isAuthenticated, async (req, res) => {
    await storage.clearNotifications((req.user as any).id);
    res.status(204).send();
  });

  app.post(api.sales.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.sales.create.input.parse(req.body);
      const sale = await storage.createSale(input);
      
      // Log notification
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "VENTE MOTO",
        target: `Facture ${sale.invoiceNumber}`,
        details: `Client: ${sale.clientName}`
      });

      res.status(201).json(sale);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  app.put(api.sales.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });

    try {
      const oldSale = await storage.getSale(id);
      const input = api.sales.update.input.parse(req.body);
      const sale = await storage.updateSale(id, input);

      // Detect if a payment was marked as paid
      let paymentAction = "MODIFICATION";
      let paymentDetails = `Client: ${sale.clientName}`;
      if (oldSale && input.payments) {
        const oldPayments = (oldSale.payments as any) || {};
        const newPayments = (input.payments as any) || {};
        const newlyPaid = Object.entries(newPayments)
          .filter(([month, val]: [string, any]) => val?.isPaid && !oldPayments[month]?.isPaid)
          .map(([month]) => month);
        if (newlyPaid.length > 0) {
          paymentAction = "PAIEMENT";
          paymentDetails = `Client: ${sale.clientName} — ${newlyPaid.join(", ")}`;
        }
      }

      await storage.createNotification({
        userId: (req.user as any).id,
        action: paymentAction,
        target: `Facture ${sale.invoiceNumber}`,
        details: paymentDetails
      });

      res.json(sale);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      // Handle generic errors (like not found from storage)
      res.status(500).json({ message: "Failed to update sale" });
    }
  });

  app.delete(api.sales.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    
    const sale = await storage.getSale(id);
    if (sale) {
      await storage.deleteSale(id);
      
      // Log notification
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "SUPPRESSION",
        target: `Facture ${sale.invoiceNumber}`,
        details: `Client: ${sale.clientName} — Vente moto supprimée`
      });
    }

    res.status(204).send();
  });

  app.post(api.sales.bulkCreate.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.sales.bulkCreate.input.parse(req.body);
      const sales = await storage.bulkCreateSales(input);
      res.status(201).json(sales);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  // CSV Import endpoint
  app.post("/api/sales/import-csv", isAuthenticated, async (req, res) => {
    try {
      if (!req.body || !req.body.csv) {
        return res.status(400).json({ message: "CSV data is required" });
      }

      // Handle base64 encoded CSV or direct text
      let csvBuffer: Buffer;
      if (typeof req.body.csv === "string") {
        // Try to decode as base64 first, if that fails, use as plain text
        try {
          csvBuffer = Buffer.from(req.body.csv, "base64");
        } catch {
          csvBuffer = Buffer.from(req.body.csv, "utf-8");
        }
      } else {
        return res.status(400).json({ message: "Invalid CSV format" });
      }

      const result = await importCSVFromBuffer(csvBuffer, {
        skipDuplicates: req.body.skipDuplicates !== false,
      });

      // Log notification
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "IMPORT CSV",
        target: "Import de données",
        details: `${result.added} nouveaux enregistrements ajoutés, ${result.skipped} doublons ignorés`,
      });

      res.status(200).json(result);
    } catch (err: any) {
      console.error("CSV import error:", err);
      res.status(400).json({
        message: err.message || "Failed to import CSV",
      });
    }
  });

  // -----------------------------
  // Oil module (stock + sales)
  // -----------------------------

  app.get(api.oil.stock.get.path, isAuthenticated, async (_req, res) => {
    const stock = await storage.getOilStock();
    res.json(stock);
  });

  app.get(api.oil.sales.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getOilSales();
    res.json(rows);
  });

  app.post(api.oil.sales.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.oil.sales.create.input.parse(req.body);
      const row = await storage.createOilSale(input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "VENTE HUILE",
        target: `Vente huile du ${row.date}`,
        details: `Client: ${row.client || "—"} — ${row.prix} TND`
      });
      res.status(201).json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      }
      if (err?.status === 400) return res.status(400).json({ message: err.message || "Stock insuffisant" });
      throw err;
    }
  });

  app.put(api.oil.sales.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    try {
      const input = api.oil.sales.update.input.parse(req.body);
      const row = await storage.updateOilSale(id, input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "MODIFICATION",
        target: `Vente huile du ${row.date}`,
        details: `Client: ${row.client || "—"} — modifiée`
      });
      res.json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) return res.status(400).json({ message: err.errors[0].message });
      if (err?.status === 404) return res.status(404).json({ message: "Not found" });
      throw err;
    }
  });

  app.delete(api.oil.sales.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteOilSale(id);
    await storage.createNotification({
      userId: (req.user as any).id,
      action: "SUPPRESSION",
      target: `Vente huile #${id}`,
      details: `Vente huile supprimée`
    });
    res.status(204).send();
  });

  app.get(api.oil.purchases.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getOilPurchases();
    res.json(rows);
  });

  app.post(api.oil.purchases.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.oil.purchases.create.input.parse(req.body);
      const row = await storage.createOilPurchase(input);
      res.status(201).json(row);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      }
      throw err;
    }
  });

  app.delete(api.oil.purchases.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteOilPurchase(id);
    res.status(204).send();
  });

  // -----------------------------
  // Helmets module (stock + sales)
  // -----------------------------

  app.get(api.helmets.stock.get.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getHelmetStock();
    res.json(rows);
  });

  app.get(api.helmets.sales.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getHelmetSales();
    res.json(rows);
  });

  app.post(api.helmets.sales.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.helmets.sales.create.input.parse(req.body);
      const row = await storage.createHelmetSale(input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "VENTE CASQUE",
        target: `Casque — ${row.designation}`,
        details: `Client: ${row.nomPrenom || "—"} — ${row.montant} TND`
      });
      res.status(201).json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      }
      if (err?.status === 400) return res.status(400).json({ message: err.message || "Stock insuffisant" });
      throw err;
    }
  });

  app.put(api.helmets.sales.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    try {
      const input = api.helmets.sales.update.input.parse(req.body);
      const row = await storage.updateHelmetSale(id, input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "MODIFICATION",
        target: `Casque — ${row.designation}`,
        details: `Client: ${row.nomPrenom || "—"} — modifié`
      });
      res.json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) return res.status(400).json({ message: err.errors[0].message });
      if (err?.status === 404) return res.status(404).json({ message: "Not found" });
      throw err;
    }
  });

  app.delete(api.helmets.sales.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteHelmetSale(id);
    await storage.createNotification({
      userId: (req.user as any).id,
      action: "SUPPRESSION",
      target: `Vente casque #${id}`,
      details: `Vente casque supprimée`
    });
    res.status(204).send();
  });

  app.get(api.helmets.purchases.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getHelmetPurchases();
    res.json(rows);
  });

  app.post(api.helmets.purchases.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.helmets.purchases.create.input.parse(req.body);
      const row = await storage.createHelmetPurchase(input);
      res.status(201).json(row);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      }
      throw err;
    }
  });

  app.delete(api.helmets.purchases.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteHelmetPurchase(id);
    res.status(204).send();
  });

  // -----------------------------
  // Saddles (Cache Selle)
  // -----------------------------

  app.get(api.saddles.stock.get.path, isAuthenticated, async (_req, res) => {
    const stock = await storage.getSaddleStock();
    res.json(stock);
  });

  app.get(api.saddles.sales.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getSaddleSales();
    res.json(rows);
  });

  app.post(api.saddles.sales.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.saddles.sales.create.input.parse(req.body);
      const row = await storage.createSaddleSale(input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "VENTE SELLE",
        target: `Vente selle du ${row.date}`,
        details: `Client: ${row.client || "—"} — ${row.prix} TND`
      });
      res.status(201).json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      if (err?.status === 400) return res.status(400).json({ message: err.message || "Stock insuffisant" });
      throw err;
    }
  });

  app.put(api.saddles.sales.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    try {
      const input = api.saddles.sales.update.input.parse(req.body);
      const row = await storage.updateSaddleSale(id, input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "MODIFICATION",
        target: `Vente selle du ${row.date}`,
        details: `Client: ${row.client || "—"} — modifiée`
      });
      res.json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) return res.status(400).json({ message: err.errors[0].message });
      if (err?.status === 404) return res.status(404).json({ message: "Not found" });
      throw err;
    }
  });

  app.delete(api.saddles.sales.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteSaddleSale(id);
    await storage.createNotification({
      userId: (req.user as any).id,
      action: "SUPPRESSION",
      target: `Vente selle #${id}`,
      details: `Vente selle supprimée`
    });
    res.status(204).send();
  });

  app.get(api.saddles.purchases.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getSaddlePurchases();
    res.json(rows);
  });

  app.post(api.saddles.purchases.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.saddles.purchases.create.input.parse(req.body);
      const row = await storage.createSaddlePurchase(input);
      res.status(201).json(row);
    } catch (err) {
      if (err instanceof z.ZodError) return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      throw err;
    }
  });

  app.delete(api.saddles.purchases.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteSaddlePurchase(id);
    res.status(204).send();
  });

  // -----------------------------
  // Deferred / Divers (stock + sales + purchases)
  // -----------------------------

  app.get(api.deferred.stock.get.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getDiversStock();
    res.json(rows);
  });

  app.get(api.deferred.sales.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getDeferredSales();
    res.json(rows);
  });

  app.post(api.deferred.sales.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.deferred.sales.create.input.parse(req.body);
      const row = await storage.createDeferredSale(input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "VENTE DIVERS",
        target: `${row.designation || "Article divers"}`,
        details: `Client: ${row.nomPrenom || "—"} — ${row.montant} TND`
      });
      res.status(201).json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      }
      if (err?.status === 400) return res.status(400).json({ message: err.message || "Stock insuffisant" });
      throw err;
    }
  });

  app.put(api.deferred.sales.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    try {
      const input = api.deferred.sales.update.input.parse(req.body);
      const row = await storage.updateDeferredSale(id, input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "MODIFICATION",
        target: `${row.designation || "Article divers"}`,
        details: `Client: ${row.nomPrenom || "—"} — modifié`
      });
      res.json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) return res.status(400).json({ message: err.errors[0].message });
      if (err?.status === 404) return res.status(404).json({ message: "Not found" });
      throw err;
    }
  });

  app.delete(api.deferred.sales.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteDeferredSale(id);
    await storage.createNotification({
      userId: (req.user as any).id,
      action: "SUPPRESSION",
      target: `Vente divers #${id}`,
      details: `Vente divers supprimée`
    });
    res.status(204).send();
  });

  app.get(api.deferred.purchases.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getDiversPurchases();
    res.json(rows);
  });

  app.post(api.deferred.purchases.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.deferred.purchases.create.input.parse(req.body);
      const row = await storage.createDiversPurchase(input);
      res.status(201).json(row);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      }
      throw err;
    }
  });

  app.delete(api.deferred.purchases.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteDiversPurchase(id);
    res.status(204).send();
  });

  // -----------------------------
  // Clients
  // -----------------------------

  app.get(api.clients.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getClients();
    res.json(rows);
  });

  app.post(api.clients.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.clients.create.input.parse(req.body);
      const row = await storage.createClient(input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "NOUVEAU CLIENT",
        target: row.nomPrenom,
        details: `Tél: ${row.numeroTelephone || "—"} — #${row.uniqueNumber || "—"}`
      });
      res.status(201).json(row);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({ message: err.errors[0].message, field: err.errors[0].path.join(".") });
      }
      throw err;
    }
  });

  app.put(api.clients.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    try {
      const input = api.clients.update.input.parse(req.body);
      const row = await storage.updateClient(id, input);
      await storage.createNotification({
        userId: (req.user as any).id,
        action: "MODIFICATION CLIENT",
        target: row.nomPrenom,
        details: `Client #${row.uniqueNumber || row.id} modifié`
      });
      res.json(row);
    } catch (err: any) {
      if (err instanceof z.ZodError) return res.status(400).json({ message: err.errors[0].message });
      if (err?.status === 404) return res.status(404).json({ message: "Not found" });
      throw err;
    }
  });

  app.delete(api.clients.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteClient(id);
    await storage.createNotification({
      userId: (req.user as any).id,
      action: "SUPPRESSION CLIENT",
      target: `Client #${id}`,
      details: `Client supprimé`
    });
    res.status(204).send();
  });

  // -----------------------------
  // Bons de Livraison & Factures (legacy v1 endpoints — kept as no-op stubs
  // for frontend backward-compat; data lives entirely in livraisons / factures
  // (v2) tables now. The v1 delivery_note_lines table has been dropped.)
  // -----------------------------

  app.get("/api/bons-livraison", isAuthenticated, async (_req, res) => res.json([]));
  app.get("/api/bons-livraison/next-number", isAuthenticated, async (_req, res) => {
    try { res.json({ bonNumber: await storage.nextDeliveryNoteNumber() }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  app.get("/api/factures", isAuthenticated, async (_req, res) => res.json([]));
  app.get("/api/factures/next-number", isAuthenticated, async (_req, res) => {
    try { res.json({ factureNumber: await storage.nextFactureNumber() }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  // -----------------------------
  // Factures V2 (header + lines + draft/validated workflow)
  // -----------------------------

  app.get("/api/factures-v2", isAuthenticated, async (_req, res) => {
    try { res.json(await storage.getFacturesV2()); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  app.get("/api/factures-v2/:id", isAuthenticated, async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const f = await storage.getFactureV2WithLines(id);
      if (!f) return res.status(404).json({ message: "Introuvable" });
      res.json(f);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  app.post("/api/factures-v2", isAuthenticated, async (req, res) => {
    try {
      const { factureNumber, bonRef, date, commercial, clientId, clientName, idClient, matriculeFiscal, adresseClient, phoneClient } = req.body;
      if (!factureNumber) return res.status(400).json({ message: "Numéro de facture manquant" });
      const fac = await storage.createFactureV2({
        factureNumber, bonRef: bonRef ?? "", date, commercial: commercial ?? "",
        clientId: clientId ?? null, clientName: clientName ?? "", idClient: idClient ?? "",
        matriculeFiscal: matriculeFiscal ?? "", adresseClient: adresseClient ?? "", phoneClient: phoneClient ?? "",
        status: "draft",
      } as any);
      res.status(201).json(fac);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  app.post("/api/factures-v2/:id/lines", isAuthenticated, async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const fac = await storage.getFactureV2WithLines(id);
      if (!fac) return res.status(404).json({ message: "Facture introuvable" });
      if (fac.status === "validated") return res.status(400).json({ message: "Facture validée, modification impossible" });
      const line = await storage.addFactureV2Line(id, {
        factureNumber: fac.factureNumber, bonRef: fac.bonRef, date: fac.date, commercial: fac.commercial,
        client: fac.clientName, idClient: fac.idClient, matriculeFiscal: fac.matriculeFiscal,
        adresseClient: fac.adresseClient, phoneClient: fac.phoneClient,
        ref: req.body.ref ?? "", designation: req.body.designation ?? "",
        qte: req.body.qte ?? 1, prix: req.body.prix ?? 0, tva: req.body.tva ?? "19%",
        remise: req.body.remise ?? 0, prixTtc: req.body.prixTtc ?? 0,
        montantHt: req.body.montantHt ?? 0, montantTva: req.body.montantTva ?? 0, montantTtc: req.body.montantTtc ?? 0,
      } as any);
      res.status(201).json(line);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  app.put("/api/factures-v2/:id", isAuthenticated, async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const fac = await storage.getFactureV2WithLines(id);
      if (!fac) return res.status(404).json({ message: "Introuvable" });
      if (fac.status === "validated" && (req.user as any)?.role !== "manager") {
        return res.status(403).json({ message: "Facture validée — édition réservée au gérant" });
      }
      const { lines, header } = req.body;
      if (header) await storage.updateFactureV2(id, header);
      if (Array.isArray(lines)) await storage.replaceFactureV2Lines(id, lines);
      res.json({ success: true });
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  app.delete("/api/factures-v2/:id", isAuthenticated, async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const fac = await storage.getFactureV2WithLines(id);
      if (!fac) return res.status(204).send();
      if (fac.status === "validated" && (req.user as any)?.role !== "manager") {
        return res.status(403).json({ message: "Facture validée — suppression réservée au gérant" });
      }
      await storage.deleteFactureV2(id);
      res.status(204).send();
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  app.post("/api/factures-v2/:id/validate", isAuthenticated, async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const fac = await storage.validateFactureV2(id);
      res.json(fac);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  // -----------------------------
  // Reservations
  // -----------------------------

  app.get(api.reservations.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getReservations();
    res.json(rows);
  });

  app.post(api.reservations.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.reservations.create.input.parse(req.body);
      const row = await storage.createReservation(input);
      res.status(201).json(row);
    } catch (err: any) {
      res.status(400).json({ message: err.message });
    }
  });

  app.put(api.reservations.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    try {
      const input = api.reservations.update.input.parse(req.body);
      const row = await storage.updateReservation(id, input);
      res.json(row);
    } catch (err: any) {
      res.status(err.status || 400).json({ message: err.message });
    }
  });

  app.delete(api.reservations.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteReservation(id);
    res.status(204).send();
  });

  // -----------------------------
  // Orders (Commandes)
  // -----------------------------

  app.get(api.orders.list.path, isAuthenticated, async (_req, res) => {
    const rows = await storage.getOrders();
    res.json(rows);
  });

  app.post(api.orders.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.orders.create.input.parse(req.body);
      const row = await storage.createOrder(input);
      res.status(201).json(row);
    } catch (err: any) {
      res.status(400).json({ message: err.message });
    }
  });

  app.put(api.orders.update.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    try {
      const input = api.orders.update.input.parse(req.body);
      const row = await storage.updateOrder(id, input);
      res.json(row);
    } catch (err: any) {
      res.status(err.status || 400).json({ message: err.message });
    }
  });

  app.delete(api.orders.delete.path, isAuthenticated, async (req, res) => {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "Invalid ID" });
    await storage.deleteOrder(id);
    res.status(204).send();
  });

  // Backup routes — accessible to all authenticated users
  app.get("/api/backups", isAuthenticated, (_req, res) => {
    try {
      res.json(listBackups());
    } catch (err: any) {
      res.status(500).json({ message: err.message });
    }
  });

  app.post("/api/backups/trigger", isAuthenticated, async (req, res) => {
    try {
      await generateAllBackups((msg, src) => console.log(`[${src ?? "backup"}] ${msg}`));
      // Create a notification for this backup action
      const userId = (req.user as any).id;
      await storage.createNotification({
        userId,
        action: "SAUVEGARDE",
        target: "Sauvegarde manuelle",
        details: "3 fichiers générés : Complète + Clients + Bons de Livraison",
      });
      res.json({ success: true, backups: listBackups() });
    } catch (err: any) {
      res.status(500).json({ message: err.message });
    }
  });

  app.get("/api/backups/download/:name", isAuthenticated, (req, res) => {
    try {
      const filePath = getBackupFilePath(req.params.name);
      if (!filePath) return res.status(404).json({ message: "Fichier introuvable" });
      const content = readFileSync(filePath, "utf8");
      res.setHeader("Content-Type", "application/sql");
      res.setHeader("Content-Disposition", `attachment; filename="${req.params.name}"`);
      res.send(content);
    } catch {
      res.status(404).json({ message: "Fichier introuvable" });
    }
  });

  // -----------------
  // Tarif (Product Prices)
  // -----------------

  app.get("/api/product-prices", isAuthenticated, async (req, res) => {
    try {
      const search = typeof req.query.search === "string" ? req.query.search : undefined;
      const rows = await storage.getProductPrices(search);
      res.json(rows);
    } catch (err: any) {
      res.status(500).json({ message: err.message });
    }
  });

  app.post("/api/product-prices/import", isAuthenticated, async (req, res) => {
    try {
      const { rows, replace } = req.body as { rows: { number: number; designation: string; prixVenteTTC: number }[]; replace?: boolean };
      if (!Array.isArray(rows) || rows.length === 0) return res.status(400).json({ message: "Aucune donnée" });
      if (replace) await storage.deleteAllProductPrices();
      await storage.bulkUpsertProductPrices(rows);
      res.json({ imported: rows.length });
    } catch (err: any) {
      res.status(500).json({ message: err.message });
    }
  });

  app.delete("/api/product-prices", isAuthenticated, async (_req, res) => {
    try {
      await storage.deleteAllProductPrices();
      res.json({ success: true });
    } catch (err: any) {
      res.status(500).json({ message: err.message });
    }
  });

  // ========================
  // STOCK / MOTO MANAGEMENT
  // ========================

  // Product Families
  app.get("/api/product-families", isAuthenticated, async (_req, res) => {
    try { res.json(await storage.getProductFamilies()); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.post("/api/product-families", isAuthenticated, async (req, res) => {
    try { res.json(await storage.createProductFamily(req.body)); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.patch("/api/product-families/:id", isAuthenticated, async (req, res) => {
    try { res.json(await storage.updateProductFamily(Number(req.params.id), req.body)); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.delete("/api/product-families/:id", isAuthenticated, async (req, res) => {
    try { await storage.deleteProductFamily(Number(req.params.id)); res.json({ success: true }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  // Products
  app.get("/api/stock/products", isAuthenticated, async (req, res) => {
    try {
      const familyId = req.query.familyId ? Number(req.query.familyId) : undefined;
      const search = req.query.search as string | undefined;
      res.json(await storage.getProducts(familyId, search));
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.post("/api/stock/products", isAuthenticated, async (req, res) => {
    try { res.json(await storage.createProduct(req.body)); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.patch("/api/stock/products/:id", isAuthenticated, async (req, res) => {
    try { res.json(await storage.updateProduct(Number(req.params.id), req.body)); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.delete("/api/stock/products/:id", isAuthenticated, async (req, res) => {
    try { await storage.deleteProduct(Number(req.params.id)); res.json({ success: true }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  // Product Serials
  app.get("/api/stock/serials", isAuthenticated, async (req, res) => {
    try {
      const productId = Number(req.query.productId);
      const available = req.query.available === "true";
      if (!productId) return res.status(400).json({ message: "productId requis" });
      const rows = available ? await storage.getAvailableSerials(productId) : await storage.getProductSerials(productId);
      res.json(rows);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.post("/api/stock/serials/bulk", isAuthenticated, async (req, res) => {
    try { res.json(await storage.bulkCreateProductSerials(req.body)); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  // Receptions
  app.get("/api/receptions/next-number", isAuthenticated, async (_req, res) => {
    try { res.json({ bonNumber: await storage.nextReceptionNumber() }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.get("/api/receptions", isAuthenticated, async (_req, res) => {
    try { res.json(await storage.getReceptions()); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.get("/api/receptions/:id", isAuthenticated, async (req, res) => {
    try {
      const r = await storage.getReception(Number(req.params.id));
      if (!r) return res.status(404).json({ message: "Non trouvé" });
      res.json(r);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.post("/api/receptions", isAuthenticated, async (req, res) => {
    try {
      const { reception, lines, serialsPerLine } = req.body;
      const r = await storage.createReception(reception, lines, serialsPerLine);
      res.json(r);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.patch("/api/receptions/:id", isAuthenticated, async (req, res) => {
    try {
      const r = await storage.updateReception(Number(req.params.id), req.body);
      res.json(r);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.delete("/api/receptions/:id", isAuthenticated, async (req, res) => {
    try {
      await storage.deleteReception(Number(req.params.id));
      res.json({ ok: true });
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  // Livraisons (new BL system)
  app.get("/api/livraisons/next-number", isAuthenticated, async (_req, res) => {
    try { res.json({ bonNumber: await storage.nextLivraisonNumber() }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.get("/api/livraisons", isAuthenticated, async (_req, res) => {
    try { res.json(await storage.getLivraisons()); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.get("/api/livraisons/:id", isAuthenticated, async (req, res) => {
    try {
      const r = await storage.getLivraison(Number(req.params.id));
      if (!r) return res.status(404).json({ message: "Non trouvé" });
      res.json(r);
    } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.post("/api/livraisons", isAuthenticated, async (req, res) => {
    try { res.json(await storage.createLivraison(req.body)); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.patch("/api/livraisons/:id", isAuthenticated, async (req, res) => {
    try { res.json(await storage.updateLivraison(Number(req.params.id), req.body)); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.delete("/api/livraisons/:id", isAuthenticated, async (req, res) => {
    try { await storage.deleteLivraison(Number(req.params.id)); res.json({ success: true }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.post("/api/livraisons/:id/lines", isAuthenticated, async (req, res) => {
    try { res.json(await storage.addLivraisonLine({ ...req.body, livraisonId: Number(req.params.id) })); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.delete("/api/livraisons/lines/:lineId", isAuthenticated, async (req, res) => {
    try { await storage.removeLivraisonLine(Number(req.params.lineId)); res.json({ success: true }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });
  app.post("/api/livraisons/:id/validate", isAuthenticated, async (req, res) => {
    try { await storage.validateLivraison(Number(req.params.id)); res.json({ success: true }); } catch (e: any) { res.status(500).json({ message: e.message }); }
  });

  // Seed Data
  await seedDatabase();

  return httpServer;
}

async function seedDatabase() {
  // Seed users if they don't exist
  const karim = await storage.getUserByUsername("Karim");
  if (!karim) {
    console.log("Seeding user: Karim");
    await storage.createUser({
      username: "Karim",
      role: "manager"
    });
  }

  const yassin = await storage.getUserByUsername("Yassin");
  if (!yassin) {
    console.log("Seeding user: Yassin");
    await storage.createUser({
      username: "Yassin",
      role: "staff"
    });
  }

  // Seed sales if none exist
  const existingSales = await storage.getSales();
  if (existingSales.length === 0) {
    console.log("Seeding database with initial sales data...");
    
    const samplePaymentSchedule: Record<string, { amount: number, isPaid: boolean }> = {};
    
    // Simulate some payments
    PAYMENT_MONTHS.forEach((month, index) => {
      // First 3 months paid
      if (index < 3) {
        samplePaymentSchedule[month] = { amount: 500, isPaid: true };
      } else {
        samplePaymentSchedule[month] = { amount: 500, isPaid: false };
      }
    });

    await storage.createSale({
      invoiceNumber: "25/000001",
      date: "16/06/2025",
      designation: "PISTA VCX NOIRE NOIRE",
      clientType: "B2C",
      clientName: "Mr ZIED BOUAFIA",
      chassisNumber: "LCS4BGN60S1E00784",
      registrationNumber: "72925 DN",
      grayCardStatus: "Récupérée",
      totalToPay: 7000,
      advance: 2000,
      payments: samplePaymentSchedule
    });

    await storage.createSale({
      invoiceNumber: "25/000002",
      date: "17/06/2025",
      designation: "GHOST V7 124CC BLEUE JAUNE",
      clientType: "B2C",
      clientName: "Mr MED MAROUEN EL HAJRI",
      chassisNumber: "LEHTCJ015RRM00155",
      registrationNumber: "58968 DN",
      grayCardStatus: "A Déposer",
      totalToPay: 8500,
      advance: 1500,
      payments: {} // No payments set up yet
    });
  }

  // Seed oil sales if empty
  const existingOilSales = await storage.getOilSales();
  if (existingOilSales.length === 0) {
    console.log("Seeding oil module with initial data...");
    const oilSeed: InsertOilSale[] = [
      { date: "2026-02-23", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Kilani" },
      { date: "2025-07-15", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "WAHID" },
      { date: "2025-07-16", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "ANAS", client: "" },
      { date: "2025-07-20", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "WAHID" },
      { date: "2025-07-28", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "ANAS" },
      { date: "2025-07-30", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-07-29", huile10w40: 0, huile20w50: 2, prix: 36, encaissement: "ANAS", client: "HM+KR" },
      { date: "2025-07-31", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "Abdelkader" },
      { date: "2025-08-02", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "ANAS", client: "???" },
      { date: "2025-08-05", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "ANAS", client: "KARIM" },
      { date: "2025-08-13", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "HASSEN" },
      { date: "2025-08-16", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "Ghassen" },
      { date: "2025-08-18", huile10w40: 0, huile20w50: 2, prix: 36, encaissement: "KARIM", client: "" },
      { date: "2025-08-19", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-08-20", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-08-21", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "ANAS", client: "" },
      { date: "2025-08-27", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "ANAS", client: "Jlassi" },
      { date: "2025-09-01", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "ANAS", client: "Bilel" },
      { date: "2025-09-03", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "ANAS", client: "Adem" },
      { date: "2025-09-08", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "??" },
      { date: "2025-09-10", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "WAEL" },
      { date: "2025-09-15", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "WAEL" },
      { date: "2025-09-18", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "IBRAHIM" },
      { date: "2025-09-19", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-09-19", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "ABDERAZEK" },
      { date: "2025-09-23", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "YOSRI" },
      { date: "2025-09-25", huile10w40: 1, huile20w50: 0, prix: 20, encaissement: "KARIM", client: "" },
      { date: "2025-09-30", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2025-10-02", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-10-06", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-10-07", huile10w40: 0, huile20w50: 1, prix: 20, encaissement: "KARIM", client: "" },
      { date: "2025-10-16", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "Beb Hssine" },
      { date: "2025-10-31", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "BASSEM", client: "13" },
      { date: "2025-11-01", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "SADOK" },
      { date: "2025-11-06", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "SKANDER" },
      { date: "2025-11-11", huile10w40: 0, huile20w50: 1, prix: 20, encaissement: "BASSEM", client: "" },
      { date: "2025-11-19", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2025-11-21", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-11-25", huile10w40: 1, huile20w50: 0, prix: 20, encaissement: "KARIM", client: "" },
      { date: "2025-11-29", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-12-08", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-12-09", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "ZIED" },
      { date: "2025-12-11", huile10w40: 0, huile20w50: 1, prix: 19, encaissement: "KARIM", client: "" },
      { date: "2025-12-12", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2025-12-16", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2025-12-18", huile10w40: 1, huile20w50: 0, prix: 20, encaissement: "KARIM", client: "" },
      { date: "2025-12-19", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "" },
      { date: "2025-12-20", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2025-12-20", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2025-12-22", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2025-12-30", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "BASSEM", client: "" },
      { date: "2026-01-02", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "" },
      { date: "2026-01-05", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "" },
      { date: "2026-01-08", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "" },
      { date: "2026-01-10", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "" },
      { date: "2026-01-13", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "" },
      { date: "2026-01-16", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "Adam BEN HSIN" },
      { date: "2026-01-21", huile10w40: 0, huile20w50: 1, prix: 20, encaissement: "KARIM", client: "LARIANI" },
      { date: "2026-01-26", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Ramzi BALOUTI" },
      { date: "2026-01-26", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "" },
      { date: "2026-02-02", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "YASSIN", client: "" },
      { date: "2026-02-02", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Ali" },
      { date: "2026-02-04", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "wael" },
      { date: "2026-02-05", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "Adam BEN HSIN" },
      { date: "2026-02-06", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "KARIM", client: "SABER HR" },
      { date: "2026-02-09", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Sami" },
      { date: "2026-02-09", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Abdeslem" },
      { date: "2026-02-14", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "YASSIN", client: "Adam" },
      { date: "2026-02-14", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "Skander" },
      { date: "2026-02-16", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "YASSIN", client: "Saber Hr" },
      { date: "2026-02-16", huile10w40: 1, huile20w50: 0, prix: 18, encaissement: "YASSIN", client: "Amir kirat" },
      { date: "2026-02-16", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "KARIM", client: "Zied Mlawah" },
      { date: "2026-02-17", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "abdlkader hedfi" },
      { date: "2026-02-17", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "choaaib" },
      { date: "2026-02-18", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Ramzi ballouti" },
      { date: "2026-02-20", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Hazem Aalayet" },
      { date: "2026-02-23", huile10w40: 0, huile20w50: 1, prix: 18, encaissement: "YASSIN", client: "Yacin Allagui" },
    ];
    await storage.seedOilSales(oilSeed);
  }

  // Seed helmet sales if empty
  const existingHelmetSales = await storage.getHelmetSales();
  if (existingHelmetSales.length === 0) {
    console.log("Seeding helmets module with initial data...");
    const helmetSeed: InsertHelmetSale[] = [
      {
        numeroFacture: "25/000081",
        date: "2025-11-17",
        designation: "CASQUE LS2 AIRFLOW MATT-Taille XXL",
        typeClient: "B2B",
        nomPrenom: "STE AKRAM DE COMMERCE ET SERVICES",
        quantite: 1,
        montant: 385,
      },
      {
        numeroFacture: "25/000082",
        date: "2025-11-17",
        designation: "CASQUE LS2 AIRFLOW GLOSS -Taille L",
        typeClient: "B2C",
        nomPrenom: "Skander SHILI",
        quantite: 1,
        montant: 100,
      },
      {
        numeroFacture: "25/000087",
        date: "2025-11-25",
        designation: "CASQUE LS2 AIRFLOW MATT-Taille L",
        typeClient: "B2C",
        nomPrenom: "Zaid BAILI",
        quantite: 1,
        montant: 350,
      },
      {
        numeroFacture: "25/000089",
        date: "2025-12-09",
        designation: "CASQUE LS2 AIRFLOW GLOSS -Taille L",
        typeClient: "B2C",
        nomPrenom: "Mohamed RAYEN MATHLOUTHI",
        quantite: 1,
        montant: 385,
      },
      {
        numeroFacture: "25/000094",
        date: "2025-12-20",
        designation: "CASQUE LS2 AIRFLOW MATT-Taille M",
        typeClient: "B2C",
        nomPrenom: "Moataz BOUAADILA",
        quantite: 1,
        montant: 375,
      },
      {
        numeroFacture: "26/000002",
        date: "2026-01-02",
        designation: "CASQUE MT Taille M MATT",
        typeClient: "B2C",
        nomPrenom: "Skander SHILI",
        quantite: 1,
        montant: 275,
      },
      {
        numeroFacture: "07",
        date: "2026-02-07",
        designation: "CASQUE TNL Gris-Taille XL",
        typeClient: "B2C",
        nomPrenom: "Mohamed Ali NASRALLAH",
        quantite: 1,
        montant: 140,
      },
      {
        numeroFacture: "11",
        date: "2026-02-11",
        designation: "Casque TNL Black Taille L",
        typeClient: "B2B",
        nomPrenom: "Charef Eddin ALAAMRI",
        quantite: 1,
        montant: 148,
      },
      {
        numeroFacture: "14",
        date: "2026-02-14",
        designation: "Casque TNL Noir Taille XL",
        typeClient: "B2B",
        nomPrenom: "Dhia Bouaadila",
        quantite: 1,
        montant: 148,
      },
      {
        numeroFacture: "26/000021",
        date: "2026-02-16",
        designation: "CASQUE TNL Gris-Taille L",
        typeClient: "B2B",
        nomPrenom: "Hazem BEN AALAYET",
        quantite: 1,
        montant: 148,
      },
    ];
    await storage.seedHelmetSales(helmetSeed);
  }

  // Seed product prices if empty
  const existingPrices = await storage.getProductPrices();
  if (existingPrices.length === 0) {
    console.log("Seeding product prices with initial data...");
    await storage.bulkUpsertProductPrices([
      { number: 1, designation: "BAVETTE BOOSTER 2004 TAIWAN", prixVenteTTC: 9.261 },
      { number: 2, designation: "AFFICHEUR DE TEMPERATURE+HORLOGE SC", prixVenteTTC: 9.959 },
      { number: 3, designation: "AFFICHEUR DE VITESSE POWER 110", prixVenteTTC: 3.792 },
      { number: 4, designation: "AILES COLORE GHOST V7", prixVenteTTC: 169.000 },
      { number: 5, designation: "AILES JLM 110 BLEU", prixVenteTTC: 40.665 },
      { number: 6, designation: "AILES JLM 110 GRIS", prixVenteTTC: 40.665 },
      { number: 7, designation: "AILES JLM 110 ORIGINE", prixVenteTTC: 40.665 },
      { number: 8, designation: "ALARME POUR MOTO", prixVenteTTC: 27.783 },
      { number: 9, designation: "AMORTISSEUR GHOST V7", prixVenteTTC: 183.000 },
      { number: 10, designation: "AMORTISSEUR NITRO 320mm", prixVenteTTC: 32.101 },
    ]);
  }

  // Seed saddle sales if empty (need purchases first for stock)
  const existingSaddleSales = await storage.getSaddleSales();
  if (existingSaddleSales.length === 0) {
    console.log("Seeding saddles module with initial data...");
    // Add initial purchase for stock
    await storage.createSaddlePurchase({ date: "2025-08-01", tailleXl: 50, tailleXxl: 50, fournisseur: "Initial", prix: 0 });
    const saddleSeed: InsertSaddleSale[] = [
      { date: "2025-09-01", tailleXl: 1, tailleXxl: 0, prix: 15, encaissement: "ANAS", client: "Khmais" },
      { date: "2025-09-02", tailleXl: 0, tailleXxl: 1, prix: 15, encaissement: "ANAS", client: "Hmaida" },
      { date: "2025-09-10", tailleXl: 1, tailleXxl: 0, prix: 0, encaissement: "KARIM", client: "KASDAOUI" },
      { date: "2025-09-20", tailleXl: 1, tailleXxl: 0, prix: 15, encaissement: "KARIM", client: "" },
      { date: "2025-09-23", tailleXl: 2, tailleXxl: 0, prix: 0, encaissement: "KARIM", client: "" },
      { date: "2025-10-06", tailleXl: 0, tailleXxl: 1, prix: 0, encaissement: "KARIM", client: "" },
      { date: "2025-11-27", tailleXl: 0, tailleXxl: 1, prix: 15, encaissement: "KARIM", client: "" },
      { date: "2025-12-05", tailleXl: 0, tailleXxl: 1, prix: 15, encaissement: "BASSEM", client: "" },
      { date: "2025-12-09", tailleXl: 0, tailleXxl: 1, prix: 15, encaissement: "KARIM", client: "" },
      { date: "2025-12-09", tailleXl: 0, tailleXxl: 1, prix: 15, encaissement: "KARIM", client: "ZIED" },
      { date: "2026-01-14", tailleXl: 1, tailleXxl: 0, prix: 15, encaissement: "YASSIN", client: "" },
      { date: "2026-01-22", tailleXl: 0, tailleXxl: 1, prix: 15, encaissement: "YASSIN", client: "SHILI" },
      { date: "2026-02-02", tailleXl: 1, tailleXxl: 0, prix: 15, encaissement: "YASSIN", client: "ALI" },
    ];
    await storage.seedSaddleSales(saddleSeed);
  }
}
