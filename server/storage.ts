
import { db } from "./db";
import {
  sales,
  users,
  type InsertSale,
  type SaleResponse,
  type User,
  type InsertUser,
  type Notification,
  type InsertNotification,
  userNotifications,
  oilSales,
  oilPurchases,
  type InsertOilSale,
  type InsertOilPurchase,
  type OilSale,
  type OilPurchase,
  helmetSales,
  helmetPurchases,
  type InsertHelmetSale,
  type InsertHelmetPurchase,
  type HelmetSale,
  type HelmetPurchase,
  saddleSales,
  saddlePurchases,
  type InsertSaddleSale,
  type InsertSaddlePurchase,
  type SaddleSale,
  type SaddlePurchase,
  deferredSales,
  type InsertDeferredSale,
  type DeferredSale,
  diversPurchases,
  type InsertDiversPurchase,
  type DiversPurchase,
  clients,
  type InsertClient,
  type Client,
  factureLines,
  type FactureLine,
  type InsertFactureLine,
  factures,
  type Facture,
  type InsertFacture,
  reservations,
  type Reservation,
  type InsertReservation,
  orders,
  type Order,
  type InsertOrder,
  productPrices,
  type ProductPrice,
  type InsertProductPrice,
  productFamilies, type ProductFamily, type InsertProductFamily,
  products, type Product, type InsertProduct,
  productSerials, type ProductSerial, type InsertProductSerial,
  receptions, type Reception, type InsertReception,
  receptionLines, type ReceptionLine, type InsertReceptionLine,
  livraisons, type Livraison, type InsertLivraison,
  livraisonLines, type LivraisonLine, type InsertLivraisonLine,
} from "@shared/schema";
import { eq, desc, and, sql, inArray, or, isNull, asc } from "drizzle-orm";
import { notifications } from "@shared/schema";

export interface IStorage {
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  getSales(): Promise<SaleResponse[]>;
  getSale(id: number): Promise<SaleResponse | undefined>;
  createSale(sale: InsertSale): Promise<SaleResponse>;
  updateSale(id: number, updates: Partial<InsertSale>): Promise<SaleResponse>;
  deleteSale(id: number): Promise<void>;
  bulkCreateSales(salesData: InsertSale[]): Promise<SaleResponse[]>;
  getNotifications(userId: number): Promise<Notification[]>;
  createNotification(notif: InsertNotification): Promise<Notification>;
  markNotificationsAsRead(userId: number): Promise<void>;
  clearNotifications(userId: number): Promise<void>;

  // Oil module
  getOilSales(): Promise<OilSale[]>;
  createOilSale(sale: InsertOilSale): Promise<OilSale>;
  seedOilSales(rows: InsertOilSale[]): Promise<void>;
  updateOilSale(id: number, updates: Partial<InsertOilSale>): Promise<OilSale>;
  deleteOilSale(id: number): Promise<void>;
  getOilPurchases(): Promise<OilPurchase[]>;
  createOilPurchase(p: InsertOilPurchase): Promise<OilPurchase>;
  deleteOilPurchase(id: number): Promise<void>;
  getOilStock(): Promise<{ huile_10w40: number; huile_20w50: number }>;

  // Helmets module
  getHelmetSales(): Promise<HelmetSale[]>;
  createHelmetSale(sale: InsertHelmetSale): Promise<HelmetSale>;
  seedHelmetSales(rows: InsertHelmetSale[]): Promise<void>;
  updateHelmetSale(id: number, updates: Partial<InsertHelmetSale>): Promise<HelmetSale>;
  deleteHelmetSale(id: number): Promise<void>;
  getHelmetPurchases(): Promise<HelmetPurchase[]>;
  createHelmetPurchase(p: InsertHelmetPurchase): Promise<HelmetPurchase>;
  deleteHelmetPurchase(id: number): Promise<void>;
  getHelmetStock(): Promise<Array<{ designation: string; stock: number }>>;

  // Saddles (Cache Selle)
  getSaddleSales(): Promise<SaddleSale[]>;
  createSaddleSale(sale: InsertSaddleSale): Promise<SaddleSale>;
  seedSaddleSales(rows: InsertSaddleSale[]): Promise<void>;
  updateSaddleSale(id: number, updates: Partial<InsertSaddleSale>): Promise<SaddleSale>;
  deleteSaddleSale(id: number): Promise<void>;
  getSaddlePurchases(): Promise<SaddlePurchase[]>;
  createSaddlePurchase(p: InsertSaddlePurchase): Promise<SaddlePurchase>;
  deleteSaddlePurchase(id: number): Promise<void>;
  getSaddleStock(): Promise<{ taille_xl: number; taille_xxl: number }>;

  // Deferred / Divers sales
  getDeferredSales(): Promise<DeferredSale[]>;
  createDeferredSale(sale: InsertDeferredSale): Promise<DeferredSale>;
  updateDeferredSale(id: number, updates: Partial<InsertDeferredSale>): Promise<DeferredSale>;
  deleteDeferredSale(id: number): Promise<void>;
  getDiversPurchases(): Promise<DiversPurchase[]>;
  createDiversPurchase(p: InsertDiversPurchase): Promise<DiversPurchase>;
  deleteDiversPurchase(id: number): Promise<void>;
  getDiversStock(): Promise<Array<{ designation: string; stock: number }>>;

  // Clients
  getClients(): Promise<Client[]>;
  createClient(client: InsertClient): Promise<Client>;
  updateClient(id: number, updates: Partial<InsertClient>): Promise<Client>;
  deleteClient(id: number): Promise<void>;

  // Reservations
  getReservations(): Promise<Reservation[]>;
  createReservation(r: InsertReservation): Promise<Reservation>;
  updateReservation(id: number, updates: Partial<InsertReservation>): Promise<Reservation>;
  deleteReservation(id: number): Promise<void>;

