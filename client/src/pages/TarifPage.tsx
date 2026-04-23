import { useState, useRef, useMemo, useCallback, useEffect } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import * as XLSX from "xlsx";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogDescription } from "@/components/ui/dialog";
import {
  Search, Upload, Trash2, X, Tag, AlertTriangle,
  ArrowUpDown, ArrowUp, ArrowDown, ChevronLeft, ChevronRight,
  Star, SlidersHorizontal, Download, Percent, ToggleLeft, ToggleRight, Layers
} from "lucide-react";
import Dashboard from "./Dashboard";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import type { ProductPrice } from "@shared/schema";
import {
  enrichProduct, FAMILIES, FAMILY_COLORS, FAMILY_DISPLAY_NAMES, CATEGORY_COLORS,
  type EnrichedProduct
} from "@/lib/productParser";

const PAGE_SIZE = 25;
type SortField = "number" | "designation" | "family" | "model" | "category" | "displacement" | "base" | "selling";
type SortDir = "asc" | "desc";
type GroupBy = "none" | "family" | "category" | "model";
type TabId = "all" | "favorites" | (typeof FAMILIES)[number];

type FlatItem =
  | { type: "header"; label: string; count: number }
  | { type: "row"; product: EnrichedProduct };

interface Filters {
  families: string[];
  models: string[];
  displacements: string[];
  categories: string[];
  colors: string[];
}

const EMPTY_FILTERS: Filters = { families: [], models: [], displacements: [], categories: [], colors: [] };

function readLS<T>(key: string, fallback: T): T {
  try { const v = localStorage.getItem(key); return v ? JSON.parse(v) : fallback; }
  catch { return fallback; }
}

function fmt(n: number) {
  return n.toLocaleString("fr-TN", { minimumFractionDigits: 3, maximumFractionDigits: 3 });
}

function SortIcon({ field, current, dir }: { field: SortField; current: SortField | null; dir: SortDir }) {
  if (current !== field) return <ArrowUpDown className="w-3 h-3 ml-1 opacity-30 shrink-0" />;
  return dir === "asc"
    ? <ArrowUp className="w-3 h-3 ml-1 text-indigo-500 shrink-0" />
    : <ArrowDown className="w-3 h-3 ml-1 text-indigo-500 shrink-0" />;
}

function FamilyBadge({ family }: { family: string }) {
  if (!family) return null;
  const cls = FAMILY_COLORS[family] ?? "bg-gray-100 text-gray-700";
  const label = FAMILY_DISPLAY_NAMES[family] ?? family;
  return <span className={`inline-flex px-1.5 py-0.5 rounded text-[10px] font-bold uppercase tracking-wide ${cls}`}>{label}</span>;
}

function CategoryBadge({ category }: { category: string }) {
  if (!category || category === "Autre") return <span className="text-xs text-muted-foreground">—</span>;
  const cls = CATEGORY_COLORS[category] ?? "bg-gray-100 text-gray-700";
  return <span className={`inline-flex px-1.5 py-0.5 rounded text-[10px] font-medium ${cls}`}>{category}</span>;
}

function FilterSection({
  title, options, selected, onChange, displayNames,
}: {
  title: string;
  options: string[];
  selected: string[];
  onChange: (v: string[]) => void;
  displayNames?: Record<string, string>;
}) {
  if (options.length === 0) return null;
  return (
    <div className="space-y-1.5">
      <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">{title}</p>
      <div className="space-y-1 max-h-44 overflow-y-auto pr-1">
        {options.map(opt => (
          <label key={opt} className="flex items-center gap-2 cursor-pointer group">
            <input
              type="checkbox"
              className="rounded border-gray-300 text-indigo-600"
              checked={selected.includes(opt)}
              onChange={e => {
                const next = e.target.checked ? [...selected, opt] : selected.filter(v => v !== opt);
                onChange(next);
              }}
            />
            <span className="text-sm group-hover:text-foreground text-muted-foreground transition-colors truncate">
              {(displayNames?.[opt] ?? opt) || "—"}
            </span>
          </label>
        ))}
      </div>
    </div>
  );
}

