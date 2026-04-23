import { useState, useMemo } from "react";
import Dashboard from "@/pages/Dashboard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Plus, Trash2, Users, Edit2, Search, Eye, Phone, MapPin, Building, CreditCard, Hash, User, Mail } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { useClients, useCreateClient, useDeleteClient, useUpdateClient } from "@/hooks/use-clients";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

// Dropdown Options
const CATEGORIES = ["Micro Entreprise", "PME/PMI", "Grand Compte", "Groupe De Sociétés", "B2C", "Passager"];
const FAMILLES = ["Client B2C", "CLIENT B2B", "CONVENTION STEG", "CLIENT PASSAGER"];
const CIVILITES = ["S.A", "S.A.R.L", "S.U.A.R.L", "Pers-Phys", "Etranger", "Etat"];
const MODES_REGLEMENT = ["Virement", "Traite", "Espèce", "Chèque", "Chèque 90 jours", "Chèque 60 jours", "Chèque ATB", "AVOIR", "Retenue"];
const BANQUES = ["Banque Zitouna", "AMEN BANK", "Arab Banking Corporation", "Arab Tunisian Bank", "Attijari Bank", "Beit Ettamwil Saoudi Tounsi", "Best Bank", "Banque de Financement des PME", "Banque Franco-Tunisienne", "Banque de l'habitat", "Banque Internationale Arabe", "Banque nationale agricole", "Banque de Sud", "Banque de Tunisie", "Banque Tuniso-Emiratie", "Banque Tuniso-Kowétienne", "Banque Tuniso-Lybienne", "China Merchants Bank", "La Poste"];

