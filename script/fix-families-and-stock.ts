import "dotenv/config";
import postgres from "postgres";

const sql = postgres(process.env.DATABASE_URL!, { max: 1 });

async function main() {
  console.log("=== Fix: Families + Stock Duplicates ===\n");

  // ─── Step 1: Set up correct product families ───────────────────────────────
  console.log("Step 1: Rebuilding product families...");

  // Rename "Motos" → "Pista" (id 1), "Huile" stays (id 2), "Casques" stays (id 3)
  await sql`UPDATE product_families SET name = 'Pista' WHERE id = 1`;
  console.log("  Renamed family 1 → Pista");

  // Create Spring, Ghost, Blaster, Forza if not exist
  const familyNames = ["Spring", "Ghost", "Blaster", "Forza"];
  const famMap: Record<string, number> = { Pista: 1, Huile: 2, Casques: 3 };

  const existing = await sql`SELECT id, name FROM product_families`;
  for (const f of existing) famMap[f.name] = f.id;

  for (const name of familyNames) {
    if (!famMap[name]) {
      const [r] = await sql`INSERT INTO product_families (name) VALUES (${name}) RETURNING id`;
      famMap[name] = r.id;
      console.log(`  Created family: ${name} (id ${r.id})`);
    } else {
      console.log(`  Family exists: ${name} (id ${famMap[name]})`);
    }
  }

  // ─── Step 2: Assign every product to the correct family ───────────────────
  console.log("\nStep 2: Reassigning products to correct families...");

  const products = await sql`SELECT id, designation, reference FROM products`;
  let updated = 0;

  for (const p of products) {
    const d = p.designation.toUpperCase();
    let targetFam: number;

    if (d.includes("PISTA")) targetFam = famMap["Pista"];
    else if (d.includes("SPRING")) targetFam = famMap["Spring"];
    else if (d.includes("GHOST")) targetFam = famMap["Ghost"];
    else if (d.includes("BLASTER")) targetFam = famMap["Blaster"];
    else if (d.includes("FORZA")) targetFam = famMap["Forza"];
    else if (d.includes("HUILE") || d.includes("OIL")) targetFam = famMap["Huile"];
    else if (d.includes("CASQUE") || p.reference.startsWith("9") || p.reference === "666A") targetFam = famMap["Casques"];
    else targetFam = famMap["Pista"]; // Fallback

    await sql`UPDATE products SET family_id = ${targetFam} WHERE id = ${p.id}`;
    updated++;
  }
  console.log(`  Updated ${updated} products`);

  // ─── Step 3: Merge duplicate products ─────────────────────────────────────
  console.log("\nStep 3: Merging duplicate products...");

  // (from_id → to_id) pairs where "from" is the orphan and "to" is the canonical
  const mergePairs: [number, number][] = [
    [42, 31],   // SPRING BLEU FONCE: ref "54" → ref "054"
    [41, 32],   // SPRING VERT: ref "55" → ref "055"
    [45, 32],   // SPRING VERT + Casque TNL: ref "55" → ref "055"
    [44, 38],   // PISTA HR NOIR/GRIS: ref "16" → ref "016"
    [50, 53],   // PISTA HR+ BLEU BEIGE: ref "20" → ref "20" (124cc)
    [48, 54],   // PISTA HR+ ROUGE NOIRE: ref "21" → ref "21" (124cc)
    [47, 59],   // PISTA HR+ VERT MARRON: ref "14" → ref "14" (124cc)
    [49, 52],   // PISTA HR+ NOIR ROUGE: ref "15" → ref "15" (124cc)
    [33, 43],   // PISTA HR CARBON: ref "014" → ref "14"
  ];

  for (const [fromId, toId] of mergePairs) {
    const [from] = await sql`SELECT reference, designation FROM products WHERE id = ${fromId}`;
    const [to] = await sql`SELECT reference, designation FROM products WHERE id = ${toId}`;
    if (!from || !to) { console.log(`  SKIP: product ${fromId} or ${toId} not found`); continue; }

    // Move product_serials
    const { count: serialsMoved } = await sql`
      UPDATE product_serials SET product_id = ${toId} WHERE product_id = ${fromId}
    `.then(r => ({ count: r.count }));

    // Move reception_lines
    const { count: rlMoved } = await sql`
      UPDATE reception_lines SET product_id = ${toId} WHERE product_id = ${fromId}
    `.then(r => ({ count: r.count }));

    // Move livraison_lines product_id
    const { count: llMoved } = await sql`
      UPDATE livraison_lines SET product_id = ${toId} WHERE product_id = ${fromId}
    `.then(r => ({ count: r.count }));

    // Delete the orphan product
    await sql`DELETE FROM products WHERE id = ${fromId}`;

    console.log(`  Merged [${from.reference}] ${from.designation} (id ${fromId}) → [${to.reference}] ${to.designation} (id ${toId})`);
    console.log(`    Moved: ${serialsMoved} serials, ${rlMoved} reception lines, ${llMoved} livraison lines`);
  }

  // ─── Step 4: Remove now-unused placeholder available serials ──────────────
  // For each product, recalculate how many 'available' serials are correct
  console.log("\nStep 4: Fixing available serial counts...");

  // Get received per product from reception_lines
  const received = await sql`
    SELECT product_id, SUM(quantity)::int AS qty
    FROM reception_lines GROUP BY product_id
  `;
  const receivedMap = new Map<number, number>(received.map((r: any) => [r.product_id, r.qty]));

  // Get sold per product
  const sold = await sql`
    SELECT product_id, COUNT(*)::int AS qty
    FROM product_serials WHERE status = 'delivered' GROUP BY product_id
  `;
  const soldMap = new Map<number, number>(sold.map((r: any) => [r.product_id, r.qty]));

  // Get current available per product
  const avail = await sql`
    SELECT product_id, COUNT(*)::int AS qty, array_agg(id ORDER BY id DESC) AS ids
    FROM product_serials WHERE status = 'available' GROUP BY product_id
  `;

  let totalRemoved = 0;
  let totalAdded = 0;

  for (const a of avail) {
    const pid = a.product_id;
    const rcv = receivedMap.get(pid) || 0;
    const sld = soldMap.get(pid) || 0;
    const shouldBeAvail = Math.max(0, rcv - sld);
    const currentAvail = a.qty;
    const diff = currentAvail - shouldBeAvail;

    if (diff > 0) {
      // Too many available serials → remove excess (the placeholder STOCK-* ones)
      const idsToRemove = a.ids.slice(0, diff);
      await sql`DELETE FROM product_serials WHERE id = ANY(${idsToRemove}::int[])`;
      totalRemoved += diff;
      console.log(`  [id ${pid}] reduced available: ${currentAvail} → ${shouldBeAvail} (-${diff})`);
    } else if (diff < 0) {
      // Too few → add placeholder serials
      const [prod] = await sql`SELECT reference FROM products WHERE id = ${pid}`;
      if (!prod) continue;
      const toAdd = Math.abs(diff);
      // Find the next N for this product
      const [maxN] = await sql`
        SELECT COALESCE(MAX(CAST(SUBSTRING(serial_number FROM '[0-9]+$') AS INT)), 0) AS n
        FROM product_serials
        WHERE product_id = ${pid} AND serial_number LIKE 'STOCK-%'
      `;
      let startN = (maxN?.n || 0) + 1;
      for (let i = 0; i < toAdd; i++) {
        const sn = `STOCK-${prod.reference}-${String(startN + i).padStart(3, "0")}`;
        const [priceSrc] = await sql`
          SELECT prix FROM reception_lines WHERE product_id = ${pid} ORDER BY created_at DESC LIMIT 1
        `;
        await sql`
          INSERT INTO product_serials (product_id, serial_number, purchase_price, status)
          VALUES (${pid}, ${sn}, ${priceSrc?.prix || 0}, 'available')
        `;
      }
      totalAdded += toAdd;
      console.log(`  [id ${pid}] increased available: ${currentAvail} → ${shouldBeAvail} (+${toAdd})`);
    }
  }
  console.log(`  Total: removed ${totalRemoved} excess serials, added ${totalAdded} missing serials`);

  // ─── Final summary ─────────────────────────────────────────────────────────
  console.log("\n=== Final Summary ===");
  const families = await sql`SELECT id, name FROM product_families ORDER BY id`;
  console.log("\nFamilies:");
  for (const f of families) {
    const [cnt] = await sql`SELECT COUNT(*)::int AS c FROM products WHERE family_id = ${f.id}`;
    console.log(`  [${f.id}] ${f.name}: ${cnt.c} products`);
  }

  const [pCnt] = await sql`SELECT COUNT(*) FROM products`;
  const [avlCnt] = await sql`SELECT COUNT(*) FROM product_serials WHERE status='available'`;
  const [dlvCnt] = await sql`SELECT COUNT(*) FROM product_serials WHERE status='delivered'`;
  console.log(`\nProducts: ${pCnt.count}`);
  console.log(`Available serials: ${avlCnt.count}`);
  console.log(`Delivered serials: ${dlvCnt.count}`);

  await sql.end();
}

main().catch(err => { console.error(err); process.exit(1); });