function parseTarifText(raw: string): { number: number; designation: string; prixVenteTTC: number }[] {
  const result: { number: number; designation: string; prixVenteTTC: number }[] = [];
  for (const line of raw.split("\n").map(l => l.trim()).filter(Boolean)) {
    const parts = line.split(/\t|;/).map(p => p.trim());
    if (parts.length < 3) continue;
    const num = parseInt(parts[0], 10);
    if (isNaN(num)) continue;
    const designation = parts[1];
    const prix = parseFloat(parts[2].replace(",", "."));
    if (!designation || isNaN(prix)) continue;
    result.push({ number: num, designation, prixVenteTTC: prix });
  }
  return result;
}

function parseXlsx(data: ArrayBuffer): { number: number; designation: string; prixVenteTTC: number }[] {
  const wb = XLSX.read(data, { type: "array" });
  const ws = wb.Sheets[wb.SheetNames[0]];
  const rows = XLSX.utils.sheet_to_json<any[]>(ws, { header: 1 });
  const result: { number: number; designation: string; prixVenteTTC: number }[] = [];
  for (const row of rows) {
    if (!row || row.length < 3) continue;
    const num = parseInt(String(row[0]), 10);
    if (isNaN(num)) continue;
    const designation = String(row[1] ?? "").trim();
    const prix = parseFloat(String(row[2] ?? "").replace(",", "."));
    if (!designation || isNaN(prix)) continue;
    result.push({ number: num, designation, prixVenteTTC: prix });
  }
  return result;
}

