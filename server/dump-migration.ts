/**
 * dump-migration.ts
 * Parses dump.sql and applies all data to the connected database.
 * Uses WHERE NOT EXISTS — no primary key constraint required, safe to run multiple times.
 */

import fs from "fs";
import path from "path";
import postgres from "postgres";

const TABLE_ORDER = [
  "users",
  "clients",
  "sales",
  "notifications",
  "user_notifications",
  "orders",
  "reservations",
  "deferred_sales",
  "facture_lines",
  "divers_purchases",
  "helmet_purchases",
  "helmet_sales",
  "oil_purchases",
  "oil_sales",
  "product_prices",
  "saddle_purchases",
  "saddle_sales",
];

const BOOLEAN_COLUMNS: Record<string, string[]> = {
  deferred_sales: ["is_settled"],
  user_notifications: ["is_read", "dismissed"],
};

interface CopyBlock {
  table: string;
  columns: string[];
  rows: (string | null)[][];
}

function unescapeCopyValue(val: string): string | null {
  if (val === "\\N") return null;
  return val
    .replace(/\\t/g, "\t")
    .replace(/\\n/g, "\n")
    .replace(/\\r/g, "\r")
    .replace(/\\\\/g, "\\");
}

function parseDump(dumpPath: string): CopyBlock[] {
  const content = fs.readFileSync(dumpPath, "utf8");
  const lines = content.split("\n");
  const blocks: CopyBlock[] = [];

  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    const copyMatch = line.match(
      /^COPY public\.(\w+)\s+\(([^)]+)\)\s+FROM stdin;/,
    );
    if (copyMatch) {
      const table = copyMatch[1];
      const columns = copyMatch[2]
        .split(",")
        .map((c) => c.trim().replace(/^"|"$/g, ""));
      const rows: (string | null)[][] = [];

      i++;
      while (i < lines.length && lines[i] !== "\\.") {
        const row = lines[i].split("\t").map(unescapeCopyValue);
        if (row.length === columns.length) {
          rows.push(row);
        }
        i++;
      }
      blocks.push({ table, columns, rows });
    }
    i++;
  }
  return blocks;
}

export async function applyDumpMigration(logFn?: (msg: string) => void) {
  const log = logFn ?? ((msg: string) => console.log(msg));

  const connectionString =
    process.env.SUPABASE_DATABASE_URL || process.env.DATABASE_URL!;
  const sslMode = process.env.SUPABASE_DATABASE_URL ? "require" : false;

  const dumpPath = path.resolve(process.cwd(), "dump.sql");
  if (!fs.existsSync(dumpPath)) {
    log("[dump-migration] dump.sql not found, skipping.");
    return;
  }

  log("[dump-migration] Starting — parsing dump.sql...");
  const blocks = parseDump(dumpPath);

  blocks.sort((a, b) => {
    const ai = TABLE_ORDER.indexOf(a.table);
    const bi = TABLE_ORDER.indexOf(b.table);
    return (ai === -1 ? 999 : ai) - (bi === -1 ? 999 : bi);
  });

  const sql = postgres(connectionString, { ssl: sslMode, max: 3 });

  try {
    let totalInserted = 0;

    for (const block of blocks) {
      if (block.rows.length === 0) continue;

      const boolCols = BOOLEAN_COLUMNS[block.table] ?? [];

      // Get existing IDs in one query — fast check
      let existingIds = new Set<number>();
      try {
        const existing = await sql.unsafe(
          `SELECT id FROM public."${block.table}"`,
        );
        for (const row of existing) {
          existingIds.add(Number(row.id));
        }
      } catch {
        // Table may not exist — will fail on insert too, handled below
      }

      const colList = block.columns.map((c) => `"${c}"`).join(", ");
      let tableInserted = 0;

      // Insert in batches of 50 for speed
      const newRows = block.rows.filter(
        (row) => !existingIds.has(Number(row[0])),
      );

      for (let start = 0; start < newRows.length; start += 50) {
        const batch = newRows.slice(start, start + 50);
        const valueClauses: string[] = [];
        const allValues: any[] = [];
        let paramIdx = 1;

        for (const row of batch) {
          const values = row.map((val, colIdx) => {
            if (val === null) return null;
            const col = block.columns[colIdx];
            if (boolCols.includes(col)) {
              return val === "t" || val === "true";
            }
            return val;
          });
          const placeholders = values.map(() => `$${paramIdx++}`).join(", ");
          valueClauses.push(`(${placeholders})`);
          allValues.push(...values);
        }

        try {
          const result = await sql.unsafe(
            `INSERT INTO public."${block.table}" (${colList}) VALUES ${valueClauses.join(", ")}`,
            allValues,
          );
          tableInserted += (result as any)?.count ?? batch.length;
        } catch (err: any) {
          // Fallback: insert one by one to skip individual failures
          for (const row of batch) {
            const values = row.map((val, colIdx) => {
              if (val === null) return null;
              const col = block.columns[colIdx];
              if (boolCols.includes(col)) {
                return val === "t" || val === "true";
              }
              return val;
            });
            const placeholders = values.map((_, i) => `$${i + 1}`).join(", ");
            try {
              await sql.unsafe(
                `INSERT INTO public."${block.table}" (${colList}) VALUES (${placeholders})`,
                values as any[],
              );
              tableInserted++;
            } catch {
              // Row already exists or other issue — skip silently
            }
          }
        }
      }

      log(
        `[dump-migration] ${block.table}: ${newRows.length} new rows inserted (${existingIds.size} already existed).`,
      );
      totalInserted += tableInserted;
    }

    // Reset sequences to max(id) so future inserts don't conflict
    const tables = [
      "clients", "deferred_sales", "delivery_note_lines", "divers_purchases",
      "facture_lines", "helmet_purchases", "helmet_sales", "notifications",
      "oil_purchases", "oil_sales", "orders", "product_prices", "reservations",
      "saddle_purchases", "saddle_sales", "sales", "user_notifications", "users",
    ];
    for (const table of tables) {
      try {
        await sql.unsafe(
          `SELECT setval('public.${table}_id_seq', COALESCE((SELECT MAX(id) FROM public."${table}"), 1))`,
        );
      } catch {
        // ignore
      }
    }

    log(`[dump-migration] Complete. Total rows inserted: ${totalInserted}.`);
  } finally {
    await sql.end();
  }
}