export default function GestionClientsPage() {
  const { toast } = useToast();
  const { data: clients = [] } = useClients();
  const createClient = useCreateClient();
  const deleteClient = useDeleteClient();
  const updateClient = useUpdateClient();

  const [open, setOpen] = useState(false);
  const [viewOpen, setViewOpen] = useState(false);
  const [selectedClient, setSelectedClient] = useState<any>(null);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [search, setSearch] = useState("");
  const DEFAULT_FORM = {
    nomPrenom: "",
    numeroTelephone: "",
    numeroTelephone2: "",
    email: "",
    fax: "",
    nomSubClient: "",
    adresse: "",
    cin: "",
    typeCompany: "",
    codePostal: "",
    uniqueNumber: "",
    remarque: "",
    categorie: "B2C",
    famille: "Client B2C",
    civilite: "Pers-Phys",
    modeReglement: "",
    banque: "",
  };

  const [form, setForm] = useState(DEFAULT_FORM);

  const B2B_CIVILITES = ["S.A", "S.A.R.L", "S.U.A.R.L"];

  const handleCiviliteChange = (v: string) => {
    const isB2B = B2B_CIVILITES.includes(v);
    setForm(f => ({
      ...f,
      civilite: v,
      famille: isB2B ? "CLIENT B2B" : "Client B2C",
    }));
  };

  // Get the next unique number
  const getNextUniqueNumber = () => {
    if (!clients || clients.length === 0) return "411100001";
    const maxNum = Math.max(...clients.filter(c => c.uniqueNumber).map(c => parseInt(c.uniqueNumber, 10) || 0));
    return String(maxNum + 1).padStart(9, "0");
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingId) {
        await updateClient.mutateAsync({ id: editingId, ...form });
        toast({ title: "Succès", description: "Client modifié" });
      } else {
        await createClient.mutateAsync(form);
        toast({ title: "Succès", description: "Client créé" });
      }
      setOpen(false);
      setEditingId(null);
      resetForm();
    } catch (err: any) {
      toast({ title: "Erreur", description: err?.message || "Action impossible", variant: "destructive" });
    }
  };

  const resetForm = () => {
    setForm({ ...DEFAULT_FORM, uniqueNumber: getNextUniqueNumber() });
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Supprimer ce client ?")) return;
    try {
      await deleteClient.mutateAsync(id);
      toast({ title: "Supprimé" });
    } catch (err: any) {
      toast({ title: "Erreur", description: err?.message || "Suppression impossible", variant: "destructive" });
    }
  };

  const filteredClients = useMemo(() => {
    const q = search.toLowerCase().trim();
    // Sort: Newest first (by ID descending)
    const base = [...clients].sort((a, b) => b.id - a.id);
    if (!q) return base;
    return base.filter((c) => {
      const name = c.nomPrenom?.toLowerCase() ?? "";
      const phone = c.numeroTelephone?.toLowerCase() ?? "";
      const phone2 = c.numeroTelephone2?.toLowerCase() ?? "";
      const sub = c.nomSubClient?.toLowerCase() ?? "";
      const remark = c.remarque?.toLowerCase() ?? "";
      const unique = c.uniqueNumber?.toLowerCase() ?? "";
      return (
        name.includes(q) ||
        phone.includes(q) ||
        phone2.includes(q) ||
        sub.includes(q) ||
        remark.includes(q) ||
        unique.includes(q)
      );
    });
  }, [clients, search]);

  return (
    <Dashboard contentOnly>
      <div className="flex flex-col gap-8 p-8 max-w-7xl mx-auto bg-gradient-to-br from-gray-50 via-white to-gray-100 min-h-screen animate-enter">
        <header className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-gradient-to-br from-slate-700 to-slate-900 rounded-2xl shadow-lg ring-4 ring-white">
              <Users className="w-8 h-8 text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-black tracking-tight text-gray-900 uppercase italic">Gestion Clients</h1>
              <p className="text-gray-500 font-medium">Suivi des informations clients et sous-clients.</p>
            </div>
          </div>

          <Dialog
            open={open}
            onOpenChange={(o) => {
              setOpen(o);
              if (o && !editingId) {
                resetForm();
              }
              if (!o) {
                setEditingId(null);
                resetForm();
              }
            }}
          >
            <DialogTrigger asChild>
              <Button className="gap-2 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-bold px-8 py-6 rounded-2xl shadow-xl hover:shadow-2xl transition-all hover:-translate-y-0.5 active:translate-y-0">
                <Plus className="w-5 h-5 stroke-[3px]" /> Nouveau client
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[650px] rounded-[2rem] border-none shadow-2xl p-8 max-h-[90vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle className="text-2xl font-black text-gray-900 uppercase italic tracking-tight">
                  {editingId ? "Modifier un client" : "Créer un client"}
                </DialogTitle>
              </DialogHeader>
              <form onSubmit={handleSubmit} className="flex flex-col gap-5 py-4">

                {/* Row 1: Nom + Numéro Unique */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Nom / Prénom</Label><Input value={form.nomPrenom} onChange={(e) => setForm({ ...form, nomPrenom: e.target.value })} required className="h-11 rounded-xl border-gray-200 font-medium" /></div>
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Numéro Unique</Label><Input value={form.uniqueNumber} onChange={(e) => setForm({ ...form, uniqueNumber: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" placeholder={getNextUniqueNumber()} /></div>
                </div>

                {/* Row 2: Téléphones */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Téléphone Principal</Label><Input value={form.numeroTelephone} onChange={(e) => setForm({ ...form, numeroTelephone: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" placeholder="GSM 1" /></div>
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Second Téléphone</Label><Input value={form.numeroTelephone2} onChange={(e) => setForm({ ...form, numeroTelephone2: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" placeholder="GSM 2" /></div>
                </div>

                {/* Row 3: Info Sous-Client */}
                <div className="grid gap-2 bg-slate-50 p-4 rounded-2xl border border-slate-100">
                  <Label className="font-bold text-slate-700 uppercase tracking-wider text-[10px] px-1 flex items-center gap-2"><Users className="w-3 h-3" /> Info Sous-Client</Label>
                  <Input value={form.nomSubClient} onChange={(e) => setForm({ ...form, nomSubClient: e.target.value })} className="h-11 rounded-xl border-gray-200 bg-white font-medium" placeholder="Nom du sous-client" />
                </div>

                {/* Row 4: Catégorie + Famille */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Catégorie</Label><Select value={form.categorie} onValueChange={(v) => setForm({ ...form, categorie: v })}><SelectTrigger className="h-11 rounded-xl border-gray-200 font-medium"><SelectValue placeholder="Choisir..." /></SelectTrigger><SelectContent className="rounded-xl">{CATEGORIES.map(c => <SelectItem key={c} value={c} className="rounded-lg font-medium">{c}</SelectItem>)}</SelectContent></Select></div>
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Famille</Label><Select value={form.famille} onValueChange={(v) => setForm({ ...form, famille: v })}><SelectTrigger className="h-11 rounded-xl border-gray-200 font-medium"><SelectValue placeholder="Choisir..." /></SelectTrigger><SelectContent className="rounded-xl">{FAMILLES.map(f => <SelectItem key={f} value={f} className="rounded-lg font-medium">{f}</SelectItem>)}</SelectContent></Select></div>
                </div>

                {/* Row 5: Civilité (auto-sets Famille) + CIN */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Civilité</Label><Select value={form.civilite} onValueChange={handleCiviliteChange}><SelectTrigger className="h-11 rounded-xl border-gray-200 font-medium"><SelectValue placeholder="Choisir..." /></SelectTrigger><SelectContent className="rounded-xl">{CIVILITES.map(c => <SelectItem key={c} value={c} className="rounded-lg font-medium">{c}</SelectItem>)}</SelectContent></Select></div>
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">CIN / Matricule</Label><Input value={form.cin} onChange={(e) => setForm({ ...form, cin: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" /></div>
                </div>

                {/* Row 6: Adresse */}
                <div className="grid gap-2">
                  <Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Adresse</Label>
                  <Input value={form.adresse} onChange={(e) => setForm({ ...form, adresse: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" />
                </div>

                {/* Row 7: Code Postal + Remarque */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Code Postal</Label><Input value={form.codePostal} onChange={(e) => setForm({ ...form, codePostal: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" /></div>
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Remarque</Label><Input value={form.remarque} onChange={(e) => setForm({ ...form, remarque: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" /></div>
                </div>

                {/* Row 8: Email + Fax */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Email</Label><Input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" placeholder="email@example.com" /></div>
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Fax</Label><Input value={form.fax} onChange={(e) => setForm({ ...form, fax: e.target.value })} className="h-11 rounded-xl border-gray-200 font-medium" placeholder="Fax" /></div>
                </div>

                {/* Row 9: Mode Règlement + Banque */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Mode Règlement</Label><Select value={form.modeReglement} onValueChange={(v) => setForm({ ...form, modeReglement: v })}><SelectTrigger className="h-11 rounded-xl border-gray-200 font-medium"><SelectValue placeholder="Choisir..." /></SelectTrigger><SelectContent className="rounded-xl">{MODES_REGLEMENT.map(m => <SelectItem key={m} value={m} className="rounded-lg font-medium">{m}</SelectItem>)}</SelectContent></Select></div>
                  <div className="grid gap-2"><Label className="font-bold text-gray-700 uppercase tracking-wider text-[10px] px-1">Banque</Label><Select value={form.banque} onValueChange={(v) => setForm({ ...form, banque: v })}><SelectTrigger className="h-11 rounded-xl border-gray-200 font-medium"><SelectValue placeholder="Choisir..." /></SelectTrigger><SelectContent className="rounded-xl max-h-60">{BANQUES.map(b => <SelectItem key={b} value={b} className="rounded-lg font-medium">{b}</SelectItem>)}</SelectContent></Select></div>
                </div>

                <Button type="submit" className="w-full h-14 bg-gradient-to-r from-red-600 to-red-700 text-white font-black uppercase tracking-widest rounded-2xl shadow-lg mt-4">
                  Enregistrer
                </Button>
              </form>
            </DialogContent>
          </Dialog>

          <Dialog open={viewOpen} onOpenChange={setViewOpen}>
            <DialogContent className="sm:max-w-[600px] rounded-[2rem] border-none shadow-2xl p-0 overflow-hidden bg-white">
              {selectedClient && (
                <div className="flex flex-col">
                  <div className="bg-gradient-to-br from-red-50 to-white p-8 border-b border-red-100 relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-red-100/30 rounded-full -mr-16 -mt-16 blur-3xl" />
                    <div className="absolute bottom-0 left-0 w-24 h-24 bg-red-500/5 rounded-full -ml-12 -mb-12 blur-2xl" />
                    
                    <div className="relative flex items-center gap-5">
                      <div className="p-4 bg-red-100 rounded-2xl shadow-sm">
                        <Users className="w-10 h-10 text-red-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-3 flex-wrap">
                          <h2 className="text-3xl font-black uppercase italic tracking-tight truncate text-gray-900">
                            {selectedClient.nomPrenom}
                          </h2>
                          {selectedClient.uniqueNumber && (
                            <Badge className="bg-red-600 hover:bg-red-700 text-white border-none px-3 py-1 font-black italic">
                              #{selectedClient.uniqueNumber}
                            </Badge>
                          )}
                        </div>
                        <p className="text-gray-600 font-bold uppercase tracking-widest text-xs mt-1 flex items-center gap-2">
                          <Building className="w-3 h-3" />
                          {selectedClient.typeCompany || "Physical Person"}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="p-8 space-y-8 max-h-[70vh] overflow-y-auto custom-scrollbar">
                    {/* Primary Contact Section */}
                    <section className="space-y-4">
                      <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] flex items-center gap-2 px-1">
                        <span className="w-8 h-[1px] bg-slate-200" /> Coordonnées Principal
                      </h3>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100 group transition-colors hover:bg-white hover:border-blue-100 hover:shadow-sm">
                          <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1 flex items-center gap-1.5">
                            <Phone className="w-3 h-3 text-blue-500" /> GSM Principal
                          </p>
                          <p className="font-black text-slate-900 text-lg tabular-nums">
                            {selectedClient.numeroTelephone || "—"}
                          </p>
                        </div>
                        <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100 group transition-colors hover:bg-white hover:border-blue-100 hover:shadow-sm">
                          <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1 flex items-center gap-1.5">
                            <Phone className="w-3 h-3 text-blue-400" /> GSM Secondaire
                          </p>
                          <p className="font-black text-slate-900 text-lg tabular-nums">
                            {selectedClient.numeroTelephone2 || "—"}
                          </p>
                        </div>
                      </div>
                    </section>

                    {/* Classification Section */}
                    <section className="space-y-4">
                      <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] flex items-center gap-2 px-1">
                        <span className="w-8 h-[1px] bg-slate-200" /> Classification & Profil
                      </h3>
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100">
                          <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Catégorie</p>
                          <p className="font-bold text-slate-900">{selectedClient.categorie || "—"}</p>
                        </div>
                        <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100">
                          <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Famille</p>
                          <p className="font-bold text-slate-900">{selectedClient.famille || "—"}</p>
                        </div>
                        <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100">
                          <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Civilité</p>
                          <p className="font-bold text-slate-900">{selectedClient.civilite || "—"}</p>
                        </div>
                      </div>
                    </section>

                    {/* Legal & Address Section */}
                    <section className="space-y-4">
                      <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] flex items-center gap-2 px-1">
                        <span className="w-8 h-[1px] bg-slate-200" /> Détails Légaux & Adresse
                      </h3>
                      <div className="space-y-3">
                        <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-2xl border border-slate-100">
                          <div className="p-2 bg-white rounded-xl shadow-sm"><CreditCard className="w-5 h-5 text-red-500" /></div>
                          <div>
                            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest">CIN / Matricule Fiscale</p>
                            <p className="font-bold text-slate-900">{selectedClient.cin || "—"}</p>
                          </div>
                        </div>
                        <div className="flex items-start gap-4 p-4 bg-slate-50 rounded-2xl border border-slate-100">
                          <div className="p-2 bg-white rounded-xl shadow-sm"><MapPin className="w-5 h-5 text-green-500" /></div>
                          <div className="flex-1">
                            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Localisation</p>
                            <p className="font-bold text-slate-900 leading-tight">
                              {selectedClient.adresse || "—"}
                            </p>
                            {selectedClient.codePostal && (
                              <Badge variant="secondary" className="mt-2 bg-slate-200 text-slate-700 font-bold border-none">
                                CP: {selectedClient.codePostal}
                              </Badge>
                            )}
                          </div>
                        </div>
                      </div>
                    </section>

                    {/* Sub-Client Section */}
                    {selectedClient.nomSubClient && (
                      <section className="space-y-4">
                         <h3 className="text-[10px] font-black text-red-400 uppercase tracking-[0.2em] flex items-center gap-2 px-1">
                          <span className="w-8 h-[1px] bg-red-100" /> Information Sous-Client
                        </h3>
                        <div className="p-5 bg-red-50 rounded-3xl border border-red-100 shadow-sm relative overflow-hidden group">
                          <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                            <Users className="w-12 h-12 text-red-600" />
                          </div>
                          <p className="text-[9px] font-black text-red-400 uppercase tracking-widest mb-1">Désignation</p>
                          <p className="font-black text-red-900 text-xl italic">{selectedClient.nomSubClient}</p>
                        </div>
                      </section>
                    )}

                    {/* Remarks Section */}
                    <section className="pt-4 border-t border-slate-100">
                      <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3 px-1">Note & Remarque</p>
                      <div className="p-5 bg-amber-50/50 rounded-2xl border border-dashed border-amber-200/60 min-h-[80px]">
                        <p className="text-sm font-medium text-amber-900 italic leading-relaxed">
                          {selectedClient.remarque || "Aucune note particulière pour ce client."}
                        </p>
                      </div>
                    </section>
                  </div>
                  
                  <div className="p-4 bg-slate-50 border-t flex justify-end">
                    <Button 
                      variant="ghost" 
                      onClick={() => setViewOpen(false)}
                      className="rounded-xl font-bold uppercase tracking-widest text-[10px] h-10 px-6 hover:bg-slate-200 transition-colors"
                    >
                      Fermer le Profil
                    </Button>
                  </div>
                </div>
              )}
            </DialogContent>
          </Dialog>
        </header>

        <Card className="border-gray-200 shadow-2xl bg-white/90 backdrop-blur-md overflow-hidden rounded-[2.5rem] ring-1 ring-gray-100/80">
          <CardHeader className="border-b border-gray-100/80 bg-gradient-to-r from-slate-50/90 to-gray-50/90 flex flex-col gap-4 md:flex-row md:items-center md:justify-between px-6 py-5">
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-slate-100 rounded-xl">
                  <Users className="w-5 h-5 text-slate-600" />
                </div>
                <div>
                  <CardTitle className="text-base font-black text-gray-900 uppercase tracking-widest">Base de Données Clients</CardTitle>
                  <p className="text-xs font-medium text-gray-500 mt-0.5">{filteredClients.length} client{filteredClients.length !== 1 ? "s" : ""}</p>
                </div>
              </div>
            </div>
            <div className="relative w-full md:w-72">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <Input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Nom, Tel, ID unique..."
                className="h-11 pl-10 rounded-xl border-gray-200 bg-white/80 font-medium text-sm"
              />
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto custom-scrollbar">
              <Table>
                <TableHeader>
                  <TableRow className="bg-slate-50/90 hover:bg-slate-50/90 border-b-2 border-slate-100">
                    <TableHead className="font-black text-slate-700 h-14 uppercase tracking-widest text-[10px]">ID Unique</TableHead>
                    <TableHead className="font-black text-slate-700 h-14 uppercase tracking-widest text-[10px]">Client</TableHead>
                    <TableHead className="font-black text-slate-700 h-14 uppercase tracking-widest text-[10px]">GSM</TableHead>
                    <TableHead className="font-black text-slate-700 h-14 uppercase tracking-widest text-[10px]">GSM 2 / Sous-Client</TableHead>
                    <TableHead className="text-right font-black text-slate-700 h-14 uppercase tracking-widest text-[10px] pr-6">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredClients.map((c) => (
                    <TableRow
                      key={c.id}
                      className="transition-all duration-200 h-16 border-b border-gray-50/80 group hover:bg-slate-50/50 last:border-b-0"
                    >
                      <TableCell className="py-4">
                        {c.uniqueNumber ? (
                          <Badge variant="outline" className="font-bold border-gray-200 text-gray-500 bg-gray-50">
                            {c.uniqueNumber}
                          </Badge>
                        ) : "—"}
                      </TableCell>
                      <TableCell className="py-4 font-bold text-gray-900">
                        <div className="flex flex-col">
                          <span>{c.nomPrenom}</span>
                          <span className="text-[10px] text-gray-400 font-medium uppercase tracking-tight italic">
                            {c.typeCompany || "Physical Person"}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="py-4 font-medium text-gray-600">{c.numeroTelephone || "—"}</TableCell>
                      <TableCell className="py-4 font-medium text-gray-500">
                        <div className="flex flex-col">
                          <span>{c.numeroTelephone2 || "—"}</span>
                          {c.nomSubClient && <span className="text-[10px] text-red-500 font-bold uppercase tracking-tighter italic">Sub: {c.nomSubClient}</span>}
                        </div>
                      </TableCell>
                      <TableCell className="text-right py-4 pr-6">
                        <div className="flex justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => {
                              setSelectedClient(c);
                              setViewOpen(true);
                            }}
                            className="h-10 w-10 rounded-xl text-blue-500 hover:text-blue-700 hover:bg-blue-50 shadow-sm transition-all"
                            title="Voir détails"
                          >
                            <Eye className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => {
                              setEditingId(c.id);
                              setForm({
                                nomPrenom: c.nomPrenom,
                                numeroTelephone: c.numeroTelephone || "",
                                numeroTelephone2: c.numeroTelephone2 || "",
                                email: c.email || "",
                                fax: c.fax || "",
                                nomSubClient: c.nomSubClient || "",
                                adresse: c.adresse || "",
                                cin: c.cin || "",
                                typeCompany: c.typeCompany || "",
                                codePostal: c.codePostal || "",
                                uniqueNumber: c.uniqueNumber || "",
                                remarque: c.remarque || "",
                                categorie: c.categorie || "",
                                famille: c.famille || "",
                                civilite: c.civilite || "",
                                modeReglement: c.modeReglement || "",
                                banque: c.banque || "",
                              });
                              setOpen(true);
                            }}
                            className="h-10 w-10 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-white shadow-sm transition-all"
                            title="Modifier"
                          >
                            <Edit2 className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleDelete(c.id)}
                            className="h-10 w-10 rounded-xl text-red-400 hover:text-red-700 hover:bg-white shadow-sm transition-all"
                            title="Supprimer"
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
            {filteredClients.length === 0 && (
              <div className="py-16 text-center">
                <Users className="w-12 h-12 mx-auto text-gray-300 mb-3" />
                <p className="text-sm font-medium text-gray-500">{search ? "Aucun client trouvé" : "Aucun client enregistré"}</p>
                <p className="text-xs text-gray-400 mt-1">{search ? "Essayez une autre recherche" : "Cliquez sur Nouveau client pour commencer"}</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </Dashboard>
  );
}