  // Orders (Commandes)
  getOrders(): Promise<Order[]>;
  createOrder(o: InsertOrder): Promise<Order>;
  updateOrder(id: number, updates: Partial<InsertOrder>): Promise<Order>;
  deleteOrder(id: number): Promise<void>;

  // Bons de Livraison (next number across livraisons table)
  nextDeliveryNoteNumber(): Promise<string>;

  // Factures (next number across factures table)
  nextFactureNumber(): Promise<string>;

  // Factures v2 (header + lines workflow)
  getFacturesV2(): Promise<Facture[]>;
  getFactureV2WithLines(id: number): Promise<(Facture & { lines: FactureLine[] }) | undefined>;
  createFactureV2(data: InsertFacture): Promise<Facture>;
  addFactureV2Line(factureId: number, line: InsertFactureLine): Promise<FactureLine>;
  updateFactureV2(id: number, data: Partial<InsertFacture>): Promise<Facture>;
  replaceFactureV2Lines(id: number, lines: InsertFactureLine[]): Promise<void>;
  deleteFactureV2(id: number): Promise<void>;
  validateFactureV2(id: number): Promise<Facture>;

  // Tarif (Product Prices)
  getProductPrices(search?: string): Promise<ProductPrice[]>;
  bulkUpsertProductPrices(rows: InsertProductPrice[]): Promise<void>;
  deleteAllProductPrices(): Promise<void>;
  // Product Families
  getProductFamilies(): Promise<ProductFamily[]>;
  createProductFamily(data: InsertProductFamily): Promise<ProductFamily>;
  updateProductFamily(id: number, data: Partial<InsertProductFamily>): Promise<ProductFamily>;
  deleteProductFamily(id: number): Promise<void>;
  // Products
  getProducts(familyId?: number, search?: string): Promise<(Product & { familyName: string | null; availableQty: number })[]>;
  getProduct(id: number): Promise<Product | undefined>;
  createProduct(data: InsertProduct): Promise<Product>;
  updateProduct(id: number, data: Partial<InsertProduct>): Promise<Product>;
  deleteProduct(id: number): Promise<void>;
  // Product Serials
  getProductSerials(productId: number): Promise<ProductSerial[]>;
  getAvailableSerials(productId: number): Promise<ProductSerial[]>;
  createProductSerial(data: InsertProductSerial): Promise<ProductSerial>;
  updateProductSerialStatus(id: number, status: string, livraisonId?: number): Promise<void>;
  bulkCreateProductSerials(serials: InsertProductSerial[]): Promise<ProductSerial[]>;
  // Receptions
  getReceptions(): Promise<(Reception & { lines: (ReceptionLine & { product: Product | null })[] })[]>;
  getReception(id: number): Promise<(Reception & { lines: (ReceptionLine & { product: Product | null })[] }) | undefined>;
  createReception(data: InsertReception, lines: InsertReceptionLine[], serials: { productId: number; serial: string; purchasePrice: number }[][]): Promise<Reception>;
  updateReception(id: number, data: Partial<InsertReception>): Promise<Reception>;
  deleteReception(id: number): Promise<void>;
  nextReceptionNumber(): Promise<string>;
  // Livraisons
  getLivraisons(): Promise<(Livraison & { lines: LivraisonLine[]; totalHt: number; totalTtc: number })[]>;
  getLivraison(id: number): Promise<(Livraison & { lines: LivraisonLine[] }) | undefined>;
  createLivraison(data: InsertLivraison): Promise<Livraison>;
  updateLivraison(id: number, data: Partial<InsertLivraison>): Promise<Livraison>;
  deleteLivraison(id: number): Promise<void>;
  addLivraisonLine(line: InsertLivraisonLine): Promise<LivraisonLine>;
  removeLivraisonLine(lineId: number): Promise<void>;
  validateLivraison(id: number): Promise<void>;
  nextLivraisonNumber(): Promise<string>;
}

export class DatabaseStorage implements IStorage {
  private async getOilStockWithExecutor(): Promise<{ huile_10w40: number; huile_20w50: number; gear_oil: number; break_oil: number }> {
    const [p] = await db
      .select({
        q10: sql<number>`coalesce(sum(${oilPurchases.huile10w40}), 0)`,
        q20: sql<number>`coalesce(sum(${oilPurchases.huile20w50}), 0)`,
        qGear: sql<number>`coalesce(sum(${oilPurchases.gearOil}), 0)`,
        qBrake: sql<number>`coalesce(sum(${oilPurchases.brakeOil}), 0)`,
      })
      .from(oilPurchases);

    const [s] = await db
      .select({
        q10: sql<number>`coalesce(sum(${oilSales.huile10w40}), 0)`,
        q20: sql<number>`coalesce(sum(${oilSales.huile20w50}), 0)`,
        qGear: sql<number>`coalesce(sum(${oilSales.gearOil}), 0)`,
        qBrake: sql<number>`coalesce(sum(${oilSales.brakeOil}), 0)`,
      })
      .from(oilSales);

    return {
      huile_10w40: Number(p?.q10 ?? 0) - Number(s?.q10 ?? 0),
      huile_20w50: Number(p?.q20 ?? 0) - Number(s?.q20 ?? 0),
      gear_oil: Number(p?.qGear ?? 0) - Number(s?.qGear ?? 0),
      break_oil: Number(p?.qBrake ?? 0) - Number(s?.qBrake ?? 0),
    };
  }