export default function TarifPage() {
  const { toast } = useToast();

  const [margin, setMargin] = useState<20 | 25>(20);
  const [search, setSearch] = useState("");
  const [activeTab, setActiveTab] = useState<TabId>("all");
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [filters, setFilters] = useState<Filters>(() => readLS("tarif-filters", EMPTY_FILTERS));
  const [favorites, setFavorites] = useState<Set<number>>(() => new Set(readLS<number[]>("tarif-favorites", [])));
  const [sortField, setSortField] = useState<SortField | null>(null);
  const [sortDir, setSortDir] = useState<SortDir>("asc");
  const [page, setPage] = useState(1);
  const [groupBy, setGroupBy] = useState<GroupBy>("none");
  const [showNormalized, setShowNormalized] = useState(false);

  const [importOpen, setImportOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [importText, setImportText] = useState("");
  const [replaceAll, setReplaceAll] = useState(false);
  const [preview, setPreview] = useState<{ number: number; designation: string; prixVenteTTC: number }[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => { localStorage.setItem("tarif-filters", JSON.stringify(filters)); }, [filters]);
  useEffect(() => { localStorage.setItem("tarif-favorites", JSON.stringify([...favorites])); }, [favorites]);

  const { data: rawRows = [], isLoading } = useQuery<ProductPrice[]>({
    queryKey: ["/api/product-prices"],
    queryFn: () => fetch("/api/product-prices", { credentials: "include" }).then(r => r.json()),
  });

  const importMutation = useMutation({
    mutationFn: (data: { rows: typeof preview; replace: boolean }) =>
      apiRequest("POST", "/api/product-prices/import", data),
    onSuccess: (res: any) => {
      toast({ title: `${res.imported ?? "?"} articles importés` });
      queryClient.invalidateQueries({ queryKey: ["/api/product-prices"] });
      setImportOpen(false); setImportText(""); setPreview([]);
    },
    onError: () => toast({ title: "Erreur d'importation", variant: "destructive" }),
  });

  const deleteMutation = useMutation({
    mutationFn: () => apiRequest("DELETE", "/api/product-prices"),
    onSuccess: () => {
      toast({ title: "Tarif vidé" });
      queryClient.invalidateQueries({ queryKey: ["/api/product-prices"] });
      setDeleteOpen(false);
    },
    onError: () => toast({ title: "Erreur", variant: "destructive" }),
  });

  const enrichedRows = useMemo(() => rawRows.map(r => enrichProduct(r as any)), [rawRows]);

  const uniqueValues = useMemo(() => {
    const families = [...new Set(enrichedRows.map(r => r.family).filter(Boolean))].sort();
    const models = [...new Set(enrichedRows.map(r => r.model).filter(Boolean))].sort();
    const displacements = [...new Set(enrichedRows.map(r => r.displacement).filter(Boolean))].sort((a, b) => parseInt(a) - parseInt(b));
    const categories = [...new Set(enrichedRows.map(r => r.category).filter(Boolean))].sort();
    const colors = [...new Set(enrichedRows.map(r => r.color).filter(Boolean))].sort();
    return { families, models, displacements, categories, colors };
  }, [enrichedRows]);

  const filteredRows = useMemo(() => {
    const multiplier = 1 + margin / 100;
    const q = search.trim().toLowerCase();
    return enrichedRows.filter(r => {
      if (activeTab === "favorites" && !favorites.has(r.id)) return false;
      if (activeTab !== "all" && activeTab !== "favorites" && r.family !== activeTab) return false;
      if (filters.families.length && !filters.families.includes(r.family)) return false;
      if (filters.models.length && !filters.models.includes(r.model)) return false;
      if (filters.displacements.length && !filters.displacements.includes(r.displacement)) return false;
      if (filters.categories.length && !filters.categories.includes(r.category)) return false;
      if (filters.colors.length && !filters.colors.includes(r.color)) return false;
      if (q && !r.searchText.toLowerCase().includes(q)) return false;
      return true;
    });
  }, [enrichedRows, activeTab, favorites, filters, search, margin]);

  const sortedRows = useMemo(() => {
    if (!sortField) return filteredRows;
    const multiplier = 1 + margin / 100;
    return [...filteredRows].sort((a, b) => {
      let va: any, vb: any;
      if (sortField === "number") { va = a.number; vb = b.number; }
      else if (sortField === "designation") { va = showNormalized ? a.normalizedName : a.designation; vb = showNormalized ? b.normalizedName : b.designation; }
      else if (sortField === "family") { va = a.family; vb = b.family; }
      else if (sortField === "model") { va = a.model; vb = b.model; }
      else if (sortField === "category") { va = a.category; vb = b.category; }
      else if (sortField === "displacement") { va = parseInt(a.displacement) || 0; vb = parseInt(b.displacement) || 0; }
      else if (sortField === "base") { va = a.prixVenteTTC; vb = b.prixVenteTTC; }
      else if (sortField === "selling") { va = a.prixVenteTTC * multiplier; vb = b.prixVenteTTC * multiplier; }
      if (typeof va === "string") return sortDir === "asc" ? va.localeCompare(vb) : vb.localeCompare(va);
      return sortDir === "asc" ? va - vb : vb - va;
    });
  }, [filteredRows, sortField, sortDir, margin, showNormalized]);

  const flatItems = useMemo((): FlatItem[] => {
    if (groupBy === "none") return sortedRows.map(p => ({ type: "row", product: p }));
    const groups = new Map<string, EnrichedProduct[]>();
    for (const p of sortedRows) {
      const key = groupBy === "family" ? (p.family || "Sans famille")
        : groupBy === "category" ? (p.category || "Autre")
          : (p.model || "Sans modèle");
      if (!groups.has(key)) groups.set(key, []);
      groups.get(key)!.push(p);
    }
    const flat: FlatItem[] = [];
    for (const [label, products] of [...groups.entries()].sort(([a], [b]) => a.localeCompare(b))) {
      flat.push({ type: "header", label, count: products.length });
      for (const p of products) flat.push({ type: "row", product: p });
    }
    return flat;
  }, [sortedRows, groupBy]);

  const totalPages = Math.max(1, Math.ceil(flatItems.length / PAGE_SIZE));
  const safePage = Math.min(page, totalPages);
  const paginatedItems = flatItems.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);

  const activeFilterCount = filters.families.length + filters.models.length + filters.displacements.length + filters.categories.length + filters.colors.length;

  const toggleFavorite = useCallback((id: number) => {
    setFavorites(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  }, []);

  function handleSort(field: SortField) {
    if (sortField === field) setSortDir(d => d === "asc" ? "desc" : "asc");
    else { setSortField(field); setSortDir("asc"); }
    setPage(1);
  }

  function handleSearch(val: string) { setSearch(val); setPage(1); }
  function handleTab(tab: TabId) { setActiveTab(tab); setPage(1); }

  const handleFileUpload = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const ext = file.name.split(".").pop()?.toLowerCase();
    if (ext === "xlsx" || ext === "xls") {
      const reader = new FileReader();
      reader.onload = ev => {
        const data = ev.target?.result as ArrayBuffer;
        const parsed = parseXlsx(data);
        setImportText(`${parsed.length} lignes depuis Excel`);
        setPreview(parsed);
      };
      reader.readAsArrayBuffer(file);
    } else {
      const reader = new FileReader();
      reader.onload = ev => {
        const text = ev.target?.result as string;
        setImportText(text);
        setPreview(parseTarifText(text));
      };
      reader.readAsText(file, "utf-8");
    }
    e.target.value = "";
  }, []);

  function handleExport() {
    const multiplier = 1 + margin / 100;
    const header = ["ID", "N°", "Désignation", "Désignation normalisée", "Famille", "Modèle", "Cylindrée", "Catégorie", "Couleur", "Variante", "Prix de base", "Marge %", "Prix de vente"];
    const csvRows = [header, ...filteredRows.map(r => [
      r.id, r.number,
      `"${r.designation.replace(/"/g, '""')}"`,
      `"${r.normalizedName.replace(/"/g, '""')}"`,
      r.family, r.model, r.displacement, r.category, r.color, r.variant,
      r.prixVenteTTC.toFixed(3), `${margin}%`,
      (r.prixVenteTTC * multiplier).toFixed(3),
    ])];
    const csv = csvRows.map(r => r.join(",")).join("\n");
    const blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url; a.download = `prix_vente_enrichi_${margin}pct.csv`; a.click();
    URL.revokeObjectURL(url);
    toast({ title: `Export CSV — ${filteredRows.length} articles` });
  }

  const thCls = "cursor-pointer select-none hover:bg-muted/60 transition-colors whitespace-nowrap";
  const multiplier = 1 + margin / 100;

  const tabs: { id: TabId; label: string }[] = [
    { id: "all", label: "Tous" },
    ...FAMILIES.map(f => ({ id: f as TabId, label: FAMILY_DISPLAY_NAMES[f] ?? f })),
    { id: "favorites", label: "★ Favoris" },
  ];

  return (
    <Dashboard contentOnly={true}>
      <div className="flex h-full min-h-screen bg-background">

        {/* Sidebar */}
        {sidebarOpen && (
          <aside className="hidden md:flex flex-col w-56 shrink-0 border-r bg-muted/20 p-4 gap-4 overflow-y-auto">
            <div className="flex items-center justify-between">
              <span className="text-sm font-semibold">Filtres</span>
              {activeFilterCount > 0 && (
                <button
                  onClick={() => setFilters(EMPTY_FILTERS)}
                  className="text-xs text-indigo-600 hover:underline"
                  data-testid="button-clear-filters"
                >
                  Effacer ({activeFilterCount})
                </button>
              )}
            </div>
            <FilterSection
              title="Famille"
              options={uniqueValues.families}
              selected={filters.families}
              onChange={v => { setFilters(f => ({ ...f, families: v })); setPage(1); }}
              displayNames={FAMILY_DISPLAY_NAMES}
            />
            <FilterSection
              title="Cylindrée"
              options={uniqueValues.displacements}
              selected={filters.displacements}
              onChange={v => { setFilters(f => ({ ...f, displacements: v })); setPage(1); }}
            />
            <FilterSection
              title="Catégorie"
              options={uniqueValues.categories}
              selected={filters.categories}
              onChange={v => { setFilters(f => ({ ...f, categories: v })); setPage(1); }}
            />
            <FilterSection
              title="Couleur"
              options={uniqueValues.colors}
              selected={filters.colors}
              onChange={v => { setFilters(f => ({ ...f, colors: v })); setPage(1); }}
            />
            <FilterSection
              title="Modèle"
              options={uniqueValues.models}
              selected={filters.models}
              onChange={v => { setFilters(f => ({ ...f, models: v })); setPage(1); }}
            />
          </aside>
        )}

        {/* Main content */}
        <div className="flex-1 min-w-0 flex flex-col p-4 md:p-5 gap-3 overflow-hidden">

          {/* Header */}
          <div className="flex flex-wrap items-center justify-between gap-2">
            <div className="flex items-center gap-2 flex-wrap">
              <button
                onClick={() => setSidebarOpen(o => !o)}
                className="hidden md:flex items-center justify-center w-8 h-8 rounded-md hover:bg-muted transition-colors"
                data-testid="button-toggle-sidebar"
                title="Afficher/masquer les filtres"
              >
                <SlidersHorizontal className="w-4 h-4" />
              </button>
              <Tag className="w-5 h-5 text-indigo-600" />
              <h1 className="text-lg font-bold">Tarif Pièces</h1>
              <Badge variant="secondary">
                {isLoading ? "…" : `${rawRows.length.toLocaleString()} articles`}
              </Badge>
              {!isLoading && filteredRows.length !== rawRows.length && (
                <Badge variant="outline" className="text-xs">{filteredRows.length.toLocaleString()} résultats</Badge>
              )}
            </div>

            {/* Right controls */}
            <div className="flex items-center gap-2 flex-wrap">
              {/* Margin toggle */}
              <div className="flex items-center gap-1 bg-muted/50 border rounded-lg p-0.5">
                <Percent className="w-3.5 h-3.5 ml-1.5 text-muted-foreground" />
                <span className="text-xs text-muted-foreground font-medium px-1">Marge :</span>
                {([20, 25] as const).map(m => (
                  <button
                    key={m}
                    onClick={() => setMargin(m)}
                    data-testid={`button-margin-${m}`}
                    className={`px-2.5 py-1 rounded-md text-sm font-semibold transition-all ${margin === m
                        ? "bg-white dark:bg-zinc-800 shadow text-indigo-700 dark:text-indigo-400 border border-indigo-200 dark:border-indigo-700"
                        : "text-muted-foreground hover:text-foreground"
                      }`}
                  >
                    +{m}%
                  </button>
                ))}
              </div>

              {/* Export */}
              <Button size="sm" variant="outline" className="gap-1.5" onClick={handleExport} data-testid="button-export-tarif">
                <Download className="w-4 h-4" /> Exporter
              </Button>

              {/* Import */}
              <Dialog open={importOpen} onOpenChange={setImportOpen}>
                <DialogTrigger asChild>
                  <Button size="sm" className="gap-1.5" data-testid="button-import-tarif">
                    <Upload className="w-4 h-4" /> Importer
                  </Button>
                </DialogTrigger>
                <DialogContent className="max-w-2xl">
                  <DialogHeader>
                    <DialogTitle>Importer le tarif</DialogTitle>
                    <DialogDescription>
                      CSV, TSV, TXT ou Excel (.xlsx/.xls) — colonnes : N · Désignation · Prix TTC
                    </DialogDescription>
                  </DialogHeader>
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 flex-wrap">
                      <Button size="sm" variant="outline" onClick={() => fileInputRef.current?.click()} className="gap-1.5">
                        <Upload className="w-4 h-4" /> Charger fichier
                      </Button>
                      <input ref={fileInputRef} type="file" accept=".csv,.tsv,.txt,.xlsx,.xls" className="hidden" onChange={handleFileUpload} data-testid="input-file-tarif" />
                      <label className="flex items-center gap-1.5 text-sm cursor-pointer select-none">
                        <input type="checkbox" checked={replaceAll} onChange={e => setReplaceAll(e.target.checked)} className="rounded" data-testid="checkbox-replace-tarif" />
                        Remplacer tout le tarif existant
                      </label>
                    </div>
                    <textarea
                      className="w-full h-40 border rounded-md p-2 text-xs font-mono resize-none focus:outline-none focus:ring-2 focus:ring-indigo-400 bg-background"
                      placeholder={"1\tBAVETTE BOOSTER 2004\t9.261\n2\tAFFICHEUR TEMPERATURE\t9.959\n..."}
                      value={importText}
                      onChange={e => { setImportText(e.target.value); setPreview(parseTarifText(e.target.value)); }}
                      data-testid="textarea-import-tarif"
                    />
                    {preview.length > 0 && (
                      <div className="text-sm bg-muted/40 rounded-md px-3 py-2 border text-muted-foreground">
                        <span className="font-semibold text-foreground">{preview.length}</span> lignes détectées
                        {replaceAll && <span className="ml-2 text-orange-600 font-medium">· Le tarif existant sera supprimé</span>}
                      </div>
                    )}
                    <div className="flex justify-end gap-2">
                      <Button variant="outline" onClick={() => { setImportOpen(false); setImportText(""); setPreview([]); }}>Annuler</Button>
                      <Button
                        disabled={preview.length === 0 || importMutation.isPending}
                        onClick={() => importMutation.mutate({ rows: preview, replace: replaceAll })}
                        data-testid="button-confirm-import"
                      >
                        {importMutation.isPending ? "Importation…" : `Importer ${preview.length} articles`}
                      </Button>
                    </div>
                  </div>
                </DialogContent>
              </Dialog>

              {/* Delete */}
              <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
                <DialogTrigger asChild>
                  <Button size="sm" variant="outline" className="gap-1.5 text-destructive border-destructive/40 hover:bg-destructive/5" data-testid="button-delete-tarif">
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </DialogTrigger>
                <DialogContent className="max-w-sm">
                  <DialogHeader>
                    <DialogTitle className="flex items-center gap-2">
                      <AlertTriangle className="w-4 h-4 text-destructive" /> Confirmer la suppression
                    </DialogTitle>
                  </DialogHeader>
                  <p className="text-sm text-muted-foreground">Cette action supprime <strong>tous</strong> les articles. Êtes-vous sûr ?</p>
                  <div className="flex justify-end gap-2 pt-2">
                    <Button variant="outline" onClick={() => setDeleteOpen(false)}>Annuler</Button>
                    <Button variant="destructive" onClick={() => deleteMutation.mutate()} disabled={deleteMutation.isPending} data-testid="button-confirm-delete-tarif">
                      Supprimer tout
                    </Button>
                  </div>
                </DialogContent>
              </Dialog>
            </div>
          </div>

          {/* Quick tabs */}
          <div className="flex items-center gap-1.5 flex-wrap">
            {tabs.map(tab => (
              <button
                key={tab.id}
                onClick={() => handleTab(tab.id)}
                data-testid={`tab-${tab.id}`}
                className={`px-3 py-1 rounded-full text-sm font-medium transition-all border ${activeTab === tab.id
                    ? "bg-indigo-600 text-white border-indigo-600 shadow-sm"
                    : "bg-background text-muted-foreground border-border hover:border-indigo-300 hover:text-foreground"
                  }`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* Toolbar: search + grouping + toggle */}
          <div className="flex flex-wrap items-center gap-2">
            <div className="relative flex-1 min-w-48 max-w-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder="Rechercher…"
                className="pl-9 pr-9"
                value={search}
                onChange={e => handleSearch(e.target.value)}
                data-testid="input-search-tarif"
              />
              {search && (
                <button className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground" onClick={() => handleSearch("")} data-testid="button-clear-search">
                  <X className="w-3.5 h-3.5" />
                </button>
              )}
            </div>

            {/* Group by */}
            <div className="flex items-center gap-1 text-sm">
              <Layers className="w-4 h-4 text-muted-foreground" />
              <span className="text-muted-foreground text-xs">Grouper :</span>
              {([["none", "Aucun"], ["family", "Famille"], ["category", "Catégorie"], ["model", "Modèle"]] as [GroupBy, string][]).map(([val, label]) => (
                <button
                  key={val}
                  onClick={() => { setGroupBy(val); setPage(1); }}
                  data-testid={`group-${val}`}
                  className={`px-2 py-0.5 rounded text-xs font-medium transition-all border ${groupBy === val ? "bg-indigo-100 dark:bg-indigo-900/40 text-indigo-700 dark:text-indigo-300 border-indigo-200 dark:border-indigo-700" : "border-transparent text-muted-foreground hover:text-foreground"}`}
                >
                  {label}
                </button>
              ))}
            </div>

            {/* Toggle name */}
            <button
              onClick={() => setShowNormalized(n => !n)}
              data-testid="button-toggle-name"
              className="flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors"
            >
              {showNormalized ? <ToggleRight className="w-4 h-4 text-indigo-500" /> : <ToggleLeft className="w-4 h-4" />}
              Nom {showNormalized ? "normalisé" : "original"}
            </button>
          </div>

          {/* Table */}
          <Card className="flex-1 overflow-hidden">
            <CardContent className="p-0 h-full flex flex-col">
              {isLoading ? (
                <div className="flex flex-col items-center justify-center flex-1 gap-3 text-muted-foreground text-sm">
                  <div className="w-6 h-6 border-2 border-indigo-400 border-t-transparent rounded-full animate-spin" />
                  Chargement du tarif…
                </div>
              ) : rawRows.length === 0 ? (
                <div className="flex flex-col items-center justify-center flex-1 text-muted-foreground text-sm gap-2">
                  <Tag className="w-8 h-8 opacity-30" />
                  Le tarif est vide — importez vos données
                </div>
              ) : filteredRows.length === 0 ? (
                <div className="flex flex-col items-center justify-center flex-1 text-muted-foreground text-sm gap-2">
                  <Search className="w-8 h-8 opacity-30" />
                  Aucun article trouvé
                </div>
              ) : (
                <>
                  <div className="flex-1 overflow-auto min-h-0">
                    <Table>
                      <TableHeader>
                        <TableRow className="bg-muted/40 text-xs">
                          <TableHead className="w-8 text-center">★</TableHead>
                          <TableHead className={`w-12 text-center ${thCls}`} onClick={() => handleSort("number")}>
                            <span className="flex items-center justify-center">N° <SortIcon field="number" current={sortField} dir={sortDir} /></span>
                          </TableHead>
                          <TableHead className={`${thCls}`} onClick={() => handleSort("designation")}>
                            <span className="flex items-center">Désignation <SortIcon field="designation" current={sortField} dir={sortDir} /></span>
                          </TableHead>
                          <TableHead className={`${thCls} w-24`} onClick={() => handleSort("family")}>
                            <span className="flex items-center">Famille <SortIcon field="family" current={sortField} dir={sortDir} /></span>
                          </TableHead>
                          <TableHead className={`${thCls} w-20`} onClick={() => handleSort("displacement")}>
                            <span className="flex items-center">Cylin. <SortIcon field="displacement" current={sortField} dir={sortDir} /></span>
                          </TableHead>
                          <TableHead className={`${thCls} w-32`} onClick={() => handleSort("category")}>
                            <span className="flex items-center">Catégorie <SortIcon field="category" current={sortField} dir={sortDir} /></span>
                          </TableHead>
                          <TableHead className={`${thCls} text-right w-28`} onClick={() => handleSort("base")}>
                            <span className="flex items-center justify-end">Base (DT) <SortIcon field="base" current={sortField} dir={sortDir} /></span>
                          </TableHead>
                          <TableHead className={`${thCls} text-right w-28`} onClick={() => handleSort("selling")}>
                            <span className="flex items-center justify-end">+{margin}% (DT) <SortIcon field="selling" current={sortField} dir={sortDir} /></span>
                          </TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {paginatedItems.map((item, idx) => {
                          if (item.type === "header") {
                            return (
                              <TableRow key={`h-${idx}`} className="bg-muted/60 hover:bg-muted/60">
                                <TableCell colSpan={8} className="py-1.5 px-4">
                                  <span className="text-xs font-bold uppercase tracking-wider text-muted-foreground">
                                    {item.label}
                                    <span className="ml-2 font-normal normal-case">({item.count} articles)</span>
                                  </span>
                                </TableCell>
                              </TableRow>
                            );
                          }
                          const row = item.product;
                          const isFav = favorites.has(row.id);
                          const selling = row.prixVenteTTC * multiplier;
                          return (
                            <TableRow key={row.id} className="hover:bg-muted/30 transition-colors text-sm" data-testid={`row-tarif-${row.id}`}>
                              <TableCell className="text-center w-8 p-1">
                                <button
                                  onClick={() => toggleFavorite(row.id)}
                                  data-testid={`btn-fav-${row.id}`}
                                  className="transition-all hover:scale-110"
                                >
                                  <Star className={`w-3.5 h-3.5 ${isFav ? "fill-yellow-400 text-yellow-400" : "text-muted-foreground/40 hover:text-yellow-300"}`} />
                                </button>
                              </TableCell>
                              <TableCell className="text-center text-muted-foreground text-xs font-mono">{row.number}</TableCell>
                              <TableCell className="font-medium max-w-xs">
                                <div className="truncate" title={showNormalized ? row.normalizedName : row.designation}>
                                  {showNormalized ? row.normalizedName : row.designation}
                                </div>
                                {row.variant && (
                                  <span className="text-[10px] text-muted-foreground">{row.variant}</span>
                                )}
                              </TableCell>
                              <TableCell>
                                <FamilyBadge family={row.family} />
                              </TableCell>
                              <TableCell>
                                {row.displacement
                                  ? <span className="text-xs font-mono border rounded px-1.5 py-0.5">{row.displacement}</span>
                                  : <span className="text-muted-foreground/40">—</span>}
                              </TableCell>
                              <TableCell>
                                <CategoryBadge category={row.category} />
                              </TableCell>
                              <TableCell className="text-right font-mono text-sm text-muted-foreground">
                                {fmt(row.prixVenteTTC)}
                              </TableCell>
                              <TableCell className="text-right font-mono text-sm font-semibold text-emerald-700 dark:text-emerald-400">
                                {fmt(selling)}
                              </TableCell>
                            </TableRow>
                          );
                        })}
                      </TableBody>
                    </Table>
                  </div>

                  {/* Pagination */}
                  {totalPages > 1 && (
                    <div className="flex items-center justify-between px-4 py-2.5 border-t bg-muted/10 text-xs">
                      <span className="text-muted-foreground">
                        Page <span className="font-semibold text-foreground">{safePage}</span> / {totalPages}
                        <span className="ml-2 text-muted-foreground/70">({filteredRows.length.toLocaleString()} articles)</span>
                      </span>
                      <div className="flex items-center gap-1">
                        <Button variant="outline" size="sm" className="h-7 w-7 p-0" disabled={safePage <= 1} onClick={() => setPage(1)} data-testid="button-first-page">
                          <ChevronLeft className="w-3 h-3" /><ChevronLeft className="w-3 h-3 -ml-2" />
                        </Button>
                        <Button variant="outline" size="sm" className="h-7 w-7 p-0" disabled={safePage <= 1} onClick={() => setPage(p => Math.max(1, p - 1))} data-testid="button-prev-page">
                          <ChevronLeft className="w-4 h-4" />
                        </Button>
                        {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                          let p: number;
                          if (totalPages <= 5) p = i + 1;
                          else if (safePage <= 3) p = i + 1;
                          else if (safePage >= totalPages - 2) p = totalPages - 4 + i;
                          else p = safePage - 2 + i;
                          return (
                            <Button key={p} variant={p === safePage ? "default" : "outline"} size="sm"
                              className="h-7 w-7 p-0 text-xs" onClick={() => setPage(p)} data-testid={`button-page-${p}`}>
                              {p}
                            </Button>
                          );
                        })}
                        <Button variant="outline" size="sm" className="h-7 w-7 p-0" disabled={safePage >= totalPages} onClick={() => setPage(p => Math.min(totalPages, p + 1))} data-testid="button-next-page">
                          <ChevronRight className="w-4 h-4" />
                        </Button>
                        <Button variant="outline" size="sm" className="h-7 w-7 p-0" disabled={safePage >= totalPages} onClick={() => setPage(totalPages)} data-testid="button-last-page">
                          <ChevronRight className="w-3 h-3" /><ChevronRight className="w-3 h-3 -ml-2" />
                        </Button>
                      </div>
                    </div>
                  )}
                </>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </Dashboard>
  );
}
