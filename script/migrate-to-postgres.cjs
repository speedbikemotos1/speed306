
/**
 * One-time migration script: SQLite → PostgreSQL
 * Run: node script/migrate-to-postgres.cjs
 */

const Database = require("better-sqlite3");
const path = require("path");
const { Client } = require("pg");
require("dotenv").config();

const sqliteDb = new Database(path.resolve(__dirname, "../data.sqlite"));
const pgClient = new Client({ connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } });

async function migrate() {
  await pgClient.connect();
  console.log("Connected to PostgreSQL");

  // Disable foreign key checks temporarily by using transactions carefully
  await pgClient.query("BEGIN");

  try {
    // ---- USERS ----
    const users = sqliteDb.prepare("SELECT * FROM users").all();
    console.log(`Migrating ${users.length} users...`);
    for (const u of users) {
      await pgClient.query(
        "INSERT INTO users (id, username, role) VALUES ($1, $2, $3) ON CONFLICT (id) DO NOTHING",
        [u.id, u.username, u.role]
      );
    }
    await pgClient.query("SELECT setval('users_id_seq', (SELECT MAX(id) FROM users))");

    // ---- SALES ----
    const sales = sqliteDb.prepare("SELECT * FROM sales").all();
    console.log(`Migrating ${sales.length} sales...`);
    for (const s of sales) {
      let payments = s.payments;
      if (typeof payments === "string") {
        try { payments = JSON.parse(payments); } catch { payments = {}; }
      }
      await pgClient.query(
        `INSERT INTO sales (id, invoice_number, date, designation, client_type, client_name,
          convention_name, chassis_number, registration_number, gray_card_status,
          total_to_pay, advance, payments, payment_day, created_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
         ON CONFLICT (id) DO NOTHING`,
        [s.id, s.invoice_number, s.date, s.designation, s.client_type, s.client_name,
         s.convention_name, s.chassis_number, s.registration_number, s.gray_card_status,
         s.total_to_pay, s.advance, JSON.stringify(payments), s.payment_day, s.created_at]
      );
    }
    await pgClient.query("SELECT setval('sales_id_seq', (SELECT MAX(id) FROM sales))");

    // ---- NOTIFICATIONS ----
    const notifications = sqliteDb.prepare("SELECT * FROM notifications").all();
    console.log(`Migrating ${notifications.length} notifications...`);
    for (const n of notifications) {
      await pgClient.query(
        "INSERT INTO notifications (id, user_id, action, target, details, timestamp) VALUES ($1,$2,$3,$4,$5,$6) ON CONFLICT (id) DO NOTHING",
        [n.id, n.user_id, n.action, n.target, n.details, n.timestamp]
      );
    }
    await pgClient.query("SELECT setval('notifications_id_seq', (SELECT MAX(id) FROM notifications))");

    // ---- USER_NOTIFICATIONS ----
    const userNotifs = sqliteDb.prepare("SELECT * FROM user_notifications").all();
    console.log(`Migrating ${userNotifs.length} user_notifications...`);
    for (const un of userNotifs) {
      await pgClient.query(
        "INSERT INTO user_notifications (id, user_id, notification_id, is_read) VALUES ($1,$2,$3,$4) ON CONFLICT (id) DO NOTHING",
        [un.id, un.user_id, un.notification_id, un.is_read === 1]
      );
    }
    await pgClient.query("SELECT setval('user_notifications_id_seq', (SELECT MAX(id) FROM user_notifications))");

    // ---- CLIENTS ----
    const clients = sqliteDb.prepare("SELECT * FROM clients").all();
    console.log(`Migrating ${clients.length} clients...`);
    for (const c of clients) {
      await pgClient.query(
        `INSERT INTO clients (id, nom_prenom, numero_telephone, numero_telephone_2, email, fax,
          nom_sub_client, adresse, cin, type_company, code_postal, unique_number,
          categorie, famille, civilite, mode_reglement, banque, remarque, created_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19)
         ON CONFLICT (id) DO NOTHING`,
        [c.id, c.nom_prenom, c.numero_telephone, c.numero_telephone_2, c.email, c.fax,
         c.nom_sub_client, c.adresse, c.cin, c.type_company, c.code_postal, c.unique_number,
         c.categorie, c.famille, c.civilite, c.mode_reglement, c.banque, c.remarque, c.created_at]
      );
    }
    await pgClient.query("SELECT setval('clients_id_seq', (SELECT MAX(id) FROM clients))");

    // ---- OIL SALES ----
    const oilSales = sqliteDb.prepare("SELECT * FROM oil_sales").all();
    console.log(`Migrating ${oilSales.length} oil_sales...`);
    for (const o of oilSales) {
      await pgClient.query(
        `INSERT INTO oil_sales (id, date, huile_10w40, huile_20w50, gear_oil, brake_oil,
          prix, encaissement, client, confirmed_by_staff, confirmed_by_manager,
          calculation_timestamp, amount_handed, created_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
         ON CONFLICT (id) DO NOTHING`,
        [o.id, o.date, o.huile_10w40, o.huile_20w50, o.gear_oil, o.brake_oil,
         o.prix, o.encaissement, o.client, o.confirmed_by_staff, o.confirmed_by_manager,
         o.calculation_timestamp, o.amount_handed, o.created_at]
      );
    }
    if (oilSales.length) await pgClient.query("SELECT setval('oil_sales_id_seq', (SELECT MAX(id) FROM oil_sales))");

    // ---- OIL PURCHASES ----
    const oilPurchases = sqliteDb.prepare("SELECT * FROM oil_purchases").all();
    console.log(`Migrating ${oilPurchases.length} oil_purchases...`);
    for (const o of oilPurchases) {
      await pgClient.query(
        "INSERT INTO oil_purchases (id, date, huile_10w40, huile_20w50, gear_oil, brake_oil, fournisseur, prix, created_at) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) ON CONFLICT (id) DO NOTHING",
        [o.id, o.date, o.huile_10w40, o.huile_20w50, o.gear_oil, o.brake_oil, o.fournisseur, o.prix, o.created_at]
      );
    }
    if (oilPurchases.length) await pgClient.query("SELECT setval('oil_purchases_id_seq', (SELECT MAX(id) FROM oil_purchases))");

    // ---- HELMET SALES ----
    const helmetSales = sqliteDb.prepare("SELECT * FROM helmet_sales").all();
    console.log(`Migrating ${helmetSales.length} helmet_sales...`);
    for (const h of helmetSales) {
      await pgClient.query(
        `INSERT INTO helmet_sales (id, numero_facture, date, designation, type_client, nom_prenom,
          quantite, montant, remarque, confirmed_by_staff, confirmed_by_manager,
          calculation_timestamp, amount_handed, created_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
         ON CONFLICT (id) DO NOTHING`,
        [h.id, h.numero_facture, h.date, h.designation, h.type_client, h.nom_prenom,
         h.quantite, h.montant, h.remarque, h.confirmed_by_staff, h.confirmed_by_manager,
         h.calculation_timestamp, h.amount_handed, h.created_at]
      );
    }
    if (helmetSales.length) await pgClient.query("SELECT setval('helmet_sales_id_seq', (SELECT MAX(id) FROM helmet_sales))");

    // ---- HELMET PURCHASES ----
    const helmetPurchases = sqliteDb.prepare("SELECT * FROM helmet_purchases").all();
    console.log(`Migrating ${helmetPurchases.length} helmet_purchases...`);
    for (const h of helmetPurchases) {
      await pgClient.query(
        "INSERT INTO helmet_purchases (id, date, designation, quantite, fournisseur, prix, created_at) VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT (id) DO NOTHING",
        [h.id, h.date, h.designation, h.quantite, h.fournisseur, h.prix, h.created_at]
      );
    }
    if (helmetPurchases.length) await pgClient.query("SELECT setval('helmet_purchases_id_seq', (SELECT MAX(id) FROM helmet_purchases))");

    // ---- SADDLE SALES ----
    const saddleSales = sqliteDb.prepare("SELECT * FROM saddle_sales").all();
    console.log(`Migrating ${saddleSales.length} saddle_sales...`);
    for (const s of saddleSales) {
      await pgClient.query(
        `INSERT INTO saddle_sales (id, date, taille_xl, taille_xxl, prix, encaissement, client,
          confirmed_by_staff, confirmed_by_manager, calculation_timestamp, amount_handed, created_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
         ON CONFLICT (id) DO NOTHING`,
        [s.id, s.date, s.taille_xl, s.taille_xxl, s.prix, s.encaissement, s.client,
         s.confirmed_by_staff, s.confirmed_by_manager, s.calculation_timestamp, s.amount_handed, s.created_at]
      );
    }
    if (saddleSales.length) await pgClient.query("SELECT setval('saddle_sales_id_seq', (SELECT MAX(id) FROM saddle_sales))");

    // ---- SADDLE PURCHASES ----
    const saddlePurchases = sqliteDb.prepare("SELECT * FROM saddle_purchases").all();
    console.log(`Migrating ${saddlePurchases.length} saddle_purchases...`);
    for (const s of saddlePurchases) {
      await pgClient.query(
        "INSERT INTO saddle_purchases (id, date, taille_xl, taille_xxl, fournisseur, prix, created_at) VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT (id) DO NOTHING",
        [s.id, s.date, s.taille_xl, s.taille_xxl, s.fournisseur, s.prix, s.created_at]
      );
    }
    if (saddlePurchases.length) await pgClient.query("SELECT setval('saddle_purchases_id_seq', (SELECT MAX(id) FROM saddle_purchases))");

    // ---- DEFERRED SALES ----
    const deferredSales = sqliteDb.prepare("SELECT * FROM deferred_sales").all();
    console.log(`Migrating ${deferredSales.length} deferred_sales...`);
    for (const d of deferredSales) {
      await pgClient.query(
        `INSERT INTO deferred_sales (id, date, nom_prenom, numero_telephone, type_moto, designation,
          quantite, montant, is_settled, confirmed_by_staff, confirmed_by_manager,
          calculation_timestamp, amount_handed, created_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
         ON CONFLICT (id) DO NOTHING`,
        [d.id, d.date, d.nom_prenom, d.numero_telephone, d.type_moto, d.designation,
         d.quantite, d.montant, d.is_settled === 1, d.confirmed_by_staff, d.confirmed_by_manager,
         d.calculation_timestamp, d.amount_handed, d.created_at]
      );
    }
    if (deferredSales.length) await pgClient.query("SELECT setval('deferred_sales_id_seq', (SELECT MAX(id) FROM deferred_sales))");

    // ---- DIVERS PURCHASES ----
    const diversPurchases = sqliteDb.prepare("SELECT * FROM divers_purchases").all();
    console.log(`Migrating ${diversPurchases.length} divers_purchases...`);
    for (const d of diversPurchases) {
      await pgClient.query(
        "INSERT INTO divers_purchases (id, date, designation, quantite, fournisseur, prix, created_at) VALUES ($1,$2,$3,$4,$5,$6,$7) ON CONFLICT (id) DO NOTHING",
        [d.id, d.date, d.designation, d.quantite, d.fournisseur, d.prix, d.created_at]
      );
    }
    if (diversPurchases.length) await pgClient.query("SELECT setval('divers_purchases_id_seq', (SELECT MAX(id) FROM divers_purchases))");

    await pgClient.query("COMMIT");
    console.log("\n✅ Migration complete! All data migrated to PostgreSQL.");

  } catch (err) {
    await pgClient.query("ROLLBACK");
    console.error("❌ Migration failed, rolled back:", err);
    process.exit(1);
  } finally {
    sqliteDb.close();
    await pgClient.end();
  }
}

migrate().catch(console.error);
