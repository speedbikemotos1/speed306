
import { integer, pgTable, text, doublePrecision, boolean, bigint, serial, jsonb } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
import { sql } from "drizzle-orm";

// Helper to define the month keys for the payment schedule
// July 2025 to Jan 2028
export const PAYMENT_MONTHS = [
  "juillet_2025", "aout_2025", "septembre_2025", "octobre_2025", "novembre_2025", "decembre_2025",
  "janvier_2026", "fevrier_2026", "mars_2026", "avril_2026", "mai_2026", "juin_2026",
  "juillet_2026", "aout_2026", "septembre_2026", "octobre_2026", "novembre_2026", "decembre_2026",
  "janvier_2027", "fevrier_2027", "mars_2027", "avril_2027", "mai_2027", "juin_2027",
  "juillet_2027", "aout_2027", "septembre_2027", "octobre_2027", "novembre_2027", "decembre_2027",
  "janvier_2028"
] as const;

export const CARTE_GRISE_STATUS = [
  "A Déposer",  // Red
  "Récupérée",  // Green
  "Impôt",      // Orange
  "En cours",   // Purple
  "Prête",      // Blue
  "None",       // Light grey / no status
] as const;

// Structure for a single month's payment data
const PaymentDataSchema = z.object({
  amount: z.number().default(0),
  isPaid: z.boolean().default(false)
});

export type PaymentData = z.infer<typeof PaymentDataSchema>;

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  role: text("role").notNull(), // 'manager' or 'staff'
});

export const insertUserSchema = createInsertSchema(users).omit({ id: true });
export type User = typeof users.$inferSelect;
export type InsertUser = z.infer<typeof insertUserSchema>;

