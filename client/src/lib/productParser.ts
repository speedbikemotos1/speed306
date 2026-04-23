const TYPO_MAP: [RegExp, string][] = [
  [/\bCOLORE\b/g, "COLOREE"],
  [/\bGOST\b/g, "GHOST"],
  [/\bJL\s+M\b/g, "JLM"],
  [/\bORIGNE\b/g, "ORIGINE"],
  [/\bORGINE\b/g, "ORIGINE"],
  [/\bBOOSTE\b/g, "BOOSTER"],
  [/\bBOSTER\b/g, "BOOSTER"],
  [/\bPOWR\b/g, "POWER"],
  [/\bSPRIN\b/g, "SPRING"],
  [/\bDEMAREUR\b/g, "DEMARREUR"],
  [/\bFILTER\b/g, "FILTRE"],
  [/\bCLOCH\b/g, "CLOCHE"],
  [/\bCYLINDER\b/g, "CYLINDRE"],
  [/\bPOIGNIEE\b/g, "POIGNEE"],
  [/\bECHAPEMENT\b/g, "ECHAPPEMENT"],
];

export const FAMILIES = ["GHOST", "JLM", "MBK", "CIAO", "POWER", "BOOSTER", "SPRING", "KTG"] as const;
export type Family = (typeof FAMILIES)[number];

const CATEGORY_KEYWORDS: [string[], string][] = [
  [["AILES", "AILE", "CARENAGE", "COQUE", "GARDE", "HABILLAGE", "CACHE"], "Carrosserie"],
  [["BAVETTE", "RETROVISEUR", "BEQUILLE"], "Extérieur"],
  [["AFFICHEUR", "COMPTEUR", "COMMUTATEUR", "CDI", "BOBINE", "REGULATEUR"], "Électronique"],
  [["FEU", "PHARE", "CLIGNOTANT", "AMPOULE", "PROJECTEUR"], "Éclairage"],
  [["MOTEUR", "CYLINDRE", "PISTON", "CULASSE", "CARBURATEUR", "VILEBREQUIN", "SOUPAPE", "ARBRE", "CARTER", "COUVERCLE"], "Moteur"],
  [["FREIN", "PLAQUETTE", "DISQUE", "MAITRE", "ETRIER", "FLEXIBLE", "PATIN"], "Freinage"],
  [["PNEU", "JANTE", "ROUE", "CHAMBRE"], "Roues & Pneus"],
  [["CABLE", "POIGNEE", "LEVIER", "COMMODO"], "Câbles & Commandes"],
  [["POT", "ECHAPPEMENT", "SILENCIEUX"], "Échappement"],
  [["CHAINE", "COURONNE", "PIGNON", "VARIATEUR", "COURROIE", "GALET", "EMBRAYAGE", "CLOCHE"], "Transmission"],
  [["JOINT", "POCHETTE"], "Joints & Étanchéité"],
  [["ROULEMENT"], "Roulements"],
  [["SELLE"], "Confort"],
  [["GUIDON", "DIRECTION"], "Direction"],
  [["FOURCHE", "AMORTISSEUR", "PLONGEUR"], "Suspension"],
  [["RESERVOIR", "ROBINET", "JAUGE"], "Carburant"],
  [["FILTRE"], "Filtration"],
  [["BOUGIE"], "Allumage"],
  [["DEMARREUR", "BATTERIE", "STATOR", "BENDIX", "CAGE", "VENTILATEUR"], "Électricité"],
  [["STICKER", "AUTOCOLLANT"], "Décoration"],
  [["KIT"], "Kits"],
];

const CATEGORY_MAP: Record<string, string> = {};
for (const [keys, cat] of CATEGORY_KEYWORDS) {
  for (const k of keys) CATEGORY_MAP[k] = cat;
}

const PHRASE_CATEGORIES: [string, string][] = [
  ["KIT ROULEMENT", "Roulements"],
  ["KIT BOITE", "Transmission"],
  ["KIT CONTACT", "Électronique"],
  ["AXE DE ROUE", "Roues & Pneus"],
  ["AXE DE BROCHE", "Moteur"],
  ["JEU DE DIRECTION", "Direction"],
  ["JEU DE PATIN", "Freinage"],
  ["JEU DE GALET", "Transmission"],
  ["JEU DE ROULEMENT", "Roulements"],
  ["JEU DE PAR", "Suspension"],
  ["BRAS DE KICK", "Électricité"],
  ["PIGNON DE DEMARRAGE", "Électricité"],
  ["SUPPORT MOTEUR", "Moteur"],
  ["TE DE FOURCHE", "Suspension"],
  ["BLOC CDI", "Électronique"],
];

