import Dashboard from "@/pages/Dashboard";
import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { queryClient } from "@/lib/queryClient";
import { apiRequest } from "@/lib/queryClient";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { Truck, Plus, Trash2, ChevronRight, X, Eye, Pencil } from "lucide-react";
import { useAuth } from "@/hooks/use-auth";

type ProductFamily = { id: number; name: string };
type Product = { id: number; reference: string; designation: string; familyId: number | null; defaultPrice: number; tvaPct: number; availableQty: number };
type Reception = { id: number; bonNumber: string; date: string; fournisseur: string; lines: ReceptionLine[] };
type ReceptionLine = { id: number; productId: number; quantity: number; prix: number; tvaPct: number; remise: number; product: Product | null };

type DraftLine = {
  productId: number;
  reference: string;
  designation: string;
  quantity: number;
  prix: number;
  tvaPct: number;
  remise: number;
  serials: string[];
};

const fmt = (n: number) => n.toLocaleString("fr-TN", { minimumFractionDigits: 3, maximumFractionDigits: 3 });

function calcLine(prix: number, qty: number, tva: number, remise: number) {
  const ht = prix * qty * (1 - remise / 100);
  const tvaAmt = ht * (tva / 100);
  return { ht, tva: tvaAmt, ttc: ht + tvaAmt };
}

