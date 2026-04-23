import "dotenv/config";
import Database from "better-sqlite3";
import postgres from "postgres";

const sqliteDb = new Database("data.sqlite");
const pgClient = postgres(process.env.DATABASE_URL!);

async function migrate() {
  console.log("Starting SQLite → PostgreSQL migration...\n");

  // ── Users ──────────────────────────────────────────────────────────────────
  const sqliteUsers = sqliteDb.prepare("SELECT * FROM users").all() as any[];
  console.log(`Users: ${sqliteUsers.length} rows`);
  if (sqliteUsers.length > 0) {
    await pgClient`TRUNCATE users RESTART IDENTITY CASCADE`;
    for (const u of sqliteUsers) {
      await pgClient`
        INSERT INTO users (id, username, role)
        VALUES (${u.id}, ${u.username}, ${u.role})
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('users_id_seq', (SELECT MAX(id) FROM users))`;
    console.log("  ✓ Users migrated");
  }

  // ── Sales ──────────────────────────────────────────────────────────────────
  const sqliteSales = sqliteDb.prepare("SELECT * FROM sales ORDER BY id").all() as any[];
  console.log(`Sales: ${sqliteSales.length} rows`);
  if (sqliteSales.length > 0) {
    await pgClient`TRUNCATE sales RESTART IDENTITY CASCADE`;
    for (const s of sqliteSales) {
      let payments: any = {};
      try {
        payments = typeof s.payments === "string" ? JSON.parse(s.payments) : (s.payments ?? {});
      } catch {}
      await pgClient`
        INSERT INTO sales (id, invoice_number, date, designation, client_type, client_name,
          convention_name, chassis_number, registration_number, gray_card_status,
          total_to_pay, advance, payments, payment_day, created_at)
        VALUES (
          ${s.id}, ${s.invoice_number}, ${s.date}, ${s.designation}, ${s.client_type},
          ${s.client_name}, ${s.convention_name ?? null}, ${s.chassis_number ?? null},
          ${s.registration_number ?? null}, ${s.gray_card_status ?? "En cours"},
          ${s.total_to_pay ?? 0}, ${s.advance ?? 0},
          ${JSON.stringify(payments)}::jsonb,
          ${s.payment_day ?? 1}, ${s.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('sales_id_seq', (SELECT MAX(id) FROM sales))`;
    console.log("  ✓ Sales migrated");
  }

  // ── Clients ────────────────────────────────────────────────────────────────
  const sqliteClients = sqliteDb.prepare("SELECT * FROM clients ORDER BY id").all() as any[];
  console.log(`Clients: ${sqliteClients.length} rows`);
  if (sqliteClients.length > 0) {
    await pgClient`TRUNCATE clients RESTART IDENTITY CASCADE`;
    for (const c of sqliteClients) {
      await pgClient`
        INSERT INTO clients (id, nom_prenom, numero_telephone, numero_telephone_2,
          email, fax, nom_sub_client, adresse, cin, type_company, code_postal,
          unique_number, categorie, famille, civilite, mode_reglement, banque,
          remarque, created_at)
        VALUES (
          ${c.id}, ${c.nom_prenom}, ${c.numero_telephone ?? ""}, ${c.numero_telephone_2 ?? ""},
          ${c.email ?? ""}, ${c.fax ?? ""}, ${c.nom_sub_client ?? ""}, ${c.adresse ?? ""},
          ${c.cin ?? ""}, ${c.type_company ?? ""}, ${c.code_postal ?? ""},
          ${c.unique_number ?? ""}, ${c.categorie ?? ""}, ${c.famille ?? ""},
          ${c.civilite ?? ""}, ${c.mode_reglement ?? ""}, ${c.banque ?? ""},
          ${c.remarque ?? ""}, ${c.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('clients_id_seq', (SELECT MAX(id) FROM clients))`;
    console.log("  ✓ Clients migrated");
  }

  // ── Oil Sales ──────────────────────────────────────────────────────────────
  const sqliteOilSales = sqliteDb.prepare("SELECT * FROM oil_sales ORDER BY id").all() as any[];
  console.log(`Oil Sales: ${sqliteOilSales.length} rows`);
  if (sqliteOilSales.length > 0) {
    await pgClient`TRUNCATE oil_sales RESTART IDENTITY CASCADE`;
    for (const o of sqliteOilSales) {
      await pgClient`
        INSERT INTO oil_sales (id, date, huile_10w40, huile_20w50, gear_oil, brake_oil,
          prix, encaissement, client, confirmed_by_staff, confirmed_by_manager,
          calculation_timestamp, amount_handed, created_at)
        VALUES (
          ${o.id}, ${o.date}, ${o.huile_10w40 ?? 0}, ${o.huile_20w50 ?? 0},
          ${o.gear_oil ?? 0}, ${o.brake_oil ?? 0},
          ${o.prix ?? 0}, ${o.encaissement}, ${o.client ?? ""},
          ${o.confirmed_by_staff ?? null}, ${o.confirmed_by_manager ?? null},
          ${o.calculation_timestamp ?? null}, ${o.amount_handed ?? 0},
          ${o.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('oil_sales_id_seq', (SELECT MAX(id) FROM oil_sales))`;
    console.log("  ✓ Oil Sales migrated");
  }

  // ── Oil Purchases ──────────────────────────────────────────────────────────
  const sqliteOilPurchases = sqliteDb.prepare("SELECT * FROM oil_purchases ORDER BY id").all() as any[];
  console.log(`Oil Purchases: ${sqliteOilPurchases.length} rows`);
  if (sqliteOilPurchases.length > 0) {
    await pgClient`TRUNCATE oil_purchases RESTART IDENTITY CASCADE`;
    for (const o of sqliteOilPurchases) {
      await pgClient`
        INSERT INTO oil_purchases (id, date, huile_10w40, huile_20w50, gear_oil, brake_oil,
          fournisseur, prix, created_at)
        VALUES (
          ${o.id}, ${o.date}, ${o.huile_10w40 ?? 0}, ${o.huile_20w50 ?? 0},
          ${o.gear_oil ?? 0}, ${o.brake_oil ?? 0},
          ${o.fournisseur ?? ""}, ${o.prix ?? 0}, ${o.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('oil_purchases_id_seq', (SELECT MAX(id) FROM oil_purchases))`;
    console.log("  ✓ Oil Purchases migrated");
  }

  // ── Helmet Sales ───────────────────────────────────────────────────────────
  const sqliteHelmetSales = sqliteDb.prepare("SELECT * FROM helmet_sales ORDER BY id").all() as any[];
  console.log(`Helmet Sales: ${sqliteHelmetSales.length} rows`);
  if (sqliteHelmetSales.length > 0) {
    await pgClient`TRUNCATE helmet_sales RESTART IDENTITY CASCADE`;
    for (const h of sqliteHelmetSales) {
      await pgClient`
        INSERT INTO helmet_sales (id, numero_facture, date, designation, type_client,
          nom_prenom, quantite, montant, remarque, confirmed_by_staff, confirmed_by_manager,
          calculation_timestamp, amount_handed, created_at)
        VALUES (
          ${h.id}, ${h.numero_facture ?? ""}, ${h.date}, ${h.designation},
          ${h.type_client}, ${h.nom_prenom}, ${h.quantite ?? 1}, ${h.montant ?? 0},
          ${h.remarque ?? ""}, ${h.confirmed_by_staff ?? null}, ${h.confirmed_by_manager ?? null},
          ${h.calculation_timestamp ?? null}, ${h.amount_handed ?? 0},
          ${h.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('helmet_sales_id_seq', (SELECT MAX(id) FROM helmet_sales))`;
    console.log("  ✓ Helmet Sales migrated");
  }

  // ── Helmet Purchases ───────────────────────────────────────────────────────
  const sqliteHelmetPurchases = sqliteDb.prepare("SELECT * FROM helmet_purchases ORDER BY id").all() as any[];
  console.log(`Helmet Purchases: ${sqliteHelmetPurchases.length} rows`);
  if (sqliteHelmetPurchases.length > 0) {
    await pgClient`TRUNCATE helmet_purchases RESTART IDENTITY CASCADE`;
    for (const h of sqliteHelmetPurchases) {
      await pgClient`
        INSERT INTO helmet_purchases (id, date, designation, quantite, fournisseur, prix, created_at)
        VALUES (
          ${h.id}, ${h.date}, ${h.designation}, ${h.quantite ?? 0},
          ${h.fournisseur ?? ""}, ${h.prix ?? 0}, ${h.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('helmet_purchases_id_seq', (SELECT MAX(id) FROM helmet_purchases))`;
    console.log("  ✓ Helmet Purchases migrated");
  }

  // ── Saddle Sales ───────────────────────────────────────────────────────────
  const sqliteSaddleSales = sqliteDb.prepare("SELECT * FROM saddle_sales ORDER BY id").all() as any[];
  console.log(`Saddle Sales: ${sqliteSaddleSales.length} rows`);
  if (sqliteSaddleSales.length > 0) {
    await pgClient`TRUNCATE saddle_sales RESTART IDENTITY CASCADE`;
    for (const s of sqliteSaddleSales) {
      await pgClient`
        INSERT INTO saddle_sales (id, date, taille_xl, taille_xxl, prix, encaissement,
          client, confirmed_by_staff, confirmed_by_manager, calculation_timestamp,
          amount_handed, created_at)
        VALUES (
          ${s.id}, ${s.date}, ${s.taille_xl ?? 0}, ${s.taille_xxl ?? 0},
          ${s.prix ?? 0}, ${s.encaissement}, ${s.client ?? ""},
          ${s.confirmed_by_staff ?? null}, ${s.confirmed_by_manager ?? null},
          ${s.calculation_timestamp ?? null}, ${s.amount_handed ?? 0},
          ${s.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('saddle_sales_id_seq', (SELECT MAX(id) FROM saddle_sales))`;
    console.log("  ✓ Saddle Sales migrated");
  }

  // ── Saddle Purchases ───────────────────────────────────────────────────────
  const sqliteSaddlePurchases = sqliteDb.prepare("SELECT * FROM saddle_purchases ORDER BY id").all() as any[];
  console.log(`Saddle Purchases: ${sqliteSaddlePurchases.length} rows`);
  if (sqliteSaddlePurchases.length > 0) {
    await pgClient`TRUNCATE saddle_purchases RESTART IDENTITY CASCADE`;
    for (const s of sqliteSaddlePurchases) {
      await pgClient`
        INSERT INTO saddle_purchases (id, date, taille_xl, taille_xxl, fournisseur, prix, created_at)
        VALUES (
          ${s.id}, ${s.date}, ${s.taille_xl ?? 0}, ${s.taille_xxl ?? 0},
          ${s.fournisseur ?? ""}, ${s.prix ?? 0}, ${s.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('saddle_purchases_id_seq', (SELECT MAX(id) FROM saddle_purchases))`;
    console.log("  ✓ Saddle Purchases migrated");
  }

  // ── Deferred Sales ─────────────────────────────────────────────────────────
  const sqliteDeferredSales = sqliteDb.prepare("SELECT * FROM deferred_sales ORDER BY id").all() as any[];
  console.log(`Deferred Sales: ${sqliteDeferredSales.length} rows`);
  if (sqliteDeferredSales.length > 0) {
    await pgClient`TRUNCATE deferred_sales RESTART IDENTITY CASCADE`;
    for (const d of sqliteDeferredSales) {
      await pgClient`
        INSERT INTO deferred_sales (id, date, nom_prenom, numero_telephone, type_moto,
          designation, quantite, montant, is_settled, confirmed_by_staff, confirmed_by_manager,
          calculation_timestamp, amount_handed, created_at)
        VALUES (
          ${d.id}, ${d.date}, ${d.nom_prenom}, ${d.numero_telephone ?? ""},
          ${d.type_moto ?? ""}, ${d.designation}, ${d.quantite ?? 1}, ${d.montant ?? 0},
          ${d.is_settled ? true : false},
          ${d.confirmed_by_staff ?? null}, ${d.confirmed_by_manager ?? null},
          ${d.calculation_timestamp ?? null}, ${d.amount_handed ?? 0},
          ${d.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('deferred_sales_id_seq', (SELECT MAX(id) FROM deferred_sales))`;
    console.log("  ✓ Deferred Sales migrated");
  }

  // ── Divers Purchases ───────────────────────────────────────────────────────
  const sqliteDiversPurchases = sqliteDb.prepare("SELECT * FROM divers_purchases ORDER BY id").all() as any[];
  console.log(`Divers Purchases: ${sqliteDiversPurchases.length} rows`);
  if (sqliteDiversPurchases.length > 0) {
    await pgClient`TRUNCATE divers_purchases RESTART IDENTITY CASCADE`;
    for (const d of sqliteDiversPurchases) {
      await pgClient`
        INSERT INTO divers_purchases (id, date, designation, quantite, fournisseur, prix, created_at)
        VALUES (
          ${d.id}, ${d.date}, ${d.designation}, ${d.quantite ?? 0},
          ${d.fournisseur ?? ""}, ${d.prix ?? 0}, ${d.created_at ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('divers_purchases_id_seq', (SELECT MAX(id) FROM divers_purchases))`;
    console.log("  ✓ Divers Purchases migrated");
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  const sqliteNotifications = sqliteDb.prepare("SELECT * FROM notifications ORDER BY id").all() as any[];
  console.log(`Notifications: ${sqliteNotifications.length} rows`);
  if (sqliteNotifications.length > 0) {
    await pgClient`TRUNCATE user_notifications RESTART IDENTITY CASCADE`;
    await pgClient`TRUNCATE notifications RESTART IDENTITY CASCADE`;
    for (const n of sqliteNotifications) {
      await pgClient`
        INSERT INTO notifications (id, user_id, action, target, details, timestamp)
        VALUES (
          ${n.id}, ${n.user_id ?? null}, ${n.action}, ${n.target},
          ${n.details ?? null}, ${n.timestamp ?? Date.now()}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('notifications_id_seq', (SELECT MAX(id) FROM notifications))`;
    console.log("  ✓ Notifications migrated");
  }

  // ── User Notifications ─────────────────────────────────────────────────────
  const sqliteUserNotifs = sqliteDb.prepare("SELECT * FROM user_notifications ORDER BY id").all() as any[];
  console.log(`User Notifications: ${sqliteUserNotifs.length} rows`);
  if (sqliteUserNotifs.length > 0) {
    for (const un of sqliteUserNotifs) {
      await pgClient`
        INSERT INTO user_notifications (id, user_id, notification_id, is_read)
        VALUES (
          ${un.id}, ${un.user_id}, ${un.notification_id}, ${un.is_read ? true : false}
        )
        ON CONFLICT (id) DO NOTHING
      `;
    }
    await pgClient`SELECT setval('user_notifications_id_seq', (SELECT MAX(id) FROM user_notifications))`;
    console.log("  ✓ User Notifications migrated");
  }

  await pgClient.end();
  sqliteDb.close();
  console.log("\n✅ Migration complete!");
}

migrate().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