const COLORS = ["BLEU", "NOIR", "ROUGE", "GRIS", "BLANC", "VERT", "JAUNE", "ORANGE", "VIOLET", "ROSE", "MARRON", "ARGENT", "OR", "CHROME", "TRANSPARENT"];
const VARIANTS = ["V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "ORIGINE", "SPORT", "RACING", "PREMIUM", "EVO", "PRO", "PLUS", "SUPER"];
const DISPLACEMENTS = ["250", "200", "150", "125", "124", "110", "100", "80", "50"];

export interface EnrichedProduct {
  id: number;
  number: number;
  designation: string;
  prixVenteTTC: number;
  normalizedName: string;
  family: string;
  model: string;
  displacement: string;
  variant: string;
  color: string;
  category: string;
  searchText: string;
}

export function normalizeDesignation(raw: string): string {
  let s = raw.toUpperCase();
  for (const [re, fix] of TYPO_MAP) s = s.replace(re, fix);
  s = s.replace(/[-_]/g, " ").replace(/\s+/g, " ").trim();
  s = s.replace(/\b(\w+)(\s+\1)+\b/gi, "$1");
  return s;
}

function extractFamily(normalized: string): string {
  for (const fam of FAMILIES) {
    if (new RegExp(`\\b${fam}\\b`).test(normalized)) return fam;
  }
  return "";
}

function extractDisplacement(normalized: string): string {
  for (const cc of DISPLACEMENTS) {
    if (new RegExp(`\\b${cc}(CC)?\\b`, "i").test(normalized)) return `${cc}cc`;
  }
  return "";
}

function extractVariant(normalized: string): string {
  for (const v of VARIANTS) {
    if (new RegExp(`\\b${v}\\b`).test(normalized)) return v;
  }
  return "";
}

function extractColor(normalized: string): string {
  for (const c of COLORS) {
    if (new RegExp(`\\b${c}\\b`).test(normalized)) return c;
  }
  return "";
}

function extractCategory(normalized: string): string {
  for (const [phrase, cat] of PHRASE_CATEGORIES) {
    if (normalized.includes(phrase)) return cat;
  }
  const words = normalized.split(/\s+/);
  for (const word of words) {
    if (CATEGORY_MAP[word]) return CATEGORY_MAP[word];
  }
  return "Autre";
}

function extractModel(normalized: string, family: string, displacement: string): string {
  if (family === "KTG") {
    const isHRPlus = /HR\s*\+/.test(normalized);
    const isPista = normalized.includes("PISTA");
    if (isPista) return "PISTA HR+";
    if (isHRPlus) return displacement ? `HR+ ${displacement}` : "HR+";
    return displacement ? `HR ${displacement}` : "HR";
  }
  if (!family) return "";
  const vMatch = normalized.match(new RegExp(`${family}\\s+(V\\d+|\\d{2,3})`, "i"));
  if (vMatch) return `${family} ${vMatch[1].toUpperCase()}`;
  if (displacement) return `${family} ${displacement}`;
  return family;
}

export function enrichProduct(p: { id: number; number: number; designation: string; prixVenteTTC: number }): EnrichedProduct {
  const normalized = normalizeDesignation(p.designation);
  const family = extractFamily(normalized);
  const displacement = extractDisplacement(normalized);
  const model = extractModel(normalized, family, displacement);
  const variant = extractVariant(normalized);
  const color = extractColor(normalized);
  const category = extractCategory(normalized);
  const searchText = [normalized, family, model, category, color, variant].filter(Boolean).join(" ");
  return { ...p, normalizedName: normalized, family, model, displacement, variant, color, category, searchText };
}

export const FAMILY_DISPLAY_NAMES: Record<string, string> = {
  KTG: "HR+",
};

export const FAMILY_COLORS: Record<string, string> = {
  GHOST: "bg-violet-100 text-violet-800 dark:bg-violet-900/40 dark:text-violet-300",
  JLM: "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-300",
  MBK: "bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300",
  CIAO: "bg-green-100 text-green-800 dark:bg-green-900/40 dark:text-green-300",
  POWER: "bg-red-100 text-red-800 dark:bg-red-900/40 dark:text-red-300",
  BOOSTER: "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-300",
  SPRING: "bg-teal-100 text-teal-800 dark:bg-teal-900/40 dark:text-teal-300",
  KTG: "bg-rose-100 text-rose-800 dark:bg-rose-900/40 dark:text-rose-300",
};

export const CATEGORY_COLORS: Record<string, string> = {
  "Carrosserie": "bg-sky-100 text-sky-800 dark:bg-sky-900/40 dark:text-sky-300",
  "Extérieur": "bg-cyan-100 text-cyan-800 dark:bg-cyan-900/40 dark:text-cyan-300",
  "Électronique": "bg-indigo-100 text-indigo-800 dark:bg-indigo-900/40 dark:text-indigo-300",
  "Éclairage": "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/40 dark:text-yellow-300",
  "Moteur": "bg-red-100 text-red-800 dark:bg-red-900/40 dark:text-red-300",
  "Freinage": "bg-rose-100 text-rose-800 dark:bg-rose-900/40 dark:text-rose-300",
  "Roues & Pneus": "bg-stone-100 text-stone-800 dark:bg-stone-900/40 dark:text-stone-300",
  "Câbles & Commandes": "bg-slate-100 text-slate-800 dark:bg-slate-900/40 dark:text-slate-300",
  "Échappement": "bg-zinc-100 text-zinc-800 dark:bg-zinc-900/40 dark:text-zinc-300",
  "Transmission": "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-300",
  "Joints & Étanchéité": "bg-lime-100 text-lime-800 dark:bg-lime-900/40 dark:text-lime-300",
  "Roulements": "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-300",
  "Confort": "bg-pink-100 text-pink-800 dark:bg-pink-900/40 dark:text-pink-300",
  "Direction": "bg-purple-100 text-purple-800 dark:bg-purple-900/40 dark:text-purple-300",
  "Suspension": "bg-fuchsia-100 text-fuchsia-800 dark:bg-fuchsia-900/40 dark:text-fuchsia-300",
  "Carburant": "bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300",
  "Filtration": "bg-teal-100 text-teal-800 dark:bg-teal-900/40 dark:text-teal-300",
  "Allumage": "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/40 dark:text-yellow-300",
  "Électricité": "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-300",
  "Décoration": "bg-violet-100 text-violet-800 dark:bg-violet-900/40 dark:text-violet-300",
  "Kits": "bg-green-100 text-green-800 dark:bg-green-900/40 dark:text-green-300",
  "Autre": "bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400",
};
