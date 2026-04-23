import { readFileSync } from "fs";
import { join } from "path";
import postgres from "postgres";

async function isDatabaseEmpty(sql: postgres.Sql): Promise<boolean> {
  const result = await sql`SELECT COUNT(*) as count FROM public.clients`;
  return parseInt(result[0].count) === 0;
}

export async function autoSeedIfEmpty(log: (msg: string, src?: string) => void) {
  const connectionString = process.env.DATABASE_URL!;
  const sql = postgres(connectionString, { max: 1 });

  try {
    const empty = await isDatabaseEmpty(sql);
    if (!empty) {
      log("Database already has data — skipping auto-seed.", "seed");
      return;
    }

    log("Database is empty — seeding with all production data...", "seed");

    const seedPath = join(process.cwd(), "script/seed-data.sql");
    const seedSql = readFileSync(seedPath, "utf8");

    const statements = seedSql
      .split("\n")
      .filter((line) => !line.startsWith("--") && line.trim() !== "")
      .join("\n")
      .split(/;\s*\n/)
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    for (const statement of statements) {
      try {
        await sql.unsafe(statement + ";");
      } catch (err: any) {
        log(`Seed warning: ${err.message}`, "seed");
      }
    }

    log("Database seeded successfully with all production data.", "seed");
  } catch (err: any) {
    log(`Auto-seed error: ${err.message}`, "seed");
  } finally {
    await sql.end();
  }
}
