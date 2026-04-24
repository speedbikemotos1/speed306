import Dashboard from "@/pages/Dashboard";
import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { queryClient } from "@/lib/queryClient";
import { apiRequest } from "@/lib/queryClient";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { Boxes, Plus, Pencil, Trash2, Search, Package, Tags, Hash } from "lucide-react";

type ProductFamily = { id: number; name: string };
type Product = { id: number; reference: string; designation: string; familyId: number | null; defaultPrice: number; tvaPct: number; availableQty: number; familyName: string | null };
type ProductSerial = { id: number; productId: number; serialNumber: string; purchasePrice: number; status: string; receptionId?: number | null };
type ProductFormState = { reference: string; designation: string; familyId: string; defaultPrice: string; tvaPct: string };

type Tab = "familles" | "produits" | "serials";

// ─── Product Form Fields (MUST be outside ProduitsTab to prevent re-mount on keystroke) ───
function ProductFormFields({ form, setForm, families }: {
  form: ProductFormState;
  setForm: React.Dispatch<React.SetStateAction<ProductFormState>>;
  families: ProductFamily[];
}) {
  return (
    <div className="flex flex-col gap-3">
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="text-xs font-semibold text-gray-600 mb-1 block">Référence</label>
          <Input value={form.reference} onChange={e => setForm(f => ({ ...f, reference: e.target.value }))} placeholder="071" data-testid="input-product-ref" />
        </div>
        <div>
          <label className="text-xs font-semibold text-gray-600 mb-1 block">Famille</label>
          <Select value={form.familyId} onValueChange={v => setForm(f => ({ ...f, familyId: v }))}>
            <SelectTrigger data-testid="select-product-family"><SelectValue placeholder="Choisir..." /></SelectTrigger>
            <SelectContent>{families.map(fam => <SelectItem key={fam.id} value={fam.id.toString()}>{fam.name}</SelectItem>)}</SelectContent>
          </Select>
        </div>
      </div>
      <div>
        <label className="text-xs font-semibold text-gray-600 mb-1 block">Désignation</label>
        <Input value={form.designation} onChange={e => setForm(f => ({ ...f, designation: e.target.value }))} placeholder="BLASTER VERT 125cc" data-testid="input-product-designation" />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="text-xs font-semibold text-gray-600 mb-1 block">Prix vente (HT)</label>
          <Input type="number" value={form.defaultPrice} onChange={e => setForm(f => ({ ...f, defaultPrice: e.target.value }))} placeholder="5440.37" data-testid="input-product-price" />
        </div>
        <div>
          <label className="text-xs font-semibold text-gray-600 mb-1 block">TVA %</label>
          <Input type="number" value={form.tvaPct} onChange={e => setForm(f => ({ ...f, tvaPct: e.target.value }))} placeholder="19" data-testid="input-product-tva" />
        </div>
      </div>
    </div>
  );
}

export default function StockMotosPage() {
  const [tab, setTab] = useState<Tab>("produits");
  const [search, setSearch] = useState("");
  const [filterFamilyId, setFilterFamilyId] = useState<string>("all");
  const [selectedProductId, setSelectedProductId] = useState<number | null>(null);
  const [serialStatusFilter, setSerialStatusFilter] = useState<string>("all");
  const { toast } = useToast();

  const { data: families = [] } = useQuery<ProductFamily[]>({ queryKey: ["/api/product-families"] });
  const { data: products = [] } = useQuery<Product[]>({
    queryKey: ["/api/stock/products", filterFamilyId, search],
    queryFn: () => {
      const params = new URLSearchParams();
      if (filterFamilyId !== "all") params.set("familyId", filterFamilyId);
      if (search) params.set("search", search);
      return fetch(`/api/stock/products?${params}`, { credentials: "include" }).then(r => r.json());
    },
  });
  const { data: serials = [] } = useQuery<ProductSerial[]>({
    queryKey: ["/api/stock/serials", selectedProductId],
    queryFn: () =>
      selectedProductId
        ? fetch(`/api/stock/serials?productId=${selectedProductId}`, { credentials: "include" }).then(r => r.json())
        : Promise.resolve([]),
    enabled: !!selectedProductId,
  });

  const totalAvailable = products.reduce((acc, p) => acc + (p.availableQty ?? 0), 0);
  const filteredSerials = serials.filter(s => serialStatusFilter === "all" || s.status === serialStatusFilter);

  return (
    <Dashboard contentOnly>
      <div className="flex flex-col gap-6 p-6 max-w-7xl mx-auto min-h-screen">
        <header className="flex items-center gap-4">
          <div className="p-3 bg-gradient-to-br from-blue-600 to-blue-800 rounded-2xl shadow-lg ring-4 ring-white">
            <Boxes className="w-8 h-8 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-black tracking-tight text-gray-900 uppercase italic">Stock Motos</h1>
            <p className="text-gray-500 font-medium">{totalAvailable} motos disponibles en stock</p>
          </div>
        </header>

        {/* Tabs */}
        <div className="flex gap-1 bg-gray-100 p-1 rounded-xl w-fit">
          {([
            { key: "produits", label: "Produits", icon: <Package className="w-3.5 h-3.5" /> },
            { key: "familles", label: "Familles", icon: <Tags className="w-3.5 h-3.5" /> },
            { key: "serials", label: "Numéros de Série", icon: <Hash className="w-3.5 h-3.5" /> },
          ] as const).map(t => (
            <button
              key={t.key}
              onClick={() => setTab(t.key)}
              className={`flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-bold transition-all ${tab === t.key ? "bg-white shadow text-blue-700" : "text-gray-500 hover:text-gray-700"}`}
            >
              {t.icon}{t.label}
            </button>
          ))}
        </div>

        {tab === "familles" && <FamillesTab families={families} toast={toast} />}
        {tab === "produits" && (
          <ProduitsTab
            products={products}
            families={families}
            search={search}
            setSearch={setSearch}
            filterFamilyId={filterFamilyId}
            setFilterFamilyId={setFilterFamilyId}
            toast={toast}
          />
        )}
        {tab === "serials" && (
          <SerialsTab
            products={products}
            serials={filteredSerials}
            selectedProductId={selectedProductId}
            setSelectedProductId={setSelectedProductId}
            statusFilter={serialStatusFilter}
            setStatusFilter={setSerialStatusFilter}
          />
        )}
      </div>
    </Dashboard>
  );
}

