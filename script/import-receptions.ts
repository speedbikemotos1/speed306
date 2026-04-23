import "dotenv/config";
import postgres from "postgres";
import { readFileSync } from "fs";
import { join } from "path";

const sql = postgres(process.env.DATABASE_URL!, { max: 1 });

// ─── CSV Row ──────────────────────────────────────────────────────────────────
type CsvRow = {
  ReceiptNumber: string;
  Date: string;
  Supplier: string;
  InvoiceNumber: string;
  Reference: string;
  Designation: string;
  Quantity: number;
  UnitPrice: number;
  TVA_Percent: number;
  Discount_Percent: number;
  MontantHT: number;
  MontantTVA: number;
  MontantTTC: number;
};

function parseCsv(content: string): CsvRow[] {
  const lines = content.trim().split("\n");
  const headers = lines[0].split(",");
  return lines.slice(1).map(line => {
    // Handle quoted fields
    const values: string[] = [];
    let cur = "";
    let inQuote = false;
    for (const ch of line) {
      if (ch === '"') { inQuote = !inQuote; }
      else if (ch === "," && !inQuote) { values.push(cur.trim()); cur = ""; }
      else { cur += ch; }
    }
    values.push(cur.trim());
    const obj: any = {};
    headers.forEach((h, i) => { obj[h.trim()] = values[i] ?? ""; });
    return {
      ReceiptNumber: obj.ReceiptNumber,
      Date: obj.Date,
      Supplier: obj.Supplier,
      InvoiceNumber: obj.InvoiceNumber,
      Reference: obj.Reference,
      Designation: obj.Designation,
      Quantity: parseInt(obj.Quantity) || 1,
      UnitPrice: parseFloat(obj.UnitPrice) || 0,
      TVA_Percent: parseFloat(obj.TVA_Percent) || 19,
      Discount_Percent: parseFloat(obj.Discount_Percent) || 0,
      MontantHT: parseFloat(obj.MontantHT) || 0,
      MontantTVA: parseFloat(obj.MontantTVA) || 0,
      MontantTTC: parseFloat(obj.MontantTTC) || 0,
    };
  });
}

// ─── Reference normalisation: "009" → "9", "014" → "14", etc., unless ≥3 digits with leading content ─
function normalizeRef(ref: string): string {
  // Keep original for 3-char+ that aren't padded (like "100", "500")
  const n = parseInt(ref);
  if (isNaN(n)) return ref.toUpperCase();
  // 3-digit refs >= 100 → keep as-is (100, 101, etc.)
  if (n >= 100) return ref;
  // 2/3-digit padded refs (009, 010, 071) → strip zeros
  return String(n);
}

// ─── Detect family from designation ──────────────────────────────────────────
function detectFamily(designation: string): "motos" | "huile" | "casques" {
  const d = designation.toUpperCase();
  if (d.includes("HUILE") || d.includes("OIL")) return "huile";
  if (d.includes("CASQUE")) return "casques";
  return "motos";
}

