import "dotenv/config";
import postgres from "postgres";
import { readFileSync } from "fs";
import { join } from "path";

const sql = postgres(process.env.DATABASE_URL!, { max: 1 });

type CsvRow = {
  ReceiptNumber: string; Date: string; Supplier: string; InvoiceNumber: string;
  Reference: string; Designation: string; Quantity: number; UnitPrice: number;
  TVA_Percent: number; Discount_Percent: number; UnitIndex: string; serial_number: string;
};

function parseCsv(content: string): CsvRow[] {
  const lines = content.trim().split("\n");
  const headers = lines[0].split(",");
  return lines.slice(1).map(line => {
    const values: string[] = [];
    let cur = ""; let inQ = false;
    for (const ch of line) {
      if (ch === '"') inQ = !inQ;
      else if (ch === "," && !inQ) { values.push(cur.trim()); cur = ""; }
      else cur += ch;
    }
    values.push(cur.trim());
    const o: any = {};
    headers.forEach((h, i) => { o[h.trim()] = (values[i] ?? "").trim(); });
    return {
      ReceiptNumber: o.ReceiptNumber, Date: o.Date, Supplier: o.Supplier,
      InvoiceNumber: o.InvoiceNumber, Reference: o.Reference, Designation: o.Designation,
      Quantity: parseInt(o.Quantity) || 1, UnitPrice: parseFloat(o.UnitPrice) || 0,
      TVA_Percent: parseFloat(o.TVA_Percent) || 19,
      Discount_Percent: parseFloat(o.Discount_Percent) || 0,
      UnitIndex: o.UnitIndex || "", serial_number: o.serial_number || "",
    };
  });
}

function normRef(ref: string): string {
  const n = parseInt(ref);
  if (isNaN(n)) return ref.toUpperCase();
  return String(n); // strip leading zeros always
}

function detectFamily(desig: string, famMap: Record<string, number>): number {
  const d = desig.toUpperCase();
  if (d.includes("PISTA")) return famMap["Pista"] || 1;
  if (d.includes("SPRING")) return famMap["Spring"] || 4;
  if (d.includes("GHOST")) return famMap["Ghost"] || 5;
  if (d.includes("BLASTER")) return famMap["Blaster"] || 6;
  if (d.includes("FORZA")) return famMap["Forza"] || 7;
  if (d.includes("HUILE") || d.includes("OIL")) return famMap["Huile"] || 2;
  if (d.includes("CASQUE")) return famMap["Casques"] || 3;
  return 1;
}