export const sales = pgTable("sales", {
  id: serial("id").primaryKey(),
  invoiceNumber: text("invoice_number").notNull(),
  date: text("date").notNull(),
  designation: text("designation").notNull(),
  clientType: text("client_type").notNull(), // B2B / B2C / Convention
  clientName: text("client_name").notNull(),
  conventionName: text("convention_name"),
  chassisNumber: text("chassis_number"),
  registrationNumber: text("registration_number"),
  grayCardStatus: text("gray_card_status").default("En cours"),

  // Financials
  totalToPay: integer("total_to_pay").default(0),
  advance: integer("advance").default(0),

  // Payments: Stored as JSONB
  payments: jsonb("payments").$type<Record<string, PaymentData>>().default({}),
  paymentDay: integer("payment_day").default(1),

  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertSaleSchema = createInsertSchema(sales).omit({
  id: true,
  createdAt: true
});

export type Sale = typeof sales.$inferSelect;
export type InsertSale = z.infer<typeof insertSaleSchema>;

export const notifications = pgTable("notifications", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").references(() => users.id),
  action: text("action").notNull(), // 'CREATE', 'UPDATE', 'DELETE'
  target: text("target").notNull(),
  details: text("details"),
  timestamp: bigint("timestamp", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const userNotifications = pgTable("user_notifications", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull().references(() => users.id),
  notificationId: integer("notification_id").notNull().references(() => notifications.id),
  isRead: boolean("is_read").default(false),
  dismissed: boolean("dismissed").default(false),
});

export const insertNotificationSchema = createInsertSchema(notifications).omit({
  id: true,
  timestamp: true
});

export type Notification = typeof notifications.$inferSelect & { isRead?: boolean };
export type InsertNotification = z.infer<typeof insertNotificationSchema>;
export type UserNotification = typeof userNotifications.$inferSelect;

// Derived Types for API
export type SaleResponse = Sale;

// -----------------------------
// Modules: Oil (stock + sales)
// -----------------------------

export const oilSales = pgTable("oil_sales", {
  id: serial("id").primaryKey(),
  date: text("date").notNull(), // YYYY-MM-DD
  huile10w40: integer("huile_10w40").default(0).notNull(),
  huile20w50: integer("huile_20w50").default(0).notNull(),
  gearOil: integer("gear_oil").default(0),
  brakeOil: integer("brake_oil").default(0),
  prix: doublePrecision("prix").default(0).notNull(),
  encaissement: text("encaissement").notNull(),
  client: text("client").default("").notNull(),
  confirmedByStaff: text("confirmed_by_staff"),
  confirmedByManager: text("confirmed_by_manager"),
  calculationTimestamp: bigint("calculation_timestamp", { mode: "number" }),
  amountHanded: doublePrecision("amount_handed").default(0),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertOilSaleSchema = createInsertSchema(oilSales).omit({
  id: true,
  createdAt: true,
});

export type OilSale = typeof oilSales.$inferSelect;
export type InsertOilSale = z.infer<typeof insertOilSaleSchema>;

export const oilPurchases = pgTable("oil_purchases", {
  id: serial("id").primaryKey(),
  date: text("date").notNull(), // YYYY-MM-DD
  huile10w40: integer("huile_10w40").default(0).notNull(),
  huile20w50: integer("huile_20w50").default(0).notNull(),
  gearOil: integer("gear_oil").default(0),
  brakeOil: integer("brake_oil").default(0),
  fournisseur: text("fournisseur").default("").notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertOilPurchaseSchema = createInsertSchema(oilPurchases).omit({
  id: true,
  createdAt: true,
});

export type OilPurchase = typeof oilPurchases.$inferSelect;
export type InsertOilPurchase = z.infer<typeof insertOilPurchaseSchema>;

export const oilStockSchema = z.object({
  huile_10w40: z.number(),
  huile_20w50: z.number(),
  gear_oil: z.number(),
  break_oil: z.number(),
});
export type OilStock = z.infer<typeof oilStockSchema>;

// -----------------------------
// Modules: Helmets (stock + sales)
// -----------------------------

export const helmetSales = pgTable("helmet_sales", {
  id: serial("id").primaryKey(),
  numeroFacture: text("numero_facture").default("").notNull(),
  date: text("date").notNull(), // YYYY-MM-DD
  designation: text("designation").notNull(),
  typeClient: text("type_client").notNull(),
  nomPrenom: text("nom_prenom").notNull(),
  quantite: integer("quantite").default(1).notNull(),
  montant: doublePrecision("montant").default(0).notNull(),
  remarque: text("remarque").default("").notNull(),
  confirmedByStaff: text("confirmed_by_staff"),
  confirmedByManager: text("confirmed_by_manager"),
  calculationTimestamp: bigint("calculation_timestamp", { mode: "number" }),
  amountHanded: doublePrecision("amount_handed").default(0),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertHelmetSaleSchema = createInsertSchema(helmetSales).omit({
  id: true,
  createdAt: true,
});

export type HelmetSale = typeof helmetSales.$inferSelect;
export type InsertHelmetSale = z.infer<typeof insertHelmetSaleSchema>;

export const helmetPurchases = pgTable("helmet_purchases", {
  id: serial("id").primaryKey(),
  date: text("date").notNull(), // YYYY-MM-DD
  designation: text("designation").notNull(),
  quantite: integer("quantite").default(0).notNull(),
  fournisseur: text("fournisseur").default("").notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertHelmetPurchaseSchema = createInsertSchema(helmetPurchases).omit({
  id: true,
  createdAt: true,
});

export type HelmetPurchase = typeof helmetPurchases.$inferSelect;
export type InsertHelmetPurchase = z.infer<typeof insertHelmetPurchaseSchema>;

export const helmetStockRowSchema = z.object({
  designation: z.string(),
  stock: z.number(),
});
export const helmetStockSchema = z.array(helmetStockRowSchema);
export type HelmetStockRow = z.infer<typeof helmetStockRowSchema>;

// -----------------------------
// Modules: Cache Selle (saddle stock + sales)
// -----------------------------

export const saddleSales = pgTable("saddle_sales", {
  id: serial("id").primaryKey(),
  date: text("date").notNull(), // YYYY-MM-DD
  tailleXl: integer("taille_xl").default(0).notNull(),
  tailleXxl: integer("taille_xxl").default(0).notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  encaissement: text("encaissement").notNull(),
  client: text("client").default("").notNull(),
  confirmedByStaff: text("confirmed_by_staff"),
  confirmedByManager: text("confirmed_by_manager"),
  calculationTimestamp: bigint("calculation_timestamp", { mode: "number" }),
  amountHanded: doublePrecision("amount_handed").default(0),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertSaddleSaleSchema = createInsertSchema(saddleSales).omit({
  id: true,
  createdAt: true,
});

export type SaddleSale = typeof saddleSales.$inferSelect;
export type InsertSaddleSale = z.infer<typeof insertSaddleSaleSchema>;

export const saddlePurchases = pgTable("saddle_purchases", {
  id: serial("id").primaryKey(),
  date: text("date").notNull(), // YYYY-MM-DD
  tailleXl: integer("taille_xl").default(0).notNull(),
  tailleXxl: integer("taille_xxl").default(0).notNull(),
  fournisseur: text("fournisseur").default("").notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertSaddlePurchaseSchema = createInsertSchema(saddleSales).omit({
  id: true,
  createdAt: true,
});

export type SaddlePurchase = typeof saddlePurchases.$inferSelect;
export type InsertSaddlePurchase = z.infer<typeof insertSaddlePurchaseSchema>;

export const saddleStockSchema = z.object({
  taille_xl: z.number(),
  taille_xxl: z.number(),
});
export type SaddleStock = z.infer<typeof saddleStockSchema>;

// -----------------------------
// Modules: Deferred / Divers sales (with stock)
// -----------------------------

export const deferredSales = pgTable("deferred_sales", {
  id: serial("id").primaryKey(),
  date: text("date").notNull(), // YYYY-MM-DD
  nomPrenom: text("nom_prenom").notNull(),
  numeroTelephone: text("numero_telephone").default("").notNull(),
  typeMoto: text("type_moto").default("").notNull(),
  designation: text("designation").notNull(),
  quantite: integer("quantite").default(1).notNull(),
  montant: doublePrecision("montant").default(0).notNull(),
  isSettled: boolean("is_settled").default(false).notNull(),
  confirmedByStaff: text("confirmed_by_staff"),
  confirmedByManager: text("confirmed_by_manager"),
  calculationTimestamp: bigint("calculation_timestamp", { mode: "number" }),
  amountHanded: doublePrecision("amount_handed").default(0),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const diversPurchases = pgTable("divers_purchases", {
  id: serial("id").primaryKey(),
  date: text("date").notNull(), // YYYY-MM-DD
  designation: text("designation").notNull(),
  quantite: integer("quantite").default(0).notNull(),
  fournisseur: text("fournisseur").default("").notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertDiversPurchaseSchema = createInsertSchema(diversPurchases).omit({
  id: true,
  createdAt: true,
});

export type DiversPurchase = typeof diversPurchases.$inferSelect;
export type InsertDiversPurchase = z.infer<typeof insertDiversPurchaseSchema>;

export const diversStockRowSchema = z.object({
  designation: z.string(),
  stock: z.number(),
});
export const diversStockSchema = z.array(diversStockRowSchema);
export type DiversStockRow = z.infer<typeof diversStockRowSchema>;

export const insertDeferredSaleSchema = createInsertSchema(deferredSales).omit({
  id: true,
  createdAt: true,
});

export type DeferredSale = typeof deferredSales.$inferSelect;
export type InsertDeferredSale = z.infer<typeof insertDeferredSaleSchema>;

// -----------------------------
// Bons de Livraison (legacy v1 — table removed; types kept for backward-compat)
// -----------------------------

export type DeliveryNoteLine = {
  id: number;
  bonNumber: string;
  date: string;
  commercial: string;
  client: string;
  idClient: string;
  matriculeFiscal: string;
  adresseClient: string;
  phoneClient: string;
  factureNumber: string;
  ref: string;
  designation: string;
  qte: number;
  prix: number;
  tva: string;
  remise: number;
  prixTtc: number;
  montantHt: number;
  montantTva: number;
  montantTtc: number;
  serialNumber: string;
  createdAt: number;
};

// -----------------------------
// Factures
// -----------------------------

export const factures = pgTable("factures", {
  id: serial("id").primaryKey(),
  factureNumber: text("facture_number").notNull(),
  bonRef: text("bon_ref").default("").notNull(),
  date: text("date").notNull(),
  commercial: text("commercial").default("").notNull(),
  clientId: integer("client_id"),
  clientName: text("client_name").default("").notNull(),
  idClient: text("id_client").default("").notNull(),
  matriculeFiscal: text("matricule_fiscal").default("").notNull(),
  adresseClient: text("adresse_client").default("").notNull(),
  phoneClient: text("phone_client").default("").notNull(),
  status: text("status").default("draft").notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertFactureSchema = createInsertSchema(factures).omit({ id: true, createdAt: true });
export type Facture = typeof factures.$inferSelect;
export type InsertFacture = z.infer<typeof insertFactureSchema>;

export const factureLines = pgTable("facture_lines", {
  id: serial("id").primaryKey(),
  factureId: integer("facture_id"),
  factureNumber: text("facture_number").notNull(),
  bonRef: text("bon_ref").default("").notNull(),
  date: text("date").notNull(),
  commercial: text("commercial").default("").notNull(),
  client: text("client").default("").notNull(),
  idClient: text("id_client").default("").notNull(),
  matriculeFiscal: text("matricule_fiscal").default("").notNull(),
  adresseClient: text("adresse_client").default("").notNull(),
  phoneClient: text("phone_client").default("").notNull(),
  ref: text("ref").default("").notNull(),
  designation: text("designation").default("").notNull(),
  qte: doublePrecision("qte").default(1).notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  tva: text("tva").default("19%").notNull(),
  remise: doublePrecision("remise").default(0).notNull(),
  prixTtc: doublePrecision("prix_ttc").default(0).notNull(),
  montantHt: doublePrecision("montant_ht").default(0).notNull(),
  montantTva: doublePrecision("montant_tva").default(0).notNull(),
  montantTtc: doublePrecision("montant_ttc").default(0).notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertFactureLineSchema = createInsertSchema(factureLines).omit({
  id: true,
  createdAt: true,
});

export type FactureLine = typeof factureLines.$inferSelect;
export type InsertFactureLine = z.infer<typeof insertFactureLineSchema>;

// -----------------------------
// Clients
// -----------------------------

export const clients = pgTable("clients", {
  id: serial("id").primaryKey(),
  nomPrenom: text("nom_prenom").notNull(),
  numeroTelephone: text("numero_telephone").default("").notNull(),
  numeroTelephone2: text("numero_telephone_2").default(""),
  email: text("email").default(""),
  fax: text("fax").default(""),
  nomSubClient: text("nom_sub_client").default(""),
  adresse: text("adresse").default(""),
  cin: text("cin").default(""),
  typeCompany: text("type_company").default(""),
  codePostal: text("code_postal").default(""),
  uniqueNumber: text("unique_number").default(""),
  categorie: text("categorie").default(""),
  famille: text("famille").default(""),
  civilite: text("civilite").default(""),
  modeReglement: text("mode_reglement").default(""),
  banque: text("banque").default(""),
  remarque: text("remarque").default("").notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertClientSchema = createInsertSchema(clients).omit({
  id: true,
  createdAt: true,
});

export type Client = typeof clients.$inferSelect;
export type InsertClient = z.infer<typeof insertClientSchema>;

// -----------------------------
// Réservations
// -----------------------------

export const reservations = pgTable("reservations", {
  id: serial("id").primaryKey(),
  nomPrenom: text("nom_prenom").notNull(),
  designation: text("designation").notNull(),
  avance: doublePrecision("avance").default(0).notNull(),
  date: text("date").notNull(),
  numero: text("numero").default("").notNull(),
  remarque: text("remarque").default("").notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertReservationSchema = createInsertSchema(reservations).omit({
  id: true,
  createdAt: true,
});

export type Reservation = typeof reservations.$inferSelect;
export type InsertReservation = z.infer<typeof insertReservationSchema>;

// -----------------------------
// Commandes (Orders)
// -----------------------------

export const orders = pgTable("orders", {
  id: serial("id").primaryKey(),
  nomPrenom: text("nom_prenom").notNull(),
  designation: text("designation").notNull(),
  avance: doublePrecision("avance").default(0).notNull(),
  date: text("date").notNull(),
  numeroTelephone: text("numero_telephone").default("").notNull(),
  remarque: text("remarque").default("").notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});

export const insertOrderSchema = createInsertSchema(orders).omit({
  id: true,
  createdAt: true,
});

export type Order = typeof orders.$inferSelect;
export type InsertOrder = z.infer<typeof insertOrderSchema>;

// -----------------------------
// Stock / Moto Management
// -----------------------------

export const productFamilies = pgTable("product_families", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertProductFamilySchema = createInsertSchema(productFamilies).omit({ id: true, createdAt: true });
export type ProductFamily = typeof productFamilies.$inferSelect;
export type InsertProductFamily = z.infer<typeof insertProductFamilySchema>;

export const products = pgTable("products", {
  id: serial("id").primaryKey(),
  reference: text("reference").notNull(),
  designation: text("designation").notNull(),
  familyId: integer("family_id"),
  defaultPrice: doublePrecision("default_price").default(0),
  tvaPct: doublePrecision("tva_pct").default(19),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertProductSchema = createInsertSchema(products).omit({ id: true, createdAt: true });
export type Product = typeof products.$inferSelect;
export type InsertProduct = z.infer<typeof insertProductSchema>;

export const productSerials = pgTable("product_serials", {
  id: serial("id").primaryKey(),
  productId: integer("product_id").notNull(),
  serialNumber: text("serial_number").notNull(),
  purchasePrice: doublePrecision("purchase_price").default(0),
  status: text("status").default("available").notNull(),
  receptionId: integer("reception_id"),
  livraisonId: integer("livraison_id"),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertProductSerialSchema = createInsertSchema(productSerials).omit({ id: true, createdAt: true });
export type ProductSerial = typeof productSerials.$inferSelect;
export type InsertProductSerial = z.infer<typeof insertProductSerialSchema>;

export const receptions = pgTable("receptions", {
  id: serial("id").primaryKey(),
  bonNumber: text("bon_number").notNull(),
  date: text("date").notNull(),
  fournisseur: text("fournisseur").default("").notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertReceptionSchema = createInsertSchema(receptions).omit({ id: true, createdAt: true });
export type Reception = typeof receptions.$inferSelect;
export type InsertReception = z.infer<typeof insertReceptionSchema>;

export const receptionLines = pgTable("reception_lines", {
  id: serial("id").primaryKey(),
  receptionId: integer("reception_id").notNull(),
  productId: integer("product_id").notNull(),
  quantity: integer("quantity").default(1).notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  tvaPct: doublePrecision("tva_pct").default(19).notNull(),
  remise: doublePrecision("remise").default(0).notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertReceptionLineSchema = createInsertSchema(receptionLines).omit({ id: true, createdAt: true });
export type ReceptionLine = typeof receptionLines.$inferSelect;
export type InsertReceptionLine = z.infer<typeof insertReceptionLineSchema>;

export const livraisons = pgTable("livraisons", {
  id: serial("id").primaryKey(),
  bonNumber: text("bon_number").notNull(),
  date: text("date").notNull(),
  commercial: text("commercial").default("").notNull(),
  clientId: integer("client_id"),
  clientName: text("client_name").default("").notNull(),
  idClient: text("id_client").default("").notNull(),
  status: text("status").default("draft").notNull(),
  factureNumber: text("facture_number").default("").notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertLivraisonSchema = createInsertSchema(livraisons).omit({ id: true, createdAt: true });
export type Livraison = typeof livraisons.$inferSelect;
export type InsertLivraison = z.infer<typeof insertLivraisonSchema>;

export const livraisonLines = pgTable("livraison_lines", {
  id: serial("id").primaryKey(),
  livraisonId: integer("livraison_id").notNull(),
  productSerialId: integer("product_serial_id"),
  productId: integer("product_id"),
  ref: text("ref").default("").notNull(),
  designation: text("designation").default("").notNull(),
  serialNumber: text("serial_number").default("").notNull(),
  prix: doublePrecision("prix").default(0).notNull(),
  tvaPct: doublePrecision("tva_pct").default(19).notNull(),
  remise: doublePrecision("remise").default(0).notNull(),
  prixTtc: doublePrecision("prix_ttc").default(0).notNull(),
  montantHt: doublePrecision("montant_ht").default(0).notNull(),
  montantTva: doublePrecision("montant_tva").default(0).notNull(),
  montantTtc: doublePrecision("montant_ttc").default(0).notNull(),
  createdAt: bigint("created_at", { mode: "number" }).default(sql`extract(epoch from now())::bigint * 1000`),
});
export const insertLivraisonLineSchema = createInsertSchema(livraisonLines).omit({ id: true, createdAt: true });
export type LivraisonLine = typeof livraisonLines.$inferSelect;
export type InsertLivraisonLine = z.infer<typeof insertLivraisonLineSchema>;

// -----------------------------
// Tarif (Product Price List)
// -----------------------------

export const productPrices = pgTable("product_prices", {
  id: serial("id").primaryKey(),
  number: integer("number").notNull(),
  designation: text("designation").notNull(),
  prixVenteTTC: doublePrecision("prix_vente_ttc").notNull(),
});

export const insertProductPriceSchema = createInsertSchema(productPrices).omit({ id: true });
export type ProductPrice = typeof productPrices.$inferSelect;
export type InsertProductPrice = z.infer<typeof insertProductPriceSchema>;
