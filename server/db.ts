
import postgres from "postgres";
import { drizzle } from "drizzle-orm/postgres-js";
import * as schema from "@shared/schema";

// In production, use the Supabase database URL if available
const connectionString =
  process.env.SUPABASE_DATABASE_URL || process.env.DATABASE_URL!;

const sslMode = process.env.SUPABASE_DATABASE_URL ? "require" : false;

const client = postgres(connectionString, {
  ssl: sslMode,
});
export const db = drizzle(client, { schema });

// Run any pending schema migrations that drizzle-kit can't apply remotely
export async function runMigrations() {
  const raw = postgres(connectionString, { ssl: sslMode, max: 1 });
  try {
    // Add dismissed column to user_notifications if it doesn't exist
    await raw`
      ALTER TABLE user_notifications
      ADD COLUMN IF NOT EXISTS dismissed BOOLEAN NOT NULL DEFAULT FALSE
    `;
    // Create product_prices table if it doesn't exist
    await raw`
      CREATE TABLE IF NOT EXISTS product_prices (
        id SERIAL PRIMARY KEY,
        number INTEGER NOT NULL,
        designation TEXT NOT NULL,
        prix_vente_ttc DOUBLE PRECISION NOT NULL
      )
    `;

    // New motorcycle stock module tables
    await raw`
      CREATE TABLE IF NOT EXISTS product_families (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
      )
    `;
    await raw`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        reference TEXT NOT NULL,
        designation TEXT NOT NULL,
        family_id INTEGER,
        default_price DOUBLE PRECISION DEFAULT 0,
        tva_pct DOUBLE PRECISION DEFAULT 19,
        created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
      )
    `;
    await raw`
      CREATE TABLE IF NOT EXISTS product_serials (
        id SERIAL PRIMARY KEY,
        product_id INTEGER NOT NULL,
        serial_number TEXT NOT NULL,
        purchase_price DOUBLE PRECISION DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'available',
        reception_id INTEGER,
        livraison_id INTEGER,
        created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
      )
    `;
    await raw`
      CREATE TABLE IF NOT EXISTS receptions (
        id SERIAL PRIMARY KEY,
        bon_number TEXT NOT NULL,
        date TEXT NOT NULL,
        fournisseur TEXT NOT NULL DEFAULT '',
        created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
      )
    `;
    await raw`
      CREATE TABLE IF NOT EXISTS reception_lines (
        id SERIAL PRIMARY KEY,
        reception_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        prix DOUBLE PRECISION NOT NULL DEFAULT 0,
        tva_pct DOUBLE PRECISION NOT NULL DEFAULT 19,
        remise DOUBLE PRECISION NOT NULL DEFAULT 0,
        created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
      )
    `;
    await raw`
      CREATE TABLE IF NOT EXISTS livraisons (
        id SERIAL PRIMARY KEY,
        bon_number TEXT NOT NULL,
        date TEXT NOT NULL,
        commercial TEXT NOT NULL DEFAULT '',
        client_id INTEGER,
        client_name TEXT NOT NULL DEFAULT '',
        id_client TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'draft',
        created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
      )
    `;
    await raw`
      CREATE TABLE IF NOT EXISTS livraison_lines (
        id SERIAL PRIMARY KEY,
        livraison_id INTEGER NOT NULL,
        product_serial_id INTEGER,
        product_id INTEGER,
        ref TEXT NOT NULL DEFAULT '',
        designation TEXT NOT NULL DEFAULT '',
        serial_number TEXT NOT NULL DEFAULT '',
        prix DOUBLE PRECISION NOT NULL DEFAULT 0,
        tva_pct DOUBLE PRECISION NOT NULL DEFAULT 19,
        remise DOUBLE PRECISION NOT NULL DEFAULT 0,
        prix_ttc DOUBLE PRECISION NOT NULL DEFAULT 0,
        montant_ht DOUBLE PRECISION NOT NULL DEFAULT 0,
        montant_tva DOUBLE PRECISION NOT NULL DEFAULT 0,
        montant_ttc DOUBLE PRECISION NOT NULL DEFAULT 0,
        created_at BIGINT DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT * 1000
      )
    `;

    // Add phoneClient column to facture_lines
    await raw`
      ALTER TABLE facture_lines
      ADD COLUMN IF NOT EXISTS phone_client TEXT NOT NULL DEFAULT ''
    `;

    console.log("[migrations] Schema is up to date.");
  } catch (err: any) {
    console.error("[migrations] Warning:", err.message);
  } finally {
    await raw.end();
  }

}