async function main() {
  console.log("=== Reception Import Script ===\n");

  // ── Read CSV ──
  const csvPath = join(process.cwd(), "attached_assets/deepseek_csv_20260423_b9a6d9_1776959850670.txt");
  const rows = parseCsv(readFileSync(csvPath, "utf8"));
  console.log(`Parsed ${rows.length} CSV rows\n`);

  // ── Step 1: Ensure product families exist ──
  console.log("Step 1: Ensuring product families...");
  const famRows = await sql`SELECT id, name FROM product_families`;
  const famMap: Record<string, number> = {};
  for (const f of famRows) famMap[f.name.toLowerCase()] = f.id;

  for (const famName of ["Motos", "Huile", "Casques"]) {
    if (!famMap[famName.toLowerCase()]) {
      const [created] = await sql`INSERT INTO product_families (name) VALUES (${famName}) RETURNING id`;
      famMap[famName.toLowerCase()] = created.id;
      console.log(`  Created family: ${famName} (id ${created.id})`);
    } else {
      console.log(`  Family exists: ${famName} (id ${famMap[famName.toLowerCase()]})`);
    }
  }

  // ── Step 2: Build product lookup from DB ──
  console.log("\nStep 2: Building product map from DB...");
  const dbProducts = await sql`SELECT id, reference, designation, family_id FROM products`;

  // Build lookup: normalizedRef → best matching product id
  const refToProductId = new Map<string, number>();
  for (const p of dbProducts) {
    const normRef = normalizeRef(p.reference);
    // Prefer the first match; for duplicates, the last one wins (we handle conflicts below)
    refToProductId.set(normRef, p.id);
    // Also keep the raw ref
    refToProductId.set(p.reference, p.id);
  }

  // For refs with multiple products in DB, disambiguate by designation similarity
  const refGroups = new Map<string, typeof dbProducts>();
  for (const p of dbProducts) {
    const normRef = normalizeRef(p.reference);
    if (!refGroups.has(normRef)) refGroups.set(normRef, []);
    refGroups.get(normRef)!.push(p);
  }

  // ── Step 3: Create missing products ──
  console.log("\nStep 3: Ensuring products from CSV exist...");

  // Collect unique (ref, designation) from CSV
  const csvProducts = new Map<string, { designation: string; unitPrice: number; tvaPct: number; family: string }>();
  for (const row of rows) {
    const normRef = normalizeRef(row.Reference);
    if (!csvProducts.has(normRef)) {
      csvProducts.set(normRef, {
        designation: row.Designation,
        unitPrice: row.UnitPrice,
        tvaPct: row.TVA_Percent,
        family: detectFamily(row.Designation),
      });
    }
  }

  for (const [normRef, info] of csvProducts) {
    const group = refGroups.get(normRef) || [];
    
    if (group.length === 0) {
      // No match → create
      const familyId = famMap[info.family];
      const [created] = await sql`
        INSERT INTO products (reference, designation, family_id, default_price, tva_pct)
        VALUES (${normRef}, ${info.designation}, ${familyId}, ${info.unitPrice}, ${info.tvaPct})
        RETURNING id
      `;
      refToProductId.set(normRef, created.id);
      console.log(`  Created product: [${normRef}] ${info.designation}`);
    } else if (group.length === 1) {
      refToProductId.set(normRef, group[0].id);
      console.log(`  Matched product: [${normRef}] ${group[0].designation}`);
    } else {
      // Multiple → pick best by designation similarity
      const csvDesig = info.designation.toUpperCase();
      let best = group[0];
      let bestScore = 0;
      for (const p of group) {
        const words = p.designation.toUpperCase().split(/\s+/);
        const score = words.filter(w => csvDesig.includes(w)).length;
        if (score > bestScore) { bestScore = score; best = p; }
      }
      refToProductId.set(normRef, best.id);
      console.log(`  Multi-match [${normRef}] → picked: ${best.designation} (id ${best.id})`);
    }
  }

  // ── Step 4: Import receptions (skip duplicates) ──
  console.log("\nStep 4: Importing receptions...");
  const existingReceptions = await sql`SELECT bon_number FROM receptions`;
  const existingBons = new Set(existingReceptions.map((r: any) => r.bon_number));

  // Group rows by ReceiptNumber
  const receiptGroups = new Map<string, CsvRow[]>();
  for (const row of rows) {
    if (!receiptGroups.has(row.ReceiptNumber)) receiptGroups.set(row.ReceiptNumber, []);
    receiptGroups.get(row.ReceiptNumber)!.push(row);
  }

  const receptionIdMap = new Map<string, number>(); // bonNumber → reception id

  for (const [bonNumber, lines] of receiptGroups) {
    if (existingBons.has(bonNumber)) {
      // Fetch existing id
      const [existing] = await sql`SELECT id FROM receptions WHERE bon_number = ${bonNumber}`;
      receptionIdMap.set(bonNumber, existing.id);
      console.log(`  Skipped (exists): ${bonNumber}`);
      continue;
    }
    const first = lines[0];
    const [created] = await sql`
      INSERT INTO receptions (bon_number, date, fournisseur)
      VALUES (${bonNumber}, ${first.Date}, ${first.Supplier})
      RETURNING id
    `;
    receptionIdMap.set(bonNumber, created.id);
    console.log(`  Created reception: ${bonNumber} — ${first.Date} — ${first.Supplier}`);
  }

  // ── Step 5: Import reception lines (skip duplicates by reception+product) ──
  console.log("\nStep 5: Importing reception lines...");
  let linesCreated = 0;
  let linesSkipped = 0;

  for (const row of rows) {
    const normRef = normalizeRef(row.Reference);
    const productId = refToProductId.get(normRef);
    const receptionId = receptionIdMap.get(row.ReceiptNumber);

    if (!productId) { console.log(`  WARN: No product for ref ${row.Reference}`); continue; }
    if (!receptionId) { console.log(`  WARN: No reception for ${row.ReceiptNumber}`); continue; }

    // Check if line already exists
    const existing = await sql`
      SELECT id FROM reception_lines
      WHERE reception_id = ${receptionId} AND product_id = ${productId}
    `;
    if (existing.length > 0) { linesSkipped++; continue; }

    // Compute per-line HT/TVA/TTC (from unit price × qty × (1 - discount))
    const ht = row.UnitPrice * row.Quantity * (1 - row.Discount_Percent / 100);
    const tvaAmt = ht * (row.TVA_Percent / 100);

    await sql`
      INSERT INTO reception_lines (reception_id, product_id, quantity, prix, tva_pct, remise)
      VALUES (${receptionId}, ${productId}, ${row.Quantity}, ${row.UnitPrice}, ${row.TVA_Percent}, ${row.Discount_Percent})
    `;
    linesCreated++;
  }
  console.log(`  Lines created: ${linesCreated}, skipped (already exist): ${linesSkipped}`);

  // ── Step 6: Create product_serials for available (unsold) stock ──
  console.log("\nStep 6: Computing available stock and creating placeholder serials...");

  // Total received per product from reception_lines
  const receivedByProduct = await sql`
    SELECT product_id, SUM(quantity)::int AS total_received
    FROM reception_lines
    GROUP BY product_id
  `;

  // Total already in product_serials per product
  const soldByProduct = await sql`
    SELECT product_id, COUNT(*)::int AS total_serials
    FROM product_serials
    GROUP BY product_id
  `;
  const soldMap = new Map<number, number>();
  for (const r of soldByProduct) soldMap.set(r.product_id, r.total_serials);

  let serialsCreated = 0;
  for (const r of receivedByProduct) {
    const pid = r.product_id;
    const received = r.total_received;
    const already = soldMap.get(pid) || 0;
    const toCreate = Math.max(0, received - already);

    if (toCreate > 0) {
      // Get product info for placeholder serial naming
      const [prod] = await sql`SELECT reference, designation FROM products WHERE id = ${pid}`;
      for (let i = 1; i <= toCreate; i++) {
        const placeholder = `STOCK-${prod.reference}-${String(i).padStart(3, "0")}`;
        // Check if already created
        const existCheck = await sql`SELECT id FROM product_serials WHERE serial_number = ${placeholder}`;
        if (existCheck.length > 0) continue;

        await sql`
          INSERT INTO product_serials (product_id, serial_number, purchase_price, status)
          SELECT ${pid}, ${placeholder}, rl.prix, 'available'
          FROM reception_lines rl
          WHERE rl.product_id = ${pid}
          ORDER BY rl.created_at DESC
          LIMIT 1
        `;
        serialsCreated++;
      }
      if (toCreate > 0) console.log(`  [${prod.reference}] ${prod.designation}: +${toCreate} available units`);
    }
  }
  console.log(`  Total available serials created: ${serialsCreated}`);

  // ── Summary ──
  console.log("\n=== Import Complete ===");
  const [rcCount] = await sql`SELECT COUNT(*) FROM receptions`;
  const [rlCount] = await sql`SELECT COUNT(*) FROM reception_lines`;
  const [psCount] = await sql`SELECT COUNT(*) FROM product_serials WHERE status = 'available'`;
  const [pdCount] = await sql`SELECT COUNT(*) FROM product_serials WHERE status = 'delivered'`;
  console.log(`Receptions:        ${rcCount.count}`);
  console.log(`Reception lines:   ${rlCount.count}`);
  console.log(`Available serials: ${psCount.count}`);
  console.log(`Delivered serials: ${pdCount.count}`);

  await sql.end();
}

main().catch(err => { console.error(err); process.exit(1); });