async function main() {
  console.log("=== Full Serial Re-Import ===\n");
  const csvPath = join(process.cwd(), "attached_assets/deepseek_csv_20260424_b8be24_1777043416878.txt");
  const rows = parseCsv(readFileSync(csvPath, "utf8"));
  console.log(`Parsed ${rows.length} CSV rows\n`);

  // ── Family map ──
  const fams = await sql`SELECT id, name FROM product_families`;
  const famMap: Record<string, number> = {};
  for (const f of fams) famMap[f.name] = f.id;

  // ── Build product lookup ──
  const dbProducts = await sql`SELECT id, reference, designation FROM products`;
  const refToId = new Map<string, number>();
  for (const p of dbProducts) {
    const nr = normRef(p.reference);
    if (!refToId.has(nr)) refToId.set(nr, p.id);
    refToId.set(p.reference, p.id); // also keep raw
  }

  // ── Step 1: Ensure all products exist ──
  console.log("Step 1: Ensuring products...");
  const csvProds = new Map<string, { desig: string; price: number; tva: number }>();
  for (const r of rows) {
    const nr = normRef(r.Reference);
    if (!csvProds.has(nr)) csvProds.set(nr, { desig: r.Designation, price: r.UnitPrice, tva: r.TVA_Percent });
  }
  for (const [nr, info] of csvProds) {
    if (!refToId.has(nr)) {
      const famId = detectFamily(info.desig, famMap);
      const [created] = await sql`
        INSERT INTO products (reference, designation, family_id, default_price, tva_pct)
        VALUES (${nr}, ${info.desig}, ${famId}, ${info.price}, ${info.tva})
        RETURNING id
      `;
      refToId.set(nr, created.id);
      console.log(`  Created product [${nr}] ${info.desig}`);
    }
  }

  // ── Step 2: Fix 26/ reception numbering ──
  // Old DB has 26/000001-26/000006 but they should be 26/000002-26/000007
  // The new CSV adds 26/000001 (13/01/2026) as the real first 26/ bon
  console.log("\nStep 2: Renumbering 26/ bons...");

  // Rename in reverse order to avoid unique conflicts, using temp names first
  const renames26 = [
    ["26/000006", "26/T000007"],
    ["26/000005", "26/T000006"],
    ["26/000004", "26/T000005"],
    ["26/000003", "26/T000004"],
    ["26/000002", "26/T000003"],
    ["26/000001", "26/T000002"],
  ];
  const finalRenames26 = [
    ["26/T000007", "26/000007"],
    ["26/T000006", "26/000006"],
    ["26/T000005", "26/000005"],
    ["26/T000004", "26/000004"],
    ["26/T000003", "26/000003"],
    ["26/T000002", "26/000002"],
  ];

  for (const [from, to] of renames26) {
    const res = await sql`UPDATE receptions SET bon_number = ${to} WHERE bon_number = ${from}`;
    if (res.count > 0) console.log(`  Renamed ${from} → ${to}`);
  }
  for (const [from, to] of finalRenames26) {
    const res = await sql`UPDATE receptions SET bon_number = ${to} WHERE bon_number = ${from}`;
    if (res.count > 0) console.log(`  Finalized ${from} → ${to}`);
  }

  // ── Step 3: Delete all placeholder STOCK-* serials ──
  console.log("\nStep 3: Removing placeholder serials...");
  const del = await sql`DELETE FROM product_serials WHERE serial_number LIKE 'STOCK-%'`;
  console.log(`  Deleted ${del.count} placeholder serials`);

  // ── Step 4: Delete all existing reception_lines ──
  console.log("\nStep 4: Clearing reception lines...");
  const delLines = await sql`DELETE FROM reception_lines`;
  console.log(`  Deleted ${delLines.count} old reception lines`);

  // ── Step 5: Ensure all receptions exist ──
  console.log("\nStep 5: Creating/updating receptions...");
  const bonGroups = new Map<string, { date: string; supplier: string }>();
  for (const r of rows) {
    if (!bonGroups.has(r.ReceiptNumber)) {
      bonGroups.set(r.ReceiptNumber, { date: r.Date, supplier: r.Supplier });
    }
  }
  const receptionIdMap = new Map<string, number>();
  for (const [bon, info] of bonGroups) {
    const existing = await sql`SELECT id FROM receptions WHERE bon_number = ${bon}`;
    if (existing.length > 0) {
      // Update date/supplier from CSV
      await sql`UPDATE receptions SET date = ${info.date}, fournisseur = ${info.supplier} WHERE bon_number = ${bon}`;
      receptionIdMap.set(bon, existing[0].id);
      console.log(`  Updated: ${bon} (${info.date})`);
    } else {
      const [created] = await sql`
        INSERT INTO receptions (bon_number, date, fournisseur) VALUES (${bon}, ${info.date}, ${info.supplier}) RETURNING id
      `;
      receptionIdMap.set(bon, created.id);
      console.log(`  Created: ${bon} (${info.date}) — ${info.supplier}`);
    }
  }

  // ── Step 6: Build livraison serial index for cross-reference ──
  console.log("\nStep 6: Indexing livraison serials...");
  const livraisonSerials = await sql`
    SELECT ll.serial_number, ll.product_id, ll.livraison_id
    FROM livraison_lines ll
    WHERE ll.serial_number IS NOT NULL AND ll.serial_number != ''
  `;
  const livSerialSet = new Set(livraisonSerials.map((r: any) => r.serial_number.trim().toUpperCase()));
  console.log(`  Found ${livSerialSet.size} serials in livraisons`);

  // ── Step 7: Process each CSV row ──
  console.log("\nStep 7: Importing serials and reception lines...");

  // Group by (bon, normalizedRef) for reception_lines, and process serials
  type LineGroup = { productId: number; prix: number; tva: number; remise: number; qty: number };
  const lineGroups = new Map<string, LineGroup>();

  // Build existing serial lookup (delivered ones from backup)
  const existingSerials = await sql`
    SELECT id, serial_number, product_id, status FROM product_serials
  `;
  const existSerialMap = new Map<string, { id: number; productId: number; status: string }>();
  for (const s of existingSerials) {
    existSerialMap.set(s.serial_number.trim().toUpperCase(), { id: s.id, productId: s.product_id, status: s.status });
  }

  let serialsCreated = 0; let serialsUpdated = 0; let serialsSkipped = 0;

  for (const row of rows) {
    const nr = normRef(row.Reference);
    const productId = refToId.get(nr);
    const receptionId = receptionIdMap.get(row.ReceiptNumber);
    if (!productId || !receptionId) { console.log(`  WARN: missing product [${nr}] or reception [${row.ReceiptNumber}]`); continue; }

    // Aggregate reception_lines
    const lineKey = `${receptionId}:${productId}`;
    if (!lineGroups.has(lineKey)) {
      lineGroups.set(lineKey, { productId, prix: row.UnitPrice, tva: row.TVA_Percent, remise: row.Discount_Percent, qty: 0 });
    }
    const lg = lineGroups.get(lineKey)!;
    // Each row = 1 unit (even if Quantity field says otherwise for grouped items like helmets)
    if (row.UnitIndex) {
      lg.qty += 1; // each UnitIndex row = 1 unit
    } else {
      lg.qty += row.Quantity; // oil/bulk items: use Quantity field
    }

    // Process serial if present
    if (!row.serial_number) continue;

    const sn = row.serial_number.trim();
    const snUp = sn.toUpperCase();
    const isDelivered = livSerialSet.has(snUp);
    const status = isDelivered ? "delivered" : "available";

    const existing = existSerialMap.get(snUp);
    if (existing) {
      // Serial already in DB — ensure product_id and reception_id are correct
      if (existing.productId !== productId || existing.status !== status) {
        await sql`
          UPDATE product_serials SET product_id = ${productId}, reception_id = ${receptionId}, status = ${status}
          WHERE id = ${existing.id}
        `;
        serialsUpdated++;
      } else {
        // Just ensure reception_id is set
        await sql`UPDATE product_serials SET reception_id = ${receptionId} WHERE id = ${existing.id}`;
        serialsSkipped++;
      }
    } else {
      // New serial not yet in DB
      await sql`
        INSERT INTO product_serials (product_id, serial_number, purchase_price, status, reception_id)
        VALUES (${productId}, ${sn}, ${row.UnitPrice}, ${status}, ${receptionId})
      `;
      existSerialMap.set(snUp, { id: 0, productId, status });
      serialsCreated++;
    }
  }
  console.log(`  Serials: created=${serialsCreated}, updated=${serialsUpdated}, linked=${serialsSkipped}`);

  // ── Step 8: Insert reception_lines ──
  console.log("\nStep 8: Inserting reception lines...");
  let linesCreated = 0;
  for (const [key, lg] of lineGroups) {
    const [receptionId] = key.split(":").map(Number);
    await sql`
      INSERT INTO reception_lines (reception_id, product_id, quantity, prix, tva_pct, remise)
      VALUES (${receptionId}, ${lg.productId}, ${lg.qty}, ${lg.prix}, ${lg.tva}, ${lg.remise})
    `;
    linesCreated++;
  }
  console.log(`  Created ${linesCreated} reception lines`);

  // ── Step 9: Cross-reference — check serials in livraisons not yet matched in CSV ──
  console.log("\nStep 9: Cross-reference with livraisons...");

  // Find any delivered serials in the DB that don't have a reception_id (historical pre-CSV sales)
  const orphanDelivered = await sql`
    SELECT ps.id, ps.serial_number, ps.product_id
    FROM product_serials ps
    WHERE ps.status = 'delivered' AND ps.reception_id IS NULL
  `;
  console.log(`  ${orphanDelivered.length} delivered serials without reception (pre-CSV sales)`);

  // Find livraison serials that should be in the CSV (delivered but might be marked as available in DB)
  const wrongStatus = await sql`
    SELECT ps.id, ps.serial_number, p.reference, p.designation
    FROM product_serials ps
    JOIN products p ON p.id = ps.product_id
    WHERE ps.status = 'available'
    AND UPPER(ps.serial_number) IN (
      SELECT UPPER(ll.serial_number) FROM livraison_lines ll
      WHERE ll.serial_number IS NOT NULL AND ll.serial_number != ''
    )
  `;
  if (wrongStatus.length > 0) {
    console.log(`  Fixing ${wrongStatus.length} serials that are 'available' but appear in livraisons:`);
    for (const s of wrongStatus) {
      await sql`UPDATE product_serials SET status = 'delivered' WHERE id = ${s.id}`;
      console.log(`    Fixed: [${s.reference}] ${s.serial_number}`);
    }
  }

  // Find livraison serials NOT in product_serials at all (need to create them)
  const missingFromStock = await sql`
    SELECT DISTINCT ll.serial_number, ll.ref, ll.designation, ll.product_id
    FROM livraison_lines ll
    WHERE ll.serial_number IS NOT NULL AND ll.serial_number != ''
    AND NOT EXISTS (
      SELECT 1 FROM product_serials ps WHERE UPPER(ps.serial_number) = UPPER(ll.serial_number)
    )
  `;
  if (missingFromStock.length > 0) {
    console.log(`  Creating ${missingFromStock.length} missing delivered serials (sold before CSV tracking):`);
    for (const s of missingFromStock) {
      const pid = s.product_id || refToId.get(normRef(s.ref));
      if (!pid) { console.log(`    WARN: no product for ref ${s.ref}`); continue; }
      await sql`
        INSERT INTO product_serials (product_id, serial_number, purchase_price, status)
        VALUES (${pid}, ${s.serial_number}, 0, 'delivered')
        ON CONFLICT DO NOTHING
      `;
      console.log(`    Created delivered: ${s.serial_number} [${s.ref}]`);
    }
  }

  // ── Final summary ──
  console.log("\n=== Summary ===");
  const [rcCount] = await sql`SELECT COUNT(*) FROM receptions`;
  const [rlCount] = await sql`SELECT COUNT(*) FROM reception_lines`;
  const [avlCount] = await sql`SELECT COUNT(*) FROM product_serials WHERE status='available'`;
  const [dlvCount] = await sql`SELECT COUNT(*) FROM product_serials WHERE status='delivered'`;
  const [prodCount] = await sql`SELECT COUNT(*) FROM products`;
  console.log(`Products:          ${prodCount.count}`);
  console.log(`Receptions:        ${rcCount.count}`);
  console.log(`Reception lines:   ${rlCount.count}`);
  console.log(`Available serials: ${avlCount.count}`);
  console.log(`Delivered serials: ${dlvCount.count}`);

  // Print stock status per product
  console.log("\n=== Stock per product ===");
  const stockSummary = await sql`
    SELECT p.reference, f.name as family, p.designation,
      COALESCE(rec.qty,0) as received,
      COALESCE(sold.qty,0) as sold,
      COALESCE(avl.qty,0) as available
    FROM products p
    JOIN product_families f ON f.id = p.family_id
    LEFT JOIN (SELECT product_id, SUM(quantity)::int AS qty FROM reception_lines GROUP BY product_id) rec ON rec.product_id = p.id
    LEFT JOIN (SELECT product_id, COUNT(*)::int AS qty FROM product_serials WHERE status='delivered' GROUP BY product_id) sold ON sold.product_id = p.id
    LEFT JOIN (SELECT product_id, COUNT(*)::int AS qty FROM product_serials WHERE status='available' GROUP BY product_id) avl ON avl.product_id = p.id
    WHERE rec.qty > 0 OR sold.qty > 0
    ORDER BY f.name, p.reference
  `;
  for (const s of stockSummary) {
    const net = s.received - s.sold - s.available;
    const flag = net !== 0 ? ` ⚠ untracked: ${net}` : "";
    console.log(`  [${s.family}] ${s.reference} ${s.designation}: rcv=${s.received} sold=${s.sold} avail=${s.available}${flag}`);
  }

  await sql.end();
}

main().catch(err => { console.error(err); process.exit(1); });