// ─── Familles Tab ─────────────────────────────────────────────────────────────
function FamillesTab({ families, toast }: { families: ProductFamily[]; toast: ReturnType<typeof useToast>["toast"] }) {
  const [showAdd, setShowAdd] = useState(false);
  const [editItem, setEditItem] = useState<ProductFamily | null>(null);
  const [name, setName] = useState("");

  const createMut = useMutation({
    mutationFn: (data: { name: string }) => apiRequest("POST", "/api/product-families", data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/product-families"] }); setShowAdd(false); setName(""); toast({ title: "Famille créée" }); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  const updateMut = useMutation({
    mutationFn: ({ id, data }: { id: number; data: { name: string } }) => apiRequest("PATCH", `/api/product-families/${id}`, data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/product-families"] }); setEditItem(null); toast({ title: "Famille modifiée" }); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  const deleteMut = useMutation({
    mutationFn: (id: number) => apiRequest("DELETE", `/api/product-families/${id}`),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/product-families"] }); toast({ title: "Famille supprimée" }); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  return (
    <div className="flex flex-col gap-4">
      <div className="flex justify-end">
        <Button size="sm" className="gap-1.5" onClick={() => { setShowAdd(true); setName(""); }} data-testid="button-add-famille">
          <Plus className="w-4 h-4" />Nouvelle famille
        </Button>
      </div>
      <div className="grid gap-3 sm:grid-cols-2 md:grid-cols-3">
        {families.map(f => (
          <Card key={f.id} className="rounded-2xl border shadow-sm hover:shadow-md transition-all">
            <CardContent className="flex items-center justify-between p-4">
              <span className="font-bold text-gray-800">{f.name}</span>
              <div className="flex gap-1">
                <Button variant="ghost" size="icon" className="h-8 w-8" onClick={() => { setEditItem(f); setName(f.name); }} data-testid={`button-edit-famille-${f.id}`}><Pencil className="w-3.5 h-3.5" /></Button>
                <Button variant="ghost" size="icon" className="h-8 w-8 text-destructive hover:text-destructive" onClick={() => deleteMut.mutate(f.id)} data-testid={`button-delete-famille-${f.id}`}><Trash2 className="w-3.5 h-3.5" /></Button>
              </div>
            </CardContent>
          </Card>
        ))}
        {families.length === 0 && <p className="text-sm text-gray-400 col-span-3">Aucune famille. Créez-en une pour commencer.</p>}
      </div>

      <Dialog open={showAdd} onOpenChange={setShowAdd}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouvelle famille</DialogTitle></DialogHeader>
          <Input value={name} onChange={e => setName(e.target.value)} placeholder="Nom de la famille" data-testid="input-famille-name" />
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAdd(false)}>Annuler</Button>
            <Button onClick={() => createMut.mutate({ name })} disabled={!name.trim() || createMut.isPending} data-testid="button-save-famille">Créer</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!editItem} onOpenChange={o => !o && setEditItem(null)}>
        <DialogContent>
          <DialogHeader><DialogTitle>Modifier famille</DialogTitle></DialogHeader>
          <Input value={name} onChange={e => setName(e.target.value)} placeholder="Nom de la famille" data-testid="input-famille-name-edit" />
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditItem(null)}>Annuler</Button>
            <Button onClick={() => editItem && updateMut.mutate({ id: editItem.id, data: { name } })} disabled={!name.trim() || updateMut.isPending} data-testid="button-save-famille-edit">Sauvegarder</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ─── Produits Tab ─────────────────────────────────────────────────────────────
function ProduitsTab({ products, families, search, setSearch, filterFamilyId, setFilterFamilyId, toast }: {
  products: Product[]; families: ProductFamily[]; search: string; setSearch: (v: string) => void;
  filterFamilyId: string; setFilterFamilyId: (v: string) => void; toast: ReturnType<typeof useToast>["toast"];
}) {
  const [showAdd, setShowAdd] = useState(false);
  const [editItem, setEditItem] = useState<Product | null>(null);
  const [form, setForm] = useState<ProductFormState>({ reference: "", designation: "", familyId: "", defaultPrice: "", tvaPct: "19" });

  const openAdd = () => { setForm({ reference: "", designation: "", familyId: families[0]?.id.toString() ?? "", defaultPrice: "", tvaPct: "19" }); setShowAdd(true); };
  const openEdit = (p: Product) => { setEditItem(p); setForm({ reference: p.reference, designation: p.designation, familyId: p.familyId?.toString() ?? "", defaultPrice: p.defaultPrice.toString(), tvaPct: p.tvaPct.toString() }); };

  const createMut = useMutation({
    mutationFn: (data: any) => apiRequest("POST", "/api/stock/products", data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/stock/products"] }); setShowAdd(false); toast({ title: "Produit créé" }); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  const updateMut = useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) => apiRequest("PATCH", `/api/stock/products/${id}`, data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/stock/products"] }); setEditItem(null); toast({ title: "Produit modifié" }); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  const deleteMut = useMutation({
    mutationFn: (id: number) => apiRequest("DELETE", `/api/stock/products/${id}`),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/stock/products"] }); toast({ title: "Produit supprimé" }); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  const buildPayload = () => ({
    reference: form.reference,
    designation: form.designation,
    familyId: form.familyId ? Number(form.familyId) : null,
    defaultPrice: Number(form.defaultPrice),
    tvaPct: Number(form.tvaPct),
  });

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-center gap-3 justify-between">
        <div className="flex items-center gap-2 flex-1 min-w-0">
          <div className="relative flex-1 max-w-xs">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input className="pl-9" placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} data-testid="input-search-product" />
          </div>
          <Select value={filterFamilyId} onValueChange={setFilterFamilyId}>
            <SelectTrigger className="w-40" data-testid="select-filter-family"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Toutes familles</SelectItem>
              {families.filter(f => f.name !== 'Casques').map(f => <SelectItem key={f.id} value={f.id.toString()}>{f.name}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <Button size="sm" className="gap-1.5" onClick={openAdd} data-testid="button-add-product"><Plus className="w-4 h-4" />Nouveau produit</Button>
      </div>

      <div className="overflow-x-auto rounded-2xl border shadow-sm bg-white">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 border-b">
            <tr>{["Réf.", "Désignation", "Famille", "Prix HT", "TVA", "Stock dispo", ""].map(h => <th key={h} className="px-4 py-3 text-left text-xs font-black text-gray-500 uppercase tracking-wide">{h}</th>)}</tr>
          </thead>
          <tbody>
            {products.map(p => (
              <tr key={p.id} className="border-b last:border-0 hover:bg-gray-50 transition-colors" data-testid={`row-product-${p.id}`}>
                <td className="px-4 py-3 font-mono font-bold text-blue-700">{p.reference}</td>
                <td className="px-4 py-3 font-semibold text-gray-800">{p.designation}</td>
                <td className="px-4 py-3 text-gray-500">{p.familyName ?? "—"}</td>
                <td className="px-4 py-3 font-mono">{p.defaultPrice?.toLocaleString("fr-TN", { minimumFractionDigits: 3 })} TND</td>
                <td className="px-4 py-3 text-gray-500">{p.tvaPct}%</td>
                <td className="px-4 py-3">
                  <Badge variant="secondary" className={p.availableQty > 0 ? "bg-green-100 text-green-800 hover:bg-green-100" : ""} data-testid={`text-stock-${p.id}`}>
                    {p.availableQty} dispo
                  </Badge>
                </td>
                <td className="px-4 py-3">
                  <div className="flex gap-1">
                    <Button variant="ghost" size="icon" className="h-7 w-7" onClick={() => openEdit(p)} data-testid={`button-edit-product-${p.id}`}><Pencil className="w-3 h-3" /></Button>
                    <Button variant="ghost" size="icon" className="h-7 w-7 text-destructive hover:text-destructive" onClick={() => deleteMut.mutate(p.id)} data-testid={`button-delete-product-${p.id}`}><Trash2 className="w-3 h-3" /></Button>
                  </div>
                </td>
              </tr>
            ))}
            {products.length === 0 && <tr><td colSpan={7} className="px-4 py-8 text-center text-gray-400">Aucun produit trouvé.</td></tr>}
          </tbody>
        </table>
      </div>

      <Dialog open={showAdd} onOpenChange={setShowAdd}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouveau produit</DialogTitle></DialogHeader>
          <ProductFormFields form={form} setForm={setForm} families={families} />
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowAdd(false)}>Annuler</Button>
            <Button onClick={() => createMut.mutate(buildPayload())} disabled={!form.reference || !form.designation || createMut.isPending} data-testid="button-save-product">Créer</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      <Dialog open={!!editItem} onOpenChange={o => !o && setEditItem(null)}>
        <DialogContent>
          <DialogHeader><DialogTitle>Modifier produit</DialogTitle></DialogHeader>
          <ProductFormFields form={form} setForm={setForm} families={families} />
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditItem(null)}>Annuler</Button>
            <Button onClick={() => editItem && updateMut.mutate({ id: editItem.id, data: buildPayload() })} disabled={!form.reference || !form.designation || updateMut.isPending} data-testid="button-save-product-edit">Sauvegarder</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ─── Serials Tab ──────────────────────────────────────────────────────────────
function SerialsTab({ products, serials, selectedProductId, setSelectedProductId, statusFilter, setStatusFilter }: {
  products: Product[]; serials: ProductSerial[]; selectedProductId: number | null;
  setSelectedProductId: (id: number | null) => void; statusFilter: string; setStatusFilter: (v: string) => void;
}) {
  const selectedProduct = products.find(p => p.id === selectedProductId);
  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap gap-3">
        <Select value={selectedProductId?.toString() ?? ""} onValueChange={v => setSelectedProductId(v ? Number(v) : null)}>
          <SelectTrigger className="w-64" data-testid="select-serial-product"><SelectValue placeholder="Choisir un produit..." /></SelectTrigger>
          <SelectContent>{products.map(p => <SelectItem key={p.id} value={p.id.toString()}>{p.reference} — {p.designation}</SelectItem>)}</SelectContent>
        </Select>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-40" data-testid="select-serial-status"><SelectValue /></SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous statuts</SelectItem>
            <SelectItem value="available">Disponible</SelectItem>
            <SelectItem value="reserved">Réservé</SelectItem>
            <SelectItem value="sold">Vendu</SelectItem>
          </SelectContent>
        </Select>
      </div>
      {selectedProduct && <p className="text-sm font-semibold text-gray-600">{selectedProduct.designation} — {serials.length} résultat(s)</p>}
      <div className="overflow-x-auto rounded-2xl border shadow-sm bg-white">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 border-b">
            <tr>{["Numéro de série", "Prix achat", "Statut", "Réception"].map(h => <th key={h} className="px-4 py-3 text-left text-xs font-black text-gray-500 uppercase tracking-wide">{h}</th>)}</tr>
          </thead>
          <tbody>
            {serials.map(s => (
              <tr key={s.id} className="border-b last:border-0 hover:bg-gray-50" data-testid={`row-serial-${s.id}`}>
                <td className="px-4 py-3 font-mono font-bold text-gray-800">{s.serialNumber}</td>
                <td className="px-4 py-3 font-mono">{s.purchasePrice ? s.purchasePrice.toLocaleString("fr-TN", { minimumFractionDigits: 3 }) + " TND" : "—"}</td>
                <td className="px-4 py-3">
                  <Badge variant="secondary" className={
                    s.status === "available" ? "bg-green-100 text-green-800 hover:bg-green-100" :
                    s.status === "sold" ? "bg-red-100 text-red-800 hover:bg-red-100" :
                    "bg-yellow-100 text-yellow-800 hover:bg-yellow-100"
                  } data-testid={`status-serial-${s.id}`}>
                    {s.status === "available" ? "Disponible" : s.status === "sold" ? "Vendu" : "Réservé"}
                  </Badge>
                </td>
                <td className="px-4 py-3 text-gray-400 text-xs">{s.receptionId ? `BR #${s.receptionId}` : "Importé"}</td>
              </tr>
            ))}
            {!selectedProductId && <tr><td colSpan={4} className="px-4 py-8 text-center text-gray-400">Sélectionnez un produit pour voir ses numéros de série.</td></tr>}
            {selectedProductId && serials.length === 0 && <tr><td colSpan={4} className="px-4 py-8 text-center text-gray-400">Aucun numéro de série trouvé.</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  );
}
