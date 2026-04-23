import "dotenv/config";
import XLSX from "xlsx";
import { db } from "../server/db";
import {
  factures, factureLines, livraisons, livraisonLines,
  productSerials, products, productFamilies, clients,
} from "../shared/schema";
import { eq, sql } from "drizzle-orm";

const XLSX_PATH = "attached_assets/Bon_de_livraison_160_Cleaned_1776848923042.xlsx";

function excelSerialToISO(serial: number): string {
  const d = XLSX.SSF.parse_date_code(serial);
  if (!d) return "";
  const yyyy = String(d.y).padStart(4, "0");
  const mm = String(d.m).padStart(2, "0");
  const dd = String(d.d).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

function frToISO(s: string): string {
  const m = s.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (!m) return s;
  return `${m[3]}-${m[2].padStart(2, "0")}-${m[1].padStart(2, "0")}`;
}

function parseDate(v: any): string {
  if (typeof v === "number") return excelSerialToISO(v);
  if (typeof v === "string") {
    if (/^\d{4}-\d{2}-\d{2}/.test(v)) return v.slice(0, 10);
    if (/^\d{1,2}\/\d{1,2}\/\d{4}$/.test(v)) return frToISO(v);
    if (/^\d+$/.test(v)) return excelSerialToISO(Number(v));
  }
  return String(v ?? "");
}

function num(v: any): number {
  if (v == null || v === "") return 0;
  if (typeof v === "number") return v;
  return parseFloat(String(v).replace(",", ".")) || 0;
}

function tvaStr(v: any): string {
  if (typeof v === "number") {
    const pct = v <= 1 ? Math.round(v * 100) : Math.round(v);
    return `${pct}%`;
  }
  return String(v ?? "19%");
}

async function main() {
  console.log("[reimport] Reading", XLSX_PATH);
  const wb = XLSX.readFile(XLSX_PATH);
  const sh = wb.Sheets[wb.SheetNames[0]];
  const rows: any[][] = XLSX.utils.sheet_to_json(sh, { header: 1, raw: true });

  // ── 1) Wipe existing facture/livraison/serial data
  console.log("[reimport] Clearing existing v2 invoice/delivery data...");
  await db.delete(factureLines);
  await db.delete(factures);
  await db.delete(livraisonLines);
  await db.delete(livraisons);
  // Reset all delivered serials back to "available" then drop them; we will recreate.
  await db.delete(productSerials);
  await db.delete(products);
  await db.delete(productFamilies);

  // ── 2) Restart sequences so new ids start at 1 (cosmetic but tidy)
  await db.execute(sql`ALTER SEQUENCE factures_id_seq RESTART WITH 1`);
  await db.execute(sql`ALTER SEQUENCE facture_lines_id_seq RESTART WITH 1`);
  await db.execute(sql`ALTER SEQUENCE livraisons_id_seq RESTART WITH 1`);
  await db.execute(sql`ALTER SEQUENCE livraison_lines_id_seq RESTART WITH 1`);
  await db.execute(sql`ALTER SEQUENCE products_id_seq RESTART WITH 1`);
  await db.execute(sql`ALTER SEQUENCE product_serials_id_seq RESTART WITH 1`);
  await db.execute(sql`ALTER SEQUENCE product_families_id_seq RESTART WITH 1`);

  // ── 3) Default product family
  const [family] = await db.insert(productFamilies).values({ name: "Motos" }).returning();
  console.log("[reimport] Created product family", family.id, family.name);

  // ── 4) Build product catalog from xlsx (unique by ref|designation)
  type LineRow = {
    bl: string; date: string; commercial: string; client: string; idClient: string;
    factNum: string; ref: string; desig: string; qte: number; prix: number;
    tva: string; remise: number; prixTtc: number; ht: number; tvaAmt: number; ttc: number;
    serial: string;
  };

  const dataLines: LineRow[] = [];
  for (let i = 1; i < rows.length; i++) {
    const r = rows[i] || [];
    if (!r[0]) continue; // skip empty/continuation
    dataLines.push({
      bl: String(r[0]).trim(),
      date: parseDate(r[1]),
      commercial: String(r[2] ?? "").trim(),
      client: String(r[3] ?? "").trim(),
      idClient: r[4] != null ? String(r[4]).trim() : "",
      factNum: r[5] != null ? String(r[5]).trim() : "",
      ref: String(r[6] ?? "").trim(),
      desig: String(r[7] ?? "").replace(/^\s+/, "").trim(),
      qte: num(r[8]),
      prix: num(r[9]),
      tva: tvaStr(r[10]),
      remise: num(r[11]),
      prixTtc: num(r[12]),
      ht: num(r[13]),
      tvaAmt: num(r[14]),
      ttc: num(r[15]),
      serial: r[16] != null ? String(r[16]).trim() : "",
    });
  }
  console.log("[reimport] Parsed", dataLines.length, "data rows");

  // Build unique product map
  const productMap = new Map<string, { ref: string; desig: string; prices: number[]; tvaPcts: number[] }>();
  for (const l of dataLines) {
    const key = `${l.ref}|${l.desig}`;
    if (!productMap.has(key)) productMap.set(key, { ref: l.ref, desig: l.desig, prices: [], tvaPcts: [] });
    const e = productMap.get(key)!;
    e.prices.push(l.prix);
    e.tvaPcts.push(parseFloat(l.tva) || 19);
  }
  const productIdByKey = new Map<string, number>();
  for (const [key, p] of productMap) {
    const avg = p.prices.reduce((s, x) => s + x, 0) / p.prices.length;
    const tva = p.tvaPcts[0] || 19;
    const [row] = await db.insert(products).values({
      reference: p.ref || "",
      designation: p.desig || "",
      familyId: family.id,
      defaultPrice: avg,
      tvaPct: tva,
    }).returning();
    productIdByKey.set(key, row.id);
  }
  console.log("[reimport] Created", productIdByKey.size, "products");

  // ── 5) Build client lookup by uniqueNumber
  const allClients = await db.select().from(clients);
  const clientByUid = new Map<string, { id: number; nomPrenom: string }>();
  for (const c of allClients) {
    if (c.uniqueNumber) clientByUid.set(String(c.uniqueNumber).trim(), c);
  }
  console.log("[reimport] Loaded", allClients.length, "clients (", clientByUid.size, "with uniqueNumber)");

  // ── 6) Group rows by BL number
  const byBL = new Map<string, LineRow[]>();
  for (const l of dataLines) {
    if (!byBL.has(l.bl)) byBL.set(l.bl, []);
    byBL.get(l.bl)!.push(l);
  }
  // Sort BL numbers ascending so ids are assigned in order
  const sortedBLs = Array.from(byBL.keys()).sort();

  let factCount = 0, livCount = 0, lineCount = 0, serialCount = 0;

  for (const blNum of sortedBLs) {
    const ls = byBL.get(blNum)!;
    const head = ls[0];
    const cli = head.idClient ? clientByUid.get(head.idClient) : undefined;
    const clientId = cli?.id ?? null;

    // ── Create livraison
    const [liv] = await db.insert(livraisons).values({
      bonNumber: blNum,
      date: head.date,
      commercial: head.commercial,
      clientId,
      clientName: head.client,
      idClient: head.idClient,
      status: "validated",
      factureNumber: head.factNum,
    } as any).returning();
    livCount++;

    // ── Create facture (1 facture per BL based on factNum, but multiple BLs may share factNum
    //    in this dataset they don't — distinct BL = distinct factNum). Use the BL's factNum.
    const [fac] = await db.insert(factures).values({
      factureNumber: head.factNum || blNum,
      bonRef: blNum,
      date: head.date,
      commercial: head.commercial,
      clientId,
      clientName: head.client,
      idClient: head.idClient,
      matriculeFiscal: "",
      adresseClient: "",
      phoneClient: "",
      status: "validated",
    } as any).returning();
    factCount++;

    for (const l of ls) {
      const productId = productIdByKey.get(`${l.ref}|${l.desig}`)!;
      // Create serial if present
      let serialId: number | null = null;
      if (l.serial) {
        const [s] = await db.insert(productSerials).values({
          productId,
          serialNumber: l.serial,
          purchasePrice: l.prix,
          status: "delivered",
          livraisonId: liv.id,
        } as any).returning();
        serialId = s.id;
        serialCount++;
      }

      // Insert livraison line
      await db.insert(livraisonLines).values({
        livraisonId: liv.id,
        productSerialId: serialId,
        productId,
        ref: l.ref,
        designation: l.desig,
        serialNumber: l.serial,
        prix: l.prix,
        tvaPct: parseFloat(l.tva) || 19,
        remise: l.remise,
        prixTtc: l.prixTtc,
        montantHt: l.ht,
        montantTva: l.tvaAmt,
        montantTtc: l.ttc,
      } as any);

      // Insert facture line
      await db.insert(factureLines).values({
        factureId: fac.id,
        factureNumber: fac.factureNumber,
        bonRef: blNum,
        date: l.date,
        commercial: l.commercial,
        client: l.client,
        idClient: l.idClient,
        ref: l.ref,
        designation: l.desig,
        qte: l.qte,
        prix: l.prix,
        tva: l.tva,
        remise: l.remise,
        prixTtc: l.prixTtc,
        montantHt: l.ht,
        montantTva: l.tvaAmt,
        montantTtc: l.ttc,
      } as any);

      lineCount++;
    }
  }

  console.log(`[reimport] DONE — ${factCount} factures, ${livCount} livraisons, ${lineCount} lines, ${serialCount} serials`);

  // Stats
  const dateStats = await db.execute(sql`SELECT count(*) FILTER (WHERE date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')::int AS iso, count(*) FILTER (WHERE date !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$')::int AS bad FROM factures`);
  console.log("[reimport] facture date sanity:", (dateStats as any).rows[0]);

  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });
