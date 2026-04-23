import { writeFileSync, mkdirSync, readdirSync, statSync, unlinkSync } from "fs";
import { join } from "path";
import postgres from "postgres";
import cron from "node-cron";

const BACKUP_DIR = join(process.cwd(), "backups");

// Retention policy
const ONE_WEEK_MS  = 7  * 24 * 60 * 60 * 1000;
const ONE_MONTH_MS = 30 * 24 * 60 * 60 * 1000;

// 18:00 Tunisia = 17:00 UTC — this slot gets monthly retention
const MONTHLY_UTC_HOUR = 17;

// ─── Table definitions ────────────────────────────────────────────────────────

type TableDef = {
  name: string;
  cols: string[];
  numeric: string[];
  bool: string[];
  json: string[];
};

const ALL_TABLES: TableDef[] = [
  {
    name: "users",
    cols: ["id", "username", "role"],
    numeric: ["id"],
    bool: [],
    json: [],
  },
  {
    name: "clients",
    cols: ["id","nom_prenom","numero_telephone","numero_telephone_2","email","fax","nom_sub_client","adresse","cin","type_company","code_postal","unique_number","categorie","famille","civilite","mode_reglement","banque","remarque","created_at"],
    numeric: ["id","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "sales",
    cols: ["id","invoice_number","date","designation","client_type","client_name","convention_name","chassis_number","registration_number","gray_card_status","total_to_pay","advance","payments","payment_day","created_at"],
    numeric: ["id","total_to_pay","advance","payment_day","created_at"],
    bool: [],
    json: ["payments"],
  },
  {
    name: "oil_sales",
    cols: ["id","date","huile_10w40","huile_20w50","gear_oil","brake_oil","prix","encaissement","client","confirmed_by_staff","confirmed_by_manager","calculation_timestamp","amount_handed","created_at"],
    numeric: ["id","huile_10w40","huile_20w50","gear_oil","brake_oil","prix","calculation_timestamp","amount_handed","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "oil_purchases",
    cols: ["id","date","huile_10w40","huile_20w50","gear_oil","brake_oil","fournisseur","prix","created_at"],
    numeric: ["id","huile_10w40","huile_20w50","gear_oil","brake_oil","prix","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "helmet_sales",
    cols: ["id","numero_facture","date","designation","type_client","nom_prenom","quantite","montant","remarque","confirmed_by_staff","confirmed_by_manager","calculation_timestamp","amount_handed","created_at"],
    numeric: ["id","quantite","montant","calculation_timestamp","amount_handed","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "helmet_purchases",
    cols: ["id","date","designation","quantite","fournisseur","prix","created_at"],
    numeric: ["id","quantite","prix","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "deferred_sales",
    cols: ["id","date","nom_prenom","numero_telephone","type_moto","designation","quantite","montant","is_settled","confirmed_by_staff","confirmed_by_manager","calculation_timestamp","amount_handed","created_at"],
    numeric: ["id","quantite","montant","calculation_timestamp","amount_handed","created_at"],
    bool: ["is_settled"],
    json: [],
  },
  {
    name: "facture_lines",
    cols: ["id","facture_number","bon_ref","date","commercial","client","id_client","ref","designation","qte","prix","tva","remise","prix_ttc","montant_ht","montant_tva","montant_ttc","created_at"],
    numeric: ["id","qte","prix","remise","prix_ttc","montant_ht","montant_tva","montant_ttc","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "divers_purchases",
    cols: ["id","date","designation","quantite","fournisseur","prix","created_at"],
    numeric: ["id","quantite","prix","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "orders",
    cols: ["id","nom_prenom","designation","avance","date","numero_telephone","remarque","created_at"],
    numeric: ["id","avance","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "reservations",
    cols: ["id","nom_prenom","designation","avance","date","numero","remarque","created_at"],
    numeric: ["id","avance","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "saddle_purchases",
    cols: ["id","date","taille_xl","taille_xxl","fournisseur","prix","created_at"],
    numeric: ["id","taille_xl","taille_xxl","prix","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "saddle_sales",
    cols: ["id","date","taille_xl","taille_xxl","prix","encaissement","client","confirmed_by_staff","confirmed_by_manager","calculation_timestamp","amount_handed","created_at"],
    numeric: ["id","taille_xl","taille_xxl","prix","calculation_timestamp","amount_handed","created_at"],
    bool: [],
    json: [],
  },
  {
    name: "notifications",
    cols: ["id","user_id","action","target","details","timestamp"],
    numeric: ["id","user_id","timestamp"],
    bool: [],
    json: [],
  },
  {
    name: "user_notifications",
    cols: ["id","user_id","notification_id","is_read"],
    numeric: ["id","user_id","notification_id"],
    bool: ["is_read"],
    json: [],
  },
];

// Focused table sets for targeted backups
const CLIENTS_TABLES: TableDef[] = ALL_TABLES.filter(t => t.name === "clients");
const BL_TABLES: TableDef[] = ALL_TABLES.filter(t => t.name === "facture_lines");

export type BackupType = "generale" | "clients" | "bl";

// ─── Value escaper ────────────────────────────────────────────────────────────

function escapeVal(val: unknown, col: string, table: TableDef): string {
  if (val === null || val === undefined) return "NULL";
  if (table.numeric.includes(col)) return String(val);
  if (table.bool.includes(col)) return val ? "true" : "false";
  if (table.json.includes(col)) {
    const str = typeof val === "string" ? val : JSON.stringify(val);
    return "'" + str.replace(/'/g, "''") + "'";
  }
  const str = typeof val === "string" ? val : String(val);
  return "'" + str.replace(/'/g, "''") + "'";
}

// ─── Core generator ───────────────────────────────────────────────────────────

async function generateTypedBackup(
  type: BackupType,
  tables: TableDef[],
  log: (msg: string, src?: string) => void,
  timestamp: string,
  label: string,
): Promise<string> {
  const sql = postgres(process.env.DATABASE_URL!, { max: 1 });

  try {
    const typeLabel: Record<BackupType, string> = {
      generale: "Complète (toutes les tables)",
      clients: "Clients uniquement",
      bl: "Bons de Livraison uniquement",
    };

    let output = `-- ================================================================\n`;
    output += `-- Speed Bike Motos — Sauvegarde ${typeLabel[type]}\n`;
    output += `-- Générée le : ${label}\n`;
    output += `-- Type : ${type}\n`;
    output += `-- Pour restaurer : coller dans Supabase > SQL Editor > Run\n`;
    output += `-- ================================================================\n\n`;

    for (const table of tables) {
      const rows = await sql.unsafe(
        `SELECT ${table.cols.map(c => `"${c}"`).join(", ")} FROM public.${table.name} ORDER BY id`
      );
      const colStr = table.cols.map(c => `"${c}"`).join(", ");

      output += `-- Table: ${table.name} (${rows.length} lignes)\n`;
      output += `TRUNCATE public.${table.name} CASCADE;\n`;

      for (const row of rows) {
        const vals = table.cols.map(col => escapeVal((row as any)[col], col, table));
        output += `INSERT INTO public.${table.name} (${colStr}) VALUES (${vals.join(", ")});\n`;
      }

      output += `SELECT setval(pg_get_serial_sequence('public.${table.name}', 'id'), COALESCE(MAX(id), 1)) FROM public.${table.name};\n`;
      output += "\n";
    }

    mkdirSync(BACKUP_DIR, { recursive: true });
    const fileName = `backup_${type}_${timestamp}.sql`;
    const filePath = join(BACKUP_DIR, fileName);
    writeFileSync(filePath, output, "utf8");

    log(`Sauvegarde créée : ${fileName} (${(output.length / 1024).toFixed(0)} KB)`, "backup");
    return filePath;
  } finally {
    await sql.end();
  }
}

// ─── Public generators ────────────────────────────────────────────────────────

export async function generateAllBackups(
  log: (msg: string, src?: string) => void
): Promise<{ generale: string; clients: string; bl: string }> {
  const now = new Date();
  const timestamp = now.toISOString().replace(/[:.]/g, "-").slice(0, 19);
  const label = now.toLocaleString("fr-FR", { timeZone: "Africa/Tunis" });

  const [generale, clients, bl] = await Promise.all([
    generateTypedBackup("generale", ALL_TABLES,     log, timestamp, label),
    generateTypedBackup("clients",  CLIENTS_TABLES, log, timestamp, label),
    generateTypedBackup("bl",       BL_TABLES,      log, timestamp, label),
  ]);

  pruneOldBackups(log);
  return { generale, clients, bl };
}

// ─── Retention / pruning ──────────────────────────────────────────────────────

function isMonthlySlot(fileName: string): boolean {
  // Filename: backup_<type>_YYYY-MM-DDTHH-MM-SS.sql
  // Monthly = 18:00 Tunisia = 17:00 UTC → contains "T17-"
  return fileName.includes("T17-");
}

function pruneOldBackups(log: (msg: string, src?: string) => void): void {
  try {
    mkdirSync(BACKUP_DIR, { recursive: true });
    const now = Date.now();

    const files = readdirSync(BACKUP_DIR)
      .filter(f => f.startsWith("backup_") && f.endsWith(".sql"))
      .map(f => ({
        name: f,
        path: join(BACKUP_DIR, f),
        age: now - statSync(join(BACKUP_DIR, f)).mtimeMs,
        monthly: isMonthlySlot(f),
      }));

    for (const f of files) {
      const maxAge = f.monthly ? ONE_MONTH_MS : ONE_WEEK_MS;
      if (f.age > maxAge) {
        unlinkSync(f.path);
        log(`Supprimé (${f.monthly ? "30j" : "7j"}) : ${f.name}`, "backup");
      }
    }
  } catch {
    // silently skip if dir doesn't exist yet
  }
}

// ─── List helpers ─────────────────────────────────────────────────────────────

export type BackupInfo = {
  name: string;
  type: BackupType;
  size: number;
  date: string;
  monthly: boolean;
};

export function listBackups(): BackupInfo[] {
  try {
    mkdirSync(BACKUP_DIR, { recursive: true });
    return readdirSync(BACKUP_DIR)
      .filter(f => f.startsWith("backup_") && f.endsWith(".sql"))
      .map(f => {
        const stat = statSync(join(BACKUP_DIR, f));
        const type: BackupType = f.startsWith("backup_clients_")
          ? "clients"
          : f.startsWith("backup_bl_")
          ? "bl"
          : "generale";
        return {
          name: f,
          type,
          size: Math.round(stat.size / 1024),
          date: stat.mtime.toLocaleString("fr-FR", { timeZone: "Africa/Tunis" }),
          monthly: isMonthlySlot(f),
        };
      })
      .sort((a, b) => b.name.localeCompare(a.name));
  } catch {
    return [];
  }
}

export function getBackupFilePath(name: string): string | null {
  try {
    if (!name.startsWith("backup_") || !name.endsWith(".sql")) return null;
    const p = join(BACKUP_DIR, name);
    statSync(p);
    return p;
  } catch {
    return null;
  }
}

// ─── Scheduler ────────────────────────────────────────────────────────────────

export function startBackupScheduler(log: (msg: string, src?: string) => void): void {
  // Tunisia (UTC+1): 12:00→11 UTC, 15:00→14 UTC, 18:00→17 UTC (monthly), 22:00→21 UTC
  const schedule = [
    { cron: "0 11 * * *", label: "12:00" },
    { cron: "0 14 * * *", label: "15:00" },
    { cron: "0 17 * * *", label: "18:00 (mensuel)" },
    { cron: "0 21 * * *", label: "22:00" },
  ];

  for (const { cron: expr, label } of schedule) {
    cron.schedule(expr, async () => {
      log(`Sauvegarde automatique ${label} — génération de 3 fichiers…`, "backup");
      try {
        await generateAllBackups(log);
      } catch (err: any) {
        log(`Erreur sauvegarde : ${err.message}`, "backup");
      }
    });
  }

  log("Planificateur démarré : 12:00 / 15:00 / 18:00 (mensuel) / 22:00", "backup");
}
