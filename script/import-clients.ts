import { readFileSync } from "fs";
import { join } from "path";
import * as XLSX from "xlsx";
import { db } from "../server/db";
import { clients, type InsertClient } from "../shared/schema";

function findColumnKey(row: any, candidates: string[]): string | null {
  const entries = Object.keys(row || {}).map((key) => ({
    original: key,
    normalized: key.toString().toLowerCase().trim(),
  }));

  for (const cand of candidates) {
    const target = cand.toLowerCase();
    const match = entries.find((e) => e.normalized.includes(target));
    if (match) return match.original;
  }
  return null;
}

async function importClients() {
  const xlsxPath = join(
    process.cwd(),
    "attached_assets",
    "Clients_150_Cleaned.xlsx",
  );

  console.log("📄 Reading Excel file:", xlsxPath);
  const fileBuffer = readFileSync(xlsxPath);

  const workbook = XLSX.read(fileBuffer, { type: "buffer" });
  const sheetName = workbook.SheetNames[0];
  const sheet = workbook.Sheets[sheetName];
  const rows: any[] = XLSX.utils.sheet_to_json(sheet, { defval: "" });

  if (!rows.length) {
    console.error("❌ No rows found in Excel sheet");
    process.exit(1);
  }

  const sample = rows[0];

  const nameKey = findColumnKey(sample, ["nom/prénom", "nom prénom", "nom et prénom", "nom", "client"]) ?? "Nom/Prénom";
  const phoneKey = findColumnKey(sample, ["téléphone", "telephone", "tel", "gsm", "numero", "numéro"]) ?? "Téléphone";
  const phone2Key = findColumnKey(sample, ["téléphone 2", "tel 2", "gsm 2", "deuxième numéro"]) ?? "Téléphone 2";
  const subClientKey = findColumnKey(sample, ["subclient", "sous client", "nom subclient"]) ?? "Nom Sub-Client";
  const addressKey = findColumnKey(sample, ["adresse", "address", "lieu"]) ?? "Adresse";
  const cinKey = findColumnKey(sample, ["cin", "matricule", "identifiant"]) ?? "CIN/Matricule";
  const typeKey = findColumnKey(sample, ["type", "société", "entreprise", "type company"]) ?? "Type Société";
  const cpKey = findColumnKey(sample, ["code postal", "cp", "zip"]) ?? "Code Postal";
  const uniqueKey = findColumnKey(sample, ["unique", "id unique", "numéro unique"]) ?? "Numéro Unique";
  const remarkKey = findColumnKey(sample, ["remarque", "note", "commentaire", "obs"]) ?? "Remarque";

  console.log("✅ Column mapping set.");

  const existing = await db.select().from(clients);
  const existingKey = new Set(
    existing.map(
      (c) =>
        `${c.nomPrenom.toLowerCase().trim()}|${(c.numeroTelephone ?? "")
          .toLowerCase()
          .trim()}`,
    ),
  );

  const toInsert: InsertClient[] = [];

  for (const row of rows) {
    const rawName = String(row[nameKey] || "").trim();
    const rawPhone = String(row[phoneKey] || "").trim();
    
    if (!rawName) continue;

    const key = `${rawName.toLowerCase()}|${rawPhone.toLowerCase()}`;
    if (existingKey.has(key)) continue;

    existingKey.add(key);

    toInsert.push({
      nomPrenom: rawName,
      numeroTelephone: rawPhone,
      numeroTelephone2: String(row[phone2Key] || "").trim(),
      nomSubClient: String(row[subClientKey] || "").trim(),
      adresse: String(row[addressKey] || "").trim(),
      cin: String(row[cinKey] || "").trim(),
      typeCompany: String(row[typeKey] || "").trim(),
      codePostal: String(row[cpKey] || "").trim(),
      uniqueNumber: String(row[uniqueKey] || "").trim(),
      remarque: String(row[remarkKey] || "").trim(),
    });
  }

  if (!toInsert.length) {
    console.log("ℹ️ No new clients found.");
    return;
  }

  console.log(`➡️ Inserting ${toInsert.length} clients...`);
  await db.insert(clients).values(toInsert);
  console.log("✅ Import completed.");
}

importClients().catch(console.error);