  async getUser(id: number): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.id, id));
    return user;
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    const [user] = await db.select().from(users).where(eq(users.username, username));
    return user;
  }

  async createUser(user: InsertUser): Promise<User> {
    const [newUser] = await db.insert(users).values(user).returning();
    return newUser;
  }

  async getSales(): Promise<SaleResponse[]> {
    return await db
      .select()
      .from(sales)
      .orderBy(
        desc(sql<number>`CAST(substr(${sales.invoiceNumber}, 1, 2) AS INTEGER)`),
        desc(sql<number>`CAST(substr(${sales.invoiceNumber}, strpos(${sales.invoiceNumber}, '/') + 1) AS INTEGER)`),
      );
  }

  async getSale(id: number): Promise<SaleResponse | undefined> {
    const [sale] = await db.select().from(sales).where(eq(sales.id, id));
    return sale;
  }

  async getSaleByInvoiceNumber(invoiceNumber: string): Promise<SaleResponse | undefined> {
    const [sale] = await db.select().from(sales).where(eq(sales.invoiceNumber, invoiceNumber));
    return sale;
  }

  async createSale(sale: InsertSale): Promise<SaleResponse> {
    const [newSale] = await db.insert(sales).values(sale).returning();
    return newSale;
  }

  async updateSale(id: number, updates: Partial<InsertSale>): Promise<SaleResponse> {
    const [updatedSale] = await db
      .update(sales)
      .set(updates)
      .where(eq(sales.id, id))
      .returning();
    return updatedSale;
  }

  async deleteSale(id: number): Promise<void> {
    await db.delete(sales).where(eq(sales.id, id));
  }

  async bulkCreateSales(salesData: InsertSale[]): Promise<SaleResponse[]> {
    if (salesData.length === 0) return [];
    return await db.insert(sales).values(salesData).returning();
  }

  async getNotifications(userId: number): Promise<Notification[]> {
    const results = await db
      .select({
        id: notifications.id,
        userId: notifications.userId,
        action: notifications.action,
        target: notifications.target,
        details: notifications.details,
        timestamp: notifications.timestamp,
        isRead: userNotifications.isRead,
        dismissed: userNotifications.dismissed,
      })
      .from(notifications)
      .leftJoin(userNotifications, and(eq(userNotifications.notificationId, notifications.id), eq(userNotifications.userId, userId)))
      .where(or(isNull(userNotifications.dismissed), eq(userNotifications.dismissed, false)))
      .orderBy(desc(notifications.timestamp))
      .limit(20);
    
    return results.map(r => ({ ...r, isRead: r.isRead ?? false }));
  }

  async createNotification(notif: InsertNotification): Promise<Notification> {
    const [newNotif] = await db.insert(notifications).values(notif).returning();
    // Auto-mark as read for the creator so they don't see the unread dot for their own actions
    if (notif.userId) {
      await db.insert(userNotifications).values({
        userId: notif.userId,
        notificationId: newNotif.id,
        isRead: true,
      });
    }
    return { ...newNotif, isRead: true };
  }

  async markNotificationsAsRead(userId: number): Promise<void> {
    // Only process the 20 most recent notifications (same set shown in the panel)
    const recentNotifs = await db
      .select({ id: notifications.id })
      .from(notifications)
      .orderBy(desc(notifications.timestamp))
      .limit(20);

    if (recentNotifs.length === 0) return;
    const notifIds = recentNotifs.map(n => n.id);

    // Find which ones already have a record for this user
    const existing = await db
      .select({ notificationId: userNotifications.notificationId })
      .from(userNotifications)
      .where(and(
        eq(userNotifications.userId, userId),
        inArray(userNotifications.notificationId, notifIds)
      ));
    const existingIds = new Set(existing.map(e => e.notificationId));

    // Bulk update existing records
    if (existingIds.size > 0) {
      await db
        .update(userNotifications)
        .set({ isRead: true })
        .where(and(
          eq(userNotifications.userId, userId),
          inArray(userNotifications.notificationId, Array.from(existingIds))
        ));
    }

    // Bulk insert for notifications not yet tracked for this user
    const toInsert = notifIds.filter(id => !existingIds.has(id));
    if (toInsert.length > 0) {
      await db.insert(userNotifications).values(
        toInsert.map(notifId => ({ userId, notificationId: notifId, isRead: true }))
      );
    }
  }

  async clearNotifications(userId: number): Promise<void> {
    // Get all current notifications
    const allNotifs = await db.select({ id: notifications.id }).from(notifications).orderBy(desc(notifications.timestamp)).limit(100);
    if (allNotifs.length === 0) return;
    const allIds = allNotifs.map(n => n.id);

    // Find which ones already have a userNotifications record for this user
    const existing = await db
      .select({ notificationId: userNotifications.notificationId })
      .from(userNotifications)
      .where(and(eq(userNotifications.userId, userId), inArray(userNotifications.notificationId, allIds)));
    const existingIds = new Set(existing.map(e => e.notificationId));

    // Mark existing records as dismissed
    if (existingIds.size > 0) {
      await db
        .update(userNotifications)
        .set({ isRead: true, dismissed: true })
        .where(and(eq(userNotifications.userId, userId), inArray(userNotifications.notificationId, Array.from(existingIds))));
    }

    // Insert dismissed records for notifications not yet tracked for this user
    const toInsert = allIds.filter(id => !existingIds.has(id));
    if (toInsert.length > 0) {
      await db.insert(userNotifications).values(
        toInsert.map(notifId => ({ userId, notificationId: notifId, isRead: true, dismissed: true }))
      );
    }
  }

  // -----------------
  // Oil
  // -----------------

  async getOilSales(): Promise<OilSale[]> {
    return await db.select().from(oilSales).orderBy(desc(oilSales.date), desc(oilSales.createdAt));
  }

  async getOilPurchases(): Promise<OilPurchase[]> {
    return await db.select().from(oilPurchases).orderBy(desc(oilPurchases.date), desc(oilPurchases.createdAt));
  }

  async getOilStock(): Promise<{ huile_10w40: number; huile_20w50: number; gear_oil: number; break_oil: number }> {
    return this.getOilStockWithExecutor();
  }

  async createOilPurchase(p: InsertOilPurchase): Promise<OilPurchase> {
    const [row] = await db.insert(oilPurchases).values(p).returning();
    return row;
  }

  async deleteOilPurchase(id: number): Promise<void> {
    await db.delete(oilPurchases).where(eq(oilPurchases.id, id));
  }

  async createOilSale(sale: InsertOilSale): Promise<OilSale> {
    const stock = await this.getOilStockWithExecutor();
    const q10 = Number(sale.huile10w40 ?? 0);
    const q20 = Number(sale.huile20w50 ?? 0);
    const qGear = Number(sale.gearOil ?? 0);
    const qBrake = Number(sale.brakeOil ?? 0);
    if (
      q10 > stock.huile_10w40 ||
      q20 > stock.huile_20w50 ||
      qGear > stock.gear_oil ||
      qBrake > stock.break_oil
    ) {
      const err: any = new Error("Stock insuffisant");
      err.status = 400;
      throw err;
    }
    const inserted = await db.insert(oilSales).values(sale).returning();
    return Array.isArray(inserted) ? (inserted[0] as OilSale) : (inserted as unknown as OilSale);
  }

  async seedOilSales(rows: InsertOilSale[]): Promise<void> {
    if (!rows.length) return;
    await db.insert(oilSales).values(rows);
  }

  async updateOilSale(id: number, updates: Partial<InsertOilSale>): Promise<OilSale> {
    const [row] = await db.update(oilSales).set(updates).where(eq(oilSales.id, id)).returning();
    if (!row) {
      const err: any = new Error("Not found");
      err.status = 404;
      throw err;
    }
    return row;
  }

  async deleteOilSale(id: number): Promise<void> {
    await db.delete(oilSales).where(eq(oilSales.id, id));
  }

  // -----------------
  // Helmets
  // -----------------

  async getHelmetSales(): Promise<HelmetSale[]> {
    return await db.select().from(helmetSales).orderBy(desc(helmetSales.date), desc(helmetSales.createdAt));
  }

  async getHelmetPurchases(): Promise<HelmetPurchase[]> {
    return await db.select().from(helmetPurchases).orderBy(desc(helmetPurchases.date), desc(helmetPurchases.createdAt));
  }

  async getHelmetStock(): Promise<Array<{ designation: string; stock: number }>> {
    const purchases = await db
      .select({
        designation: helmetPurchases.designation,
        qty: sql<number>`coalesce(sum(${helmetPurchases.quantite}), 0)`,
      })
      .from(helmetPurchases)
      .groupBy(helmetPurchases.designation);

    const salesAgg = await db
      .select({
        designation: helmetSales.designation,
        qty: sql<number>`coalesce(sum(${helmetSales.quantite}), 0)`,
      })
      .from(helmetSales)
      .groupBy(helmetSales.designation);

    const pMap = new Map<string, number>();
    for (const p of purchases) pMap.set(p.designation, Number(p.qty ?? 0));

    const sMap = new Map<string, number>();
    for (const s of salesAgg) sMap.set(s.designation, Number(s.qty ?? 0));

    const allDesignations = new Set<string>([...Array.from(pMap.keys()), ...Array.from(sMap.keys())]);
    const rows = Array.from(allDesignations).map((designation) => ({
      designation,
      stock: (pMap.get(designation) ?? 0) - (sMap.get(designation) ?? 0),
    }));

    rows.sort((a, b) => a.designation.localeCompare(b.designation));
    return rows;
  }

  async createHelmetPurchase(p: InsertHelmetPurchase): Promise<HelmetPurchase> {
    const [row] = await db.insert(helmetPurchases).values(p).returning();
    return row;
  }

  async deleteHelmetPurchase(id: number): Promise<void> {
    await db.delete(helmetPurchases).where(eq(helmetPurchases.id, id));
  }

  private async getHelmetStockForDesignation(designation: string): Promise<number> {
    const [p] = await db
      .select({ qty: sql<number>`coalesce(sum(${helmetPurchases.quantite}), 0)` })
      .from(helmetPurchases)
      .where(eq(helmetPurchases.designation, designation));

    const [s] = await db
      .select({ qty: sql<number>`coalesce(sum(${helmetSales.quantite}), 0)` })
      .from(helmetSales)
      .where(eq(helmetSales.designation, designation));

    return Number(p?.qty ?? 0) - Number(s?.qty ?? 0);
  }

  async createHelmetSale(sale: InsertHelmetSale): Promise<HelmetSale> {
    const current = await this.getHelmetStockForDesignation(sale.designation);
    const qty = Number(sale.quantite ?? 1);
    if (qty > current) {
      const err: any = new Error("Stock insuffisant");
      err.status = 400;
      throw err;
    }
    const inserted = await db.insert(helmetSales).values(sale).returning();
    return Array.isArray(inserted) ? (inserted[0] as HelmetSale) : (inserted as unknown as HelmetSale);
  }

  async seedHelmetSales(rows: InsertHelmetSale[]): Promise<void> {
    if (!rows.length) return;
    await db.insert(helmetSales).values(rows);
  }

  async updateHelmetSale(id: number, updates: Partial<InsertHelmetSale>): Promise<HelmetSale> {
    const [row] = await db.update(helmetSales).set(updates).where(eq(helmetSales.id, id)).returning();
    if (!row) {
      const err: any = new Error("Not found");
      err.status = 404;
      throw err;
    }
    return row;
  }

  async deleteHelmetSale(id: number): Promise<void> {
    await db.delete(helmetSales).where(eq(helmetSales.id, id));
  }

  // -----------------
  // Saddles (Cache Selle)
  // -----------------

  private async getSaddleStockWithExecutor(): Promise<{ taille_xl: number; taille_xxl: number }> {
    const [p] = await db
      .select({
        qxl: sql<number>`coalesce(sum(${saddlePurchases.tailleXl}), 0)`,
        qxxl: sql<number>`coalesce(sum(${saddlePurchases.tailleXxl}), 0)`,
      })
      .from(saddlePurchases);

    const [s] = await db
      .select({
        qxl: sql<number>`coalesce(sum(${saddleSales.tailleXl}), 0)`,
        qxxl: sql<number>`coalesce(sum(${saddleSales.tailleXxl}), 0)`,
      })
      .from(saddleSales);

    return {
      taille_xl: Number(p?.qxl ?? 0) - Number(s?.qxl ?? 0),
      taille_xxl: Number(p?.qxxl ?? 0) - Number(s?.qxxl ?? 0),
    };
  }

  async getSaddleSales(): Promise<SaddleSale[]> {
    return await db.select().from(saddleSales).orderBy(desc(saddleSales.date), desc(saddleSales.createdAt));
  }

  async getSaddlePurchases(): Promise<SaddlePurchase[]> {
    return await db.select().from(saddlePurchases).orderBy(desc(saddlePurchases.date), desc(saddlePurchases.createdAt));
  }

  async getSaddleStock(): Promise<{ taille_xl: number; taille_xxl: number }> {
    return this.getSaddleStockWithExecutor();
  }

  async createSaddlePurchase(p: InsertSaddlePurchase): Promise<SaddlePurchase> {
    const [row] = await db.insert(saddlePurchases).values(p).returning();
    return row;
  }

  async deleteSaddlePurchase(id: number): Promise<void> {
    await db.delete(saddlePurchases).where(eq(saddlePurchases.id, id));
  }

  async createSaddleSale(sale: InsertSaddleSale): Promise<SaddleSale> {
    const stock = await this.getSaddleStockWithExecutor();
    const qxl = Number(sale.tailleXl ?? 0);
    const qxxl = Number(sale.tailleXxl ?? 0);
    if (qxl > stock.taille_xl || qxxl > stock.taille_xxl) {
      const err: any = new Error("Stock insuffisant");
      err.status = 400;
      throw err;
    }
    const inserted = await db.insert(saddleSales).values(sale).returning();
    return Array.isArray(inserted) ? (inserted[0] as SaddleSale) : (inserted as unknown as SaddleSale);
  }

  async seedSaddleSales(rows: InsertSaddleSale[]): Promise<void> {
    if (!rows.length) return;
    await db.insert(saddleSales).values(rows);
  }

  async updateSaddleSale(id: number, updates: Partial<InsertSaddleSale>): Promise<SaddleSale> {
    const [row] = await db.update(saddleSales).set(updates).where(eq(saddleSales.id, id)).returning();
    if (!row) {
      const err: any = new Error("Not found");
      err.status = 404;
      throw err;
    }
    return row;
  }

  async deleteSaddleSale(id: number): Promise<void> {
    await db.delete(saddleSales).where(eq(saddleSales.id, id));
  }

  // -----------------
  // Deferred / Divers
  // -----------------

  async getDeferredSales(): Promise<DeferredSale[]> {
    return await db.select().from(deferredSales).orderBy(desc(deferredSales.date), desc(deferredSales.createdAt));
  }

  private async getDiversStockForDesignation(designation: string): Promise<number> {
    const [p] = await db
      .select({ qty: sql<number>`coalesce(sum(${diversPurchases.quantite}), 0)` })
      .from(diversPurchases)
      .where(eq(diversPurchases.designation, designation));

    const [s] = await db
      .select({ qty: sql<number>`coalesce(sum(${deferredSales.quantite}), 0)` })
      .from(deferredSales)
      .where(eq(deferredSales.designation, designation));

    return Number(p?.qty ?? 0) - Number(s?.qty ?? 0);
  }

  async getDiversStock(): Promise<Array<{ designation: string; stock: number }>> {
    const purchases = await db
      .select({
        designation: diversPurchases.designation,
        qty: sql<number>`coalesce(sum(${diversPurchases.quantite}), 0)`,
      })
      .from(diversPurchases)
      .groupBy(diversPurchases.designation);

    const salesAgg = await db
      .select({
        designation: deferredSales.designation,
        qty: sql<number>`coalesce(sum(${deferredSales.quantite}), 0)`,
      })
      .from(deferredSales)
      .groupBy(deferredSales.designation);

    const pMap = new Map<string, number>();
    for (const p of purchases) pMap.set(p.designation, Number(p.qty ?? 0));

    const sMap = new Map<string, number>();
    for (const s of salesAgg) sMap.set(s.designation, Number(s.qty ?? 0));

    const allDesignations = new Set<string>([...Array.from(pMap.keys()), ...Array.from(sMap.keys())]);
    const rows = Array.from(allDesignations).map((designation) => ({
      designation,
      stock: (pMap.get(designation) ?? 0) - (sMap.get(designation) ?? 0),
    }));

    rows.sort((a, b) => a.designation.localeCompare(b.designation));
    return rows;
  }

  async getDiversPurchases(): Promise<DiversPurchase[]> {
    return await db.select().from(diversPurchases).orderBy(desc(diversPurchases.date), desc(diversPurchases.createdAt));
  }

  async createDiversPurchase(p: InsertDiversPurchase): Promise<DiversPurchase> {
    const [row] = await db.insert(diversPurchases).values(p).returning();
    return row;
  }

  async deleteDiversPurchase(id: number): Promise<void> {
    await db.delete(diversPurchases).where(eq(diversPurchases.id, id));
  }

  async createDeferredSale(sale: InsertDeferredSale): Promise<DeferredSale> {
    const qty = Number(sale.quantite ?? 1);
    if (qty > 0) {
      const stock = await this.getDiversStockForDesignation(sale.designation);
      if (qty > stock) {
        const err: any = new Error("Stock insuffisant");
        err.status = 400;
        throw err;
      }
    }
    const values = { ...sale, quantite: sale.quantite ?? 1 };
    const inserted = await db.insert(deferredSales).values(values).returning();
    return Array.isArray(inserted) ? (inserted[0] as DeferredSale) : (inserted as unknown as DeferredSale);
  }

  async updateDeferredSale(id: number, updates: Partial<InsertDeferredSale>): Promise<DeferredSale> {
    const [row] = await db.update(deferredSales).set(updates).where(eq(deferredSales.id, id)).returning();
    if (!row) {
      const err: any = new Error("Not found");
      err.status = 404;
      throw err;
    }
    return row;
  }

  async deleteDeferredSale(id: number): Promise<void> {
    await db.delete(deferredSales).where(eq(deferredSales.id, id));
  }

  // -----------------
  // Clients
  // -----------------

  async getClients(): Promise<Client[]> {
    return await db.select().from(clients).orderBy(desc(clients.createdAt), desc(clients.id));
  }

  async createClient(client: InsertClient): Promise<Client> {
    const [row] = await db.insert(clients).values(client).returning();
    return row;
  }

  async updateClient(id: number, updates: Partial<InsertClient>): Promise<Client> {
    const [row] = await db.update(clients).set(updates).where(eq(clients.id, id)).returning();
    if (!row) {
      const err: any = new Error("Not found");
      err.status = 404;
      throw err;
    }
    return row;
  }

  async deleteClient(id: number): Promise<void> {
    await db.delete(clients).where(eq(clients.id, id));
  }

  // -----------------
  // Numbering helpers (BL + Facture)
  // -----------------

  async nextDeliveryNoteNumber(): Promise<string> {
    const year = new Date().getFullYear().toString().slice(-2);
    const livRows = await db.select({ bn: livraisons.bonNumber }).from(livraisons);
    const max = livRows.reduce((m, r) => {
      const parts = (r.bn || "").split("/");
      if (parts.length < 2) return m;
      const n = parseInt(parts[1] || "0");
      return n > m ? n : m;
    }, 0);
    return `${year}/${String(max + 1).padStart(6, "0")}`;
  }

  async nextFactureNumber(): Promise<string> {
    const year = new Date().getFullYear().toString().slice(-2);
    const rowsHeader = await db.select({ fn: factures.factureNumber }).from(factures);
    const max = rowsHeader.reduce((m, r) => {
      const parts = (r.fn || "").split("/");
      if (parts.length < 2) return m;
      const n = parseInt(parts[1] || "0");
      return n > m ? n : m;
    }, 0);
    return `${year}/${String(max + 1).padStart(6, "0")}`;
  }

  // -----------------
  // Factures v2 (header + lines workflow)
  // -----------------
  async getFacturesV2(): Promise<(Facture & { lineCount: number; totalHt: number; totalTva: number; totalTtc: number })[]> {
    const headers = await db.select().from(factures).orderBy(desc(factures.factureNumber));
    const allLines = await db.select().from(factureLines);
    return headers.map(h => {
      const ls = allLines.filter(l => l.factureId === h.id);
      return {
        ...h,
        lineCount: ls.length,
        totalHt: ls.reduce((s, x) => s + x.montantHt, 0),
        totalTva: ls.reduce((s, x) => s + x.montantTva, 0),
        totalTtc: ls.reduce((s, x) => s + x.montantTtc, 0),
      };
    });
  }

  async getFactureV2WithLines(id: number): Promise<(Facture & { lines: FactureLine[] }) | undefined> {
    const [header] = await db.select().from(factures).where(eq(factures.id, id)).limit(1);
    if (!header) return undefined;
    const lines = await db.select().from(factureLines).where(eq(factureLines.factureId, id));
    return { ...header, lines };
  }

  async createFactureV2(data: InsertFacture): Promise<Facture> {
    const [row] = await db.insert(factures).values(data).returning();
    return row;
  }

  async addFactureV2Line(factureId: number, line: InsertFactureLine): Promise<FactureLine> {
    const [row] = await db.insert(factureLines).values({ ...line, factureId }).returning();
    return row;
  }

  async updateFactureV2(id: number, data: Partial<InsertFacture>): Promise<Facture> {
    const [row] = await db.update(factures).set(data).where(eq(factures.id, id)).returning();
    return row;
  }

  async replaceFactureV2Lines(id: number, lines: InsertFactureLine[]): Promise<void> {
    await db.delete(factureLines).where(eq(factureLines.factureId, id));
    if (lines.length > 0) {
      await db.insert(factureLines).values(lines.map(l => ({ ...l, factureId: id })));
    }
  }

  async deleteFactureV2(id: number): Promise<void> {
    await db.delete(factureLines).where(eq(factureLines.factureId, id));
    await db.delete(factures).where(eq(factures.id, id));
  }

  async validateFactureV2(id: number): Promise<Facture> {
    const header = await this.getFactureV2WithLines(id);
    if (!header) throw new Error("Facture introuvable");
    const [row] = await db.update(factures).set({ status: "validated" }).where(eq(factures.id, id)).returning();
    // If facture references a BL number, mark that livraison as facturé
    if (header.bonRef) {
      const livs = await db.select().from(livraisons).where(eq(livraisons.bonNumber, header.bonRef));
      for (const liv of livs) {
        await db.update(livraisons).set({ factureNumber: header.factureNumber }).where(eq(livraisons.id, liv.id));
      }
    }
    return row;
  }

  // -----------------
  // Reservations
  // -----------------

  async getReservations(): Promise<Reservation[]> {
    return await db.select().from(reservations).orderBy(desc(reservations.date), desc(reservations.createdAt));
  }

  async createReservation(r: InsertReservation): Promise<Reservation> {
    const [row] = await db.insert(reservations).values(r).returning();
    return row;
  }

  async updateReservation(id: number, updates: Partial<InsertReservation>): Promise<Reservation> {
    const [row] = await db.update(reservations).set(updates).where(eq(reservations.id, id)).returning();
    if (!row) { const err: any = new Error("Not found"); err.status = 404; throw err; }
    return row;
  }

  async deleteReservation(id: number): Promise<void> {
    await db.delete(reservations).where(eq(reservations.id, id));
  }

  // -----------------
  // Orders (Commandes)
  // -----------------

  async getOrders(): Promise<Order[]> {
    return await db.select().from(orders).orderBy(desc(orders.date), desc(orders.createdAt));
  }

  async createOrder(o: InsertOrder): Promise<Order> {
    const [row] = await db.insert(orders).values(o).returning();
    return row;
  }

  async updateOrder(id: number, updates: Partial<InsertOrder>): Promise<Order> {
    const [row] = await db.update(orders).set(updates).where(eq(orders.id, id)).returning();
    if (!row) { const err: any = new Error("Not found"); err.status = 404; throw err; }
    return row;
  }

  async deleteOrder(id: number): Promise<void> {
    await db.delete(orders).where(eq(orders.id, id));
  }

  // -----------------
  // Tarif (Product Prices)
  // -----------------

  async getProductPrices(search?: string): Promise<ProductPrice[]> {
    if (search && search.trim()) {
      const term = `%${search.trim().toLowerCase()}%`;
      return await db
        .select()
        .from(productPrices)
        .where(sql`lower(${productPrices.designation}) LIKE ${term}`)
        .orderBy(productPrices.number);
    }
    return await db.select().from(productPrices).orderBy(productPrices.number);
  }

  async bulkUpsertProductPrices(rows: InsertProductPrice[]): Promise<void> {
    if (rows.length === 0) return;
    const CHUNK = 500;
    for (let i = 0; i < rows.length; i += CHUNK) {
      const chunk = rows.slice(i, i + CHUNK);
      await db
        .insert(productPrices)
        .values(chunk)
        .onConflictDoNothing();
    }
  }

  async deleteAllProductPrices(): Promise<void> {
    await db.delete(productPrices);
  }

  // ---- Product Families ----
  async getProductFamilies(): Promise<ProductFamily[]> {
    return db.select().from(productFamilies).orderBy(asc(productFamilies.name));
  }
  async createProductFamily(data: InsertProductFamily): Promise<ProductFamily> {
    const [row] = await db.insert(productFamilies).values(data).returning();
    return row;
  }
  async updateProductFamily(id: number, data: Partial<InsertProductFamily>): Promise<ProductFamily> {
    const [row] = await db.update(productFamilies).set(data).where(eq(productFamilies.id, id)).returning();
    return row;
  }
  async deleteProductFamily(id: number): Promise<void> {
    await db.delete(productFamilies).where(eq(productFamilies.id, id));
  }

  // ---- Products ----
  async getProducts(familyId?: number, search?: string): Promise<(Product & { familyName: string | null; availableQty: number })[]> {
    const rows = await db.select().from(products).orderBy(asc(products.reference));
    const families = await db.select().from(productFamilies);
    const familyMap = new Map(families.map(f => [f.id, f.name]));
    const serialCounts = await db.select({
      productId: productSerials.productId,
      cnt: sql<number>`count(*)::int`,
    }).from(productSerials).where(eq(productSerials.status, "available")).groupBy(productSerials.productId);
    const countMap = new Map(serialCounts.map(r => [r.productId, r.cnt]));
    let result = rows.map(p => ({ ...p, familyName: p.familyId ? (familyMap.get(p.familyId) ?? null) : null, availableQty: countMap.get(p.id) ?? 0 }));
    // Casques have their own dedicated module — exclude from stock motos
    result = result.filter(p => p.familyName !== 'Casques');
    if (familyId) result = result.filter(p => p.familyId === familyId);
    if (search) { const q = search.toLowerCase(); result = result.filter(p => p.designation.toLowerCase().includes(q) || p.reference.toLowerCase().includes(q)); }
    result.sort((a, b) => b.availableQty - a.availableQty || a.reference.localeCompare(b.reference));
    return result;
  }
  async getProduct(id: number): Promise<Product | undefined> {
    const [row] = await db.select().from(products).where(eq(products.id, id));
    return row;
  }
  async createProduct(data: InsertProduct): Promise<Product> {
    const [row] = await db.insert(products).values(data).returning();
    return row;
  }
  async updateProduct(id: number, data: Partial<InsertProduct>): Promise<Product> {
    const [row] = await db.update(products).set(data).where(eq(products.id, id)).returning();
    return row;
  }
  async deleteProduct(id: number): Promise<void> {
    await db.delete(products).where(eq(products.id, id));
  }

  // ---- Product Serials ----
  async getProductSerials(productId: number): Promise<ProductSerial[]> {
    return db.select().from(productSerials).where(eq(productSerials.productId, productId)).orderBy(desc(productSerials.createdAt));
  }
  async getAvailableSerials(productId: number): Promise<ProductSerial[]> {
    return db.select().from(productSerials).where(and(eq(productSerials.productId, productId), eq(productSerials.status, "available"))).orderBy(asc(productSerials.serialNumber));
  }
  async createProductSerial(data: InsertProductSerial): Promise<ProductSerial> {
    const [row] = await db.insert(productSerials).values(data).returning();
    return row;
  }
  async updateProductSerialStatus(id: number, status: string, livraisonId?: number): Promise<void> {
    await db.update(productSerials).set({ status, ...(livraisonId !== undefined ? { livraisonId } : {}) }).where(eq(productSerials.id, id));
  }
  async bulkCreateProductSerials(serials: InsertProductSerial[]): Promise<ProductSerial[]> {
    if (serials.length === 0) return [];
    return db.insert(productSerials).values(serials).returning();
  }

  // ---- Receptions ----
  async nextReceptionNumber(): Promise<string> {
    const year = new Date().getFullYear().toString().slice(-2);
    const rows = await db.select({ bn: receptions.bonNumber }).from(receptions).where(sql`bon_number LIKE ${year + '/%'}`);
    const max = rows.reduce((m, r) => { const n = parseInt(r.bn.split("/")[1] || "0"); return n > m ? n : m; }, 0);
    return `${year}/${String(max + 1).padStart(6, "0")}`;
  }
  async getReceptions(): Promise<(Reception & { lines: (ReceptionLine & { product: Product | null })[] })[]> {
    const recs = await db.select().from(receptions).orderBy(desc(receptions.createdAt));
    const lines = await db.select().from(receptionLines);
    const prods = await db.select().from(products);
    const prodMap = new Map(prods.map(p => [p.id, p]));
    return recs.map(r => ({
      ...r,
      lines: lines.filter(l => l.receptionId === r.id).map(l => ({ ...l, product: prodMap.get(l.productId) ?? null })),
    }));
  }
  async getReception(id: number): Promise<(Reception & { lines: (ReceptionLine & { product: Product | null })[] }) | undefined> {
    const [rec] = await db.select().from(receptions).where(eq(receptions.id, id));
    if (!rec) return undefined;
    const lines = await db.select().from(receptionLines).where(eq(receptionLines.receptionId, id));
    const prods = await db.select().from(products);
    const prodMap = new Map(prods.map(p => [p.id, p]));
    return { ...rec, lines: lines.map(l => ({ ...l, product: prodMap.get(l.productId) ?? null })) };
  }
  async createReception(
    data: InsertReception,
    lines: InsertReceptionLine[],
    serialsPerLine: { productId: number; serial: string; purchasePrice: number }[][]
  ): Promise<Reception> {
    const [rec] = await db.insert(receptions).values(data).returning();
    for (let i = 0; i < lines.length; i++) {
      await db.insert(receptionLines).values({ ...lines[i], receptionId: rec.id }).returning();
      const sers = serialsPerLine[i] ?? [];
      for (const s of sers) {
        await db.insert(productSerials).values({ productId: s.productId, serialNumber: s.serial, purchasePrice: s.purchasePrice, status: "available", receptionId: rec.id }).onConflictDoNothing();
      }
    }
    return rec;
  }
  async updateReception(id: number, data: Partial<InsertReception>): Promise<Reception> {
    const [row] = await db.update(receptions).set(data).where(eq(receptions.id, id)).returning();
    return row;
  }
  async deleteReception(id: number): Promise<void> {
    await db.delete(productSerials).where(and(eq(productSerials.receptionId, id), eq(productSerials.status, "available")));
    await db.delete(receptionLines).where(eq(receptionLines.receptionId, id));
    await db.delete(receptions).where(eq(receptions.id, id));
  }

  // ---- Livraisons ----
  async nextLivraisonNumber(): Promise<string> {
    const year = new Date().getFullYear().toString().slice(-2);
    const rows = await db.select({ bn: livraisons.bonNumber }).from(livraisons).where(sql`bon_number LIKE ${year + '/%'}`);
    const max = rows.reduce((m, r) => { const n = parseInt(r.bn.split("/")[1] || "0"); return n > m ? n : m; }, 0);
    return `${year}/${String(max + 1).padStart(6, "0")}`;
  }
  async getLivraisons(): Promise<(Livraison & { lines: LivraisonLine[]; totalHt: number; totalTtc: number })[]> {
    const livs = await db.select().from(livraisons).orderBy(desc(livraisons.bonNumber));
    const lines = await db.select().from(livraisonLines);
    return livs.map(l => {
      const ls = lines.filter(ll => ll.livraisonId === l.id);
      return { ...l, lines: ls, totalHt: ls.reduce((s, x) => s + x.montantHt, 0), totalTtc: ls.reduce((s, x) => s + x.montantTtc, 0) };
    });
  }
  async getLivraison(id: number): Promise<(Livraison & { lines: LivraisonLine[] }) | undefined> {
    const [liv] = await db.select().from(livraisons).where(eq(livraisons.id, id));
    if (!liv) return undefined;
    const lines = await db.select().from(livraisonLines).where(eq(livraisonLines.livraisonId, id));
    return { ...liv, lines };
  }
  async createLivraison(data: InsertLivraison): Promise<Livraison> {
    const [row] = await db.insert(livraisons).values(data).returning();
    return row;
  }
  async updateLivraison(id: number, data: Partial<InsertLivraison>): Promise<Livraison> {
    const [row] = await db.update(livraisons).set(data).where(eq(livraisons.id, id)).returning();
    return row;
  }
  async deleteLivraison(id: number): Promise<void> {
    const lines = await db.select().from(livraisonLines).where(eq(livraisonLines.livraisonId, id));
    for (const l of lines) {
      if (l.productSerialId) await db.update(productSerials).set({ status: "available", livraisonId: null }).where(eq(productSerials.id, l.productSerialId));
    }
    await db.delete(livraisonLines).where(eq(livraisonLines.livraisonId, id));
    await db.delete(livraisons).where(eq(livraisons.id, id));
  }
  async addLivraisonLine(line: InsertLivraisonLine): Promise<LivraisonLine> {
    if (line.productSerialId) {
      await db.update(productSerials).set({ status: "reserved" }).where(eq(productSerials.id, line.productSerialId));
    }
    const [row] = await db.insert(livraisonLines).values(line).returning();
    return row;
  }
  async removeLivraisonLine(lineId: number): Promise<void> {
    const [line] = await db.select().from(livraisonLines).where(eq(livraisonLines.id, lineId));
    if (line?.productSerialId) await db.update(productSerials).set({ status: "available", livraisonId: null }).where(eq(productSerials.id, line.productSerialId));
    await db.delete(livraisonLines).where(eq(livraisonLines.id, lineId));
  }
  async validateLivraison(id: number): Promise<void> {
    const lines = await db.select().from(livraisonLines).where(eq(livraisonLines.livraisonId, id));
    for (const l of lines) {
      if (l.productSerialId) await db.update(productSerials).set({ status: "sold", livraisonId: id }).where(eq(productSerials.id, l.productSerialId));
    }
    await db.update(livraisons).set({ status: "validated" }).where(eq(livraisons.id, id));
  }

}

export const storage = new DatabaseStorage();