export default function ReceptionPage() {
  const [view, setView] = useState<"list" | "new" | "detail" | "edit">("list");
  const [detailId, setDetailId] = useState<number | null>(null);
  const { toast } = useToast();
  const { user } = useAuth();
  const isManager = user?.role === "manager";

  const { data: families = [] } = useQuery<ProductFamily[]>({ queryKey: ["/api/product-families"] });
  const { data: products = [] } = useQuery<Product[]>({ queryKey: ["/api/stock/products"] });
  const { data: receptions = [], isLoading } = useQuery<Reception[]>({ queryKey: ["/api/receptions"] });
  const { data: nextNumber } = useQuery<{ bonNumber: string }>({ queryKey: ["/api/receptions/next-number"] });

  const deleteMut = useMutation({
    mutationFn: (id: number) => apiRequest("DELETE", `/api/receptions/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/receptions"] });
      queryClient.invalidateQueries({ queryKey: ["/api/stock/products"] });
      queryClient.invalidateQueries({ queryKey: ["/api/receptions/next-number"] });
      setView("list");
      setDetailId(null);
      toast({ title: "Bon supprimé", description: "La réception et ses numéros de série ont été supprimés." });
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  return (
    <Dashboard contentOnly>
      <div className="flex flex-col gap-6 p-6 max-w-7xl mx-auto min-h-screen">
        <header className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-gradient-to-br from-orange-500 to-orange-700 rounded-2xl shadow-lg ring-4 ring-white">
              <Truck className="w-8 h-8 text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-black tracking-tight text-gray-900 uppercase italic">Bon de Réception</h1>
              <p className="text-gray-500 font-medium">Réception de stock — {receptions.length} bon(s) enregistré(s)</p>
            </div>
          </div>
          {view === "list" && (
            <Button className="gap-1.5" onClick={() => setView("new")} data-testid="button-new-reception">
              <Plus className="w-4 h-4" />Nouveau BR
            </Button>
          )}
          {view !== "list" && (
            <Button variant="outline" onClick={() => { setView("list"); setDetailId(null); }} data-testid="button-back-list">
              ← Retour à la liste
            </Button>
          )}
        </header>

        {view === "list" && (
          <ReceptionList
            receptions={receptions}
            isLoading={isLoading}
            onView={id => { setDetailId(id); setView("detail"); }}
            onEdit={id => { setDetailId(id); setView("edit"); }}
            onDelete={id => deleteMut.mutate(id)}
            isDeleting={deleteMut.isPending}
            isManager={isManager}
          />
        )}
        {view === "new" && (
          <ReceptionForm
            families={families}
            products={products}
            nextNumber={nextNumber?.bonNumber ?? ""}
            toast={toast}
            onSaved={() => {
              queryClient.invalidateQueries({ queryKey: ["/api/receptions"] });
              queryClient.invalidateQueries({ queryKey: ["/api/receptions/next-number"] });
              queryClient.invalidateQueries({ queryKey: ["/api/stock/products"] });
              setView("list");
            }}
          />
        )}
        {view === "detail" && detailId && (
          <ReceptionDetail
            id={detailId}
            onEdit={() => setView("edit")}
            onDelete={() => deleteMut.mutate(detailId)}
            isDeleting={deleteMut.isPending}
            isManager={isManager}
          />
        )}
        {view === "edit" && detailId && (
          <ReceptionEditForm
            id={detailId}
            toast={toast}
            onSaved={() => {
              queryClient.invalidateQueries({ queryKey: ["/api/receptions"] });
              setView("detail");
            }}
          />
        )}
      </div>
    </Dashboard>
  );
}

// ─── List ─────────────────────────────────────────────────────────────────────
function ReceptionList({ receptions, isLoading, onView, onEdit, onDelete, isDeleting, isManager }: {
  receptions: Reception[]; isLoading: boolean; onView: (id: number) => void;
  onEdit: (id: number) => void; onDelete: (id: number) => void; isDeleting: boolean; isManager: boolean;
}) {
  const [confirmDelete, setConfirmDelete] = useState<number | null>(null);
  return (
    <div className="overflow-x-auto rounded-2xl border shadow-sm bg-white">
      <table className="w-full text-sm">
        <thead className="bg-gray-50 border-b">
          <tr>{["Bon N°", "Date", "Fournisseur", "Lignes", ""].map(h => <th key={h} className="px-4 py-3 text-left text-xs font-black text-gray-500 uppercase tracking-wide">{h}</th>)}</tr>
        </thead>
        <tbody>
          {isLoading && <tr><td colSpan={5} className="text-center py-8 text-gray-400">Chargement...</td></tr>}
          {!isLoading && receptions.length === 0 && <tr><td colSpan={5} className="text-center py-8 text-gray-400">Aucune réception enregistrée.</td></tr>}
          {receptions.map(r => (
            <tr key={r.id} className="border-b last:border-0 hover:bg-gray-50 transition-colors" data-testid={`row-reception-${r.id}`}>
              <td className="px-4 py-3 font-mono font-bold text-orange-700">{r.bonNumber}</td>
              <td className="px-4 py-3 text-gray-700">{r.date}</td>
              <td className="px-4 py-3 font-semibold">{r.fournisseur || "—"}</td>
              <td className="px-4 py-3"><Badge variant="secondary">{r.lines?.length ?? 0} ligne(s)</Badge></td>
              <td className="px-4 py-3">
                <div className="flex gap-1 justify-end">
                  <Button variant="ghost" size="sm" className="gap-1" onClick={() => onView(r.id)} data-testid={`button-view-reception-${r.id}`}><Eye className="w-3.5 h-3.5" />Voir</Button>
                  {isManager && <Button variant="ghost" size="sm" className="gap-1" onClick={() => onEdit(r.id)} data-testid={`button-edit-reception-${r.id}`}><Pencil className="w-3.5 h-3.5" />Modifier</Button>}
                  {isManager && <Button variant="ghost" size="sm" className="gap-1 text-destructive hover:text-destructive" onClick={() => setConfirmDelete(r.id)} data-testid={`button-delete-reception-${r.id}`}><Trash2 className="w-3.5 h-3.5" />Supprimer</Button>}
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <Dialog open={confirmDelete !== null} onOpenChange={o => !o && setConfirmDelete(null)}>
        <DialogContent>
          <DialogHeader><DialogTitle>Confirmer la suppression</DialogTitle></DialogHeader>
          <p className="text-sm text-gray-600">Cette action supprimera le bon de réception et tous les numéros de série associés (si non vendus). Cette action est irréversible.</p>
          <div className="flex justify-end gap-2 mt-4">
            <Button variant="outline" onClick={() => setConfirmDelete(null)}>Annuler</Button>
            <Button variant="destructive" disabled={isDeleting} onClick={() => { if (confirmDelete) { onDelete(confirmDelete); setConfirmDelete(null); } }} data-testid="button-confirm-delete-reception">
              {isDeleting ? "Suppression..." : "Supprimer"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ─── Form ─────────────────────────────────────────────────────────────────────
function ReceptionForm({ families, products, nextNumber, toast, onSaved }: {
  families: ProductFamily[]; products: Product[]; nextNumber: string;
  toast: ReturnType<typeof useToast>["toast"]; onSaved: () => void;
}) {
  const today = new Date().toLocaleDateString("fr-TN", { day: "2-digit", month: "2-digit", year: "numeric" }).split("/").join("/");
  const [date, setDate] = useState(today);
  const [fournisseur, setFournisseur] = useState("");
  const [lines, setLines] = useState<DraftLine[]>([]);
  const [searchProduct, setSearchProduct] = useState("");
  const [serialModal, setSerialModal] = useState<{ lineIdx: number } | null>(null);
  const [serialInput, setSerialInput] = useState("");

  const filteredProducts = products.filter(p =>
    p.reference.toLowerCase().includes(searchProduct.toLowerCase()) ||
    p.designation.toLowerCase().includes(searchProduct.toLowerCase())
  );

  const addLine = (p: Product) => {
    setLines(prev => [...prev, { productId: p.id, reference: p.reference, designation: p.designation, quantity: 1, prix: p.defaultPrice, tvaPct: p.tvaPct, remise: 0, serials: [] }]);
    setSearchProduct("");
  };

  const updateLine = (idx: number, field: keyof DraftLine, value: any) => {
    setLines(prev => prev.map((l, i) => {
      if (i !== idx) return l;
      const updated = { ...l, [field]: value };
      if (field === "quantity") updated.serials = updated.serials.slice(0, Number(value));
      return updated;
    }));
  };

  const removeLine = (idx: number) => setLines(prev => prev.filter((_, i) => i !== idx));

  const addSerial = (lineIdx: number) => {
    const sn = serialInput.trim().toUpperCase();
    if (!sn) return;
    const line = lines[lineIdx];
    if (line.serials.includes(sn)) { toast({ title: "Doublon", description: "Ce N/S est déjà saisi.", variant: "destructive" }); return; }
    if (line.serials.length >= line.quantity) { toast({ title: "Limite", description: `Max ${line.quantity} N/S pour cette ligne.`, variant: "destructive" }); return; }
    setLines(prev => prev.map((l, i) => i === lineIdx ? { ...l, serials: [...l.serials, sn] } : l));
    setSerialInput("");
  };

  const removeSerial = (lineIdx: number, sn: string) => {
    setLines(prev => prev.map((l, i) => i === lineIdx ? { ...l, serials: l.serials.filter(s => s !== sn) } : l));
  };

  const totals = lines.reduce((acc, l) => {
    const c = calcLine(l.prix, l.quantity, l.tvaPct, l.remise);
    return { ht: acc.ht + c.ht, tva: acc.tva + c.tva, ttc: acc.ttc + c.ttc };
  }, { ht: 0, tva: 0, ttc: 0 });

  const createMut = useMutation({
    mutationFn: async () => {
      const serialsPerLine = lines.map(l => l.serials.map(sn => ({ productId: l.productId, serial: sn, purchasePrice: l.prix })));
      await apiRequest("POST", "/api/receptions", {
        reception: { bonNumber: nextNumber, date, fournisseur },
        lines: lines.map(l => ({ productId: l.productId, quantity: l.quantity, prix: l.prix, tvaPct: l.tvaPct, remise: l.remise })),
        serialsPerLine,
      });
    },
    onSuccess: () => { toast({ title: "Bon de réception créé", description: `${nextNumber} enregistré.` }); onSaved(); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  const canSave = lines.length > 0 && lines.every(l => l.serials.length === l.quantity);

  return (
    <div className="flex flex-col gap-6">
      <Card className="rounded-2xl border shadow-sm">
        <CardHeader className="pb-3"><CardTitle className="text-sm font-black uppercase tracking-wide text-gray-600">En-tête du bon</CardTitle></CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Bon N°</label><Input value={nextNumber} readOnly className="bg-gray-50 font-mono font-bold" data-testid="input-reception-number" /></div>
            <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Date</label><Input value={date} onChange={e => setDate(e.target.value)} placeholder="jj/mm/aaaa" data-testid="input-reception-date" /></div>
            <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Fournisseur</label><Input value={fournisseur} onChange={e => setFournisseur(e.target.value)} placeholder="K TRADING GLOBAL" data-testid="input-reception-fournisseur" /></div>
          </div>
        </CardContent>
      </Card>

      <Card className="rounded-2xl border shadow-sm">
        <CardHeader className="pb-3"><CardTitle className="text-sm font-black uppercase tracking-wide text-gray-600">Ajouter des produits</CardTitle></CardHeader>
        <CardContent>
          <Input value={searchProduct} onChange={e => setSearchProduct(e.target.value)} placeholder="Rechercher par référence ou désignation..." data-testid="input-search-product-reception" />
          {searchProduct && (
            <div className="mt-2 border rounded-xl overflow-hidden max-h-48 overflow-y-auto">
              {filteredProducts.slice(0, 10).map(p => (
                <button key={p.id} onClick={() => addLine(p)} className="w-full flex items-center justify-between px-3 py-2 text-sm hover:bg-blue-50 transition-colors text-left" data-testid={`button-select-product-${p.id}`}>
                  <span><span className="font-mono font-bold text-blue-700 mr-2">{p.reference}</span>{p.designation}</span>
                  <ChevronRight className="w-4 h-4 text-gray-400" />
                </button>
              ))}
              {filteredProducts.length === 0 && <p className="px-3 py-4 text-sm text-gray-400">Aucun produit trouvé.</p>}
            </div>
          )}
        </CardContent>
      </Card>

      {lines.length > 0 && (
        <Card className="rounded-2xl border shadow-sm">
          <CardHeader className="pb-3"><CardTitle className="text-sm font-black uppercase tracking-wide text-gray-600">Lignes du bon</CardTitle></CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead><tr className="border-b">{["Réf.", "Désignation", "Qté", "Prix", "TVA %", "Remise %", "TTC", "N/S saisis", ""].map(h => <th key={h} className="px-2 py-2 text-left text-xs font-bold text-gray-500">{h}</th>)}</tr></thead>
                <tbody>
                  {lines.map((l, idx) => {
                    const c = calcLine(l.prix, l.quantity, l.tvaPct, l.remise);
                    return (
                      <tr key={idx} className="border-b last:border-0" data-testid={`row-reception-line-${idx}`}>
                        <td className="px-2 py-2 font-mono font-bold text-blue-700">{l.reference}</td>
                        <td className="px-2 py-2 text-gray-700 max-w-40 truncate">{l.designation}</td>
                        <td className="px-2 py-2"><Input type="number" min={1} value={l.quantity} onChange={e => updateLine(idx, "quantity", Number(e.target.value))} className="w-16 h-8 text-center" data-testid={`input-line-qty-${idx}`} /></td>
                        <td className="px-2 py-2"><Input type="number" value={l.prix} onChange={e => updateLine(idx, "prix", Number(e.target.value))} className="w-28 h-8" data-testid={`input-line-prix-${idx}`} /></td>
                        <td className="px-2 py-2"><Input type="number" value={l.tvaPct} onChange={e => updateLine(idx, "tvaPct", Number(e.target.value))} className="w-16 h-8 text-center" data-testid={`input-line-tva-${idx}`} /></td>
                        <td className="px-2 py-2"><Input type="number" value={l.remise} onChange={e => updateLine(idx, "remise", Number(e.target.value))} className="w-16 h-8 text-center" data-testid={`input-line-remise-${idx}`} /></td>
                        <td className="px-2 py-2 font-mono font-bold">{fmt(c.ttc)}</td>
                        <td className="px-2 py-2">
                          <div className="flex flex-wrap gap-1 items-center">
                            {l.serials.map(sn => (
                              <span key={sn} className="flex items-center gap-0.5 bg-green-100 text-green-800 text-[10px] font-mono px-1.5 py-0.5 rounded-full">
                                {sn}<button onClick={() => removeSerial(idx, sn)} className="ml-0.5 hover:text-red-600"><X className="w-2.5 h-2.5" /></button>
                              </span>
                            ))}
                            {l.serials.length < l.quantity && (
                              <button onClick={() => { setSerialModal({ lineIdx: idx }); setSerialInput(""); }} className="text-blue-600 text-xs font-bold hover:underline" data-testid={`button-add-serial-${idx}`}>
                                + Ajouter N/S ({l.serials.length}/{l.quantity})
                              </button>
                            )}
                          </div>
                        </td>
                        <td className="px-2 py-2"><Button variant="ghost" size="icon" className="h-7 w-7 text-destructive" onClick={() => removeLine(idx)} data-testid={`button-remove-line-${idx}`}><Trash2 className="w-3.5 h-3.5" /></Button></td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}

      {lines.length > 0 && (
        <div className="flex flex-col sm:flex-row gap-4 items-end justify-between">
          <div className="bg-gray-50 border rounded-2xl p-4 flex gap-8">
            {[{ label: "Montant HT", value: fmt(totals.ht) }, { label: "Montant TVA", value: fmt(totals.tva) }, { label: "Montant TTC", value: fmt(totals.ttc) }].map(t => (
              <div key={t.label}><p className="text-[10px] font-black text-gray-400 uppercase tracking-widest">{t.label}</p><p className="text-xl font-black text-gray-900 font-mono" data-testid={`text-total-${t.label.toLowerCase().replace(/ /g, "-")}`}>{t.value} TND</p></div>
            ))}
          </div>
          <Button size="lg" disabled={!canSave || createMut.isPending} onClick={() => createMut.mutate()} className="gap-2 min-w-40" data-testid="button-save-reception">
            {createMut.isPending ? "Enregistrement..." : "Valider le bon"}
          </Button>
        </div>
      )}
      {lines.length > 0 && !canSave && (
        <p className="text-sm text-amber-600 font-semibold">⚠ Veuillez saisir tous les numéros de série avant de valider.</p>
      )}

      <Dialog open={!!serialModal} onOpenChange={o => !o && setSerialModal(null)}>
        <DialogContent>
          <DialogHeader><DialogTitle>Saisir numéro de série</DialogTitle></DialogHeader>
          {serialModal && (
            <div className="flex flex-col gap-3">
              <p className="text-sm text-gray-600">
                Ligne: <strong>{lines[serialModal.lineIdx]?.designation}</strong> — {lines[serialModal.lineIdx]?.serials.length}/{lines[serialModal.lineIdx]?.quantity} saisis
              </p>
              <div className="flex gap-2">
                <Input value={serialInput} onChange={e => setSerialInput(e.target.value)} onKeyDown={e => e.key === "Enter" && addSerial(serialModal.lineIdx)} placeholder="Ex: LEHTDJ042TRA00037" className="font-mono" data-testid="input-serial-number" autoFocus />
                <Button onClick={() => addSerial(serialModal.lineIdx)} data-testid="button-confirm-serial">Ajouter</Button>
              </div>
              <div className="flex flex-wrap gap-1">
                {lines[serialModal.lineIdx]?.serials.map(sn => (
                  <span key={sn} className="flex items-center gap-1 bg-green-100 text-green-800 text-xs font-mono px-2 py-1 rounded-full">
                    {sn}<button onClick={() => removeSerial(serialModal.lineIdx, sn)}><X className="w-3 h-3" /></button>
                  </span>
                ))}
              </div>
              {lines[serialModal.lineIdx]?.serials.length >= lines[serialModal.lineIdx]?.quantity && (
                <div className="flex justify-end"><Button onClick={() => setSerialModal(null)} data-testid="button-close-serial-modal">Terminer</Button></div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ─── Edit Form (header only) ──────────────────────────────────────────────────
function ReceptionEditForm({ id, toast, onSaved }: { id: number; toast: ReturnType<typeof useToast>["toast"]; onSaved: () => void }) {
  const { data: r, isLoading } = useQuery<Reception>({ queryKey: ["/api/receptions", id] });
  const [date, setDate] = useState("");
  const [fournisseur, setFournisseur] = useState("");
  const [initialized, setInitialized] = useState(false);

  if (r && !initialized) {
    setDate(r.date);
    setFournisseur(r.fournisseur);
    setInitialized(true);
  }

  const updateMut = useMutation({
    mutationFn: () => apiRequest("PATCH", `/api/receptions/${id}`, { date, fournisseur }),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/receptions"] }); queryClient.invalidateQueries({ queryKey: ["/api/receptions", id] }); toast({ title: "Bon modifié" }); onSaved(); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  if (isLoading || !r) return <p className="text-gray-400">Chargement...</p>;

  return (
    <div className="flex flex-col gap-6">
      <Card className="rounded-2xl border shadow-sm">
        <CardHeader className="pb-3"><CardTitle className="text-sm font-black uppercase tracking-wide text-gray-600">Modifier BR N° {r.bonNumber}</CardTitle></CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Date</label><Input value={date} onChange={e => setDate(e.target.value)} placeholder="jj/mm/aaaa" data-testid="input-edit-reception-date" /></div>
            <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Fournisseur</label><Input value={fournisseur} onChange={e => setFournisseur(e.target.value)} placeholder="K TRADING GLOBAL" data-testid="input-edit-reception-fournisseur" /></div>
          </div>
          <div className="flex justify-end mt-4">
            <Button onClick={() => updateMut.mutate()} disabled={updateMut.isPending} data-testid="button-save-reception-edit">
              {updateMut.isPending ? "Enregistrement..." : "Sauvegarder"}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

// ─── Detail ───────────────────────────────────────────────────────────────────
function ReceptionDetail({ id, onEdit, onDelete, isDeleting, isManager }: { id: number; onEdit: () => void; onDelete: () => void; isDeleting: boolean; isManager: boolean }) {
  const [confirmDelete, setConfirmDelete] = useState(false);
  const { data: r, isLoading } = useQuery<Reception>({ queryKey: ["/api/receptions", id] });
  if (isLoading) return <p className="text-gray-400">Chargement...</p>;
  if (!r) return <p className="text-gray-400">Non trouvé.</p>;

  const totals = (r.lines ?? []).reduce((acc, l) => {
    const c = calcLine(l.prix, l.quantity, l.tvaPct, l.remise);
    return { ht: acc.ht + c.ht, tva: acc.tva + c.tva, ttc: acc.ttc + c.ttc };
  }, { ht: 0, tva: 0, ttc: 0 });

  return (
    <div className="flex flex-col gap-6">
      <Card className="rounded-2xl border shadow-sm">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="font-black text-lg text-orange-800">BR N° {r.bonNumber}</CardTitle>
          {isManager && (
            <div className="flex gap-2">
              <Button variant="outline" className="gap-1" onClick={onEdit} data-testid="button-edit-reception-detail"><Pencil className="w-4 h-4" />Modifier</Button>
              <Button variant="outline" className="gap-1 text-destructive border-destructive/30 hover:bg-destructive/5" onClick={() => setConfirmDelete(true)} disabled={isDeleting} data-testid="button-delete-reception-detail"><Trash2 className="w-4 h-4" />Supprimer</Button>
            </div>
          )}
        </CardHeader>
        <CardContent className="grid grid-cols-2 gap-4 text-sm">
          <div><span className="text-gray-500">Date:</span> <strong>{r.date}</strong></div>
          <div><span className="text-gray-500">Fournisseur:</span> <strong>{r.fournisseur || "—"}</strong></div>
        </CardContent>
      </Card>

      <div className="overflow-x-auto rounded-2xl border shadow-sm bg-white">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 border-b"><tr>{["Réf.", "Désignation", "Qté", "Prix", "TVA%", "Remise%", "Montant TTC"].map(h => <th key={h} className="px-4 py-3 text-left text-xs font-black text-gray-500 uppercase">{h}</th>)}</tr></thead>
          <tbody>
            {(r.lines ?? []).map(l => {
              const c = calcLine(l.prix, l.quantity, l.tvaPct, l.remise);
              return (
                <tr key={l.id} className="border-b last:border-0">
                  <td className="px-4 py-3 font-mono font-bold text-blue-700">{l.product?.reference ?? "—"}</td>
                  <td className="px-4 py-3">{l.product?.designation ?? "—"}</td>
                  <td className="px-4 py-3">{l.quantity}</td>
                  <td className="px-4 py-3 font-mono">{fmt(l.prix)}</td>
                  <td className="px-4 py-3">{l.tvaPct}%</td>
                  <td className="px-4 py-3">{l.remise}%</td>
                  <td className="px-4 py-3 font-mono font-bold">{fmt(c.ttc)}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <div className="bg-gray-50 border rounded-2xl p-4 flex gap-8">
        {[{ label: "Montant HT", value: fmt(totals.ht) }, { label: "Montant TVA", value: fmt(totals.tva) }, { label: "Montant TTC", value: fmt(totals.ttc) }].map(t => (
          <div key={t.label}><p className="text-[10px] font-black text-gray-400 uppercase tracking-widest">{t.label}</p><p className="text-xl font-black text-gray-900 font-mono">{t.value} TND</p></div>
        ))}
      </div>

      <Dialog open={confirmDelete} onOpenChange={setConfirmDelete}>
        <DialogContent>
          <DialogHeader><DialogTitle>Confirmer la suppression</DialogTitle></DialogHeader>
          <p className="text-sm text-gray-600">Supprimer BR N° <strong>{r.bonNumber}</strong> ? Tous les numéros de série associés (non vendus) seront aussi supprimés.</p>
          <div className="flex justify-end gap-2 mt-4">
            <Button variant="outline" onClick={() => setConfirmDelete(false)}>Annuler</Button>
            <Button variant="destructive" disabled={isDeleting} onClick={() => { setConfirmDelete(false); onDelete(); }} data-testid="button-confirm-delete-detail">
              {isDeleting ? "Suppression..." : "Supprimer"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
