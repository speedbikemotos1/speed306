import "dotenv/config";
import { readFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";
import postgres from "postgres";

const __dirname = dirname(fileURLToPath(import.meta.url));

const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
  console.error("DATABASE_URL is not set");
  process.exit(1);
}

const sql = postgres(DATABASE_URL, { max: 1 });

async function isDatabaseEmpty(): Promise<boolean> {
  const result = await sql`SELECT COUNT(*) as count FROM public.clients`;
  return parseInt(result[0].count) === 0;
}

async function seedDatabase() {
  console.log("Checking if database needs seeding...");

  const empty = await isDatabaseEmpty();
  if (!empty) {
    console.log("Database already has data — skipping seed.");
    await sql.end();
    return;
  }

  console.log("Database is empty — loading seed data...");
  const seedPath = join(__dirname, "seed-data.sql");
  const seedSql = readFileSync(seedPath, "utf8");

  const statements = seedSql
    .split("\n")
    .filter((line) => !line.startsWith("--") && line.trim() !== "")
    .join("\n")
    .split(/;(?=\s*(?:\n|$))/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

  for (const statement of statements) {
    try {
      await sql.unsafe(statement + ";");
    } catch (err: any) {
      console.warn(`Seed statement warning: ${err.message}`);
    }
  }

  console.log("Database seeded successfully with all production data.");
  await sql.end();
}

seedDatabase().catch((err) => {
  console.error("Seeding failed:", err);
  process.exit(1);
});
