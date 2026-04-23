import { useState, useMemo } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Edit2, Trash2, ShoppingCart, DollarSign, TrendingUp, Search, X } from "lucide-react";
import Dashboard from "./Dashboard";
import { useToast } from "@/hooks/use-toast";
import { useClients } from "@/hooks/use-clients";
import { apiRequest, queryClient } from "@/lib/queryClient";
import type { Order } from "@shared/schema";

type FormData = {
  nomPrenom: string;
  designation: string;
  avance: number;
  date: string;
  numeroTelephone: string;
  remarque: string;
};

const EMPTY_FORM: FormData = {
  nomPrenom: "",
  designation: "",
  avance: 0,
  date: new Date().toISOString().split("T")[0],
  numeroTelephone: "",
  remarque: "",
};

export default function CommandePage() {
  const [isOpen, setIsOpen] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [formData, setFormData] = useState<FormData>(EMPTY_FORM);
  const [clientSelectValue, setClientSelectValue] = useState<string>("");
  const { toast } = useToast();
  const { data: clients = [] } = useClients();

  const { data: orders = [], isLoading } = useQuery<Order[]>({
    queryKey: ["/api/orders"],
  });

  const createMutation = useMutation({
    mutationFn: (data: FormData) => apiRequest("POST", "/api/orders", data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/orders"] }); toast({ title: "Succès" }); },
    onError: () => toast({ title: "Erreur", variant: "destructive" }),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<FormData> }) => apiRequest("PUT", `/api/orders/${id}`, data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/orders"] }); toast({ title: "Succès" }); },
    onError: () => toast({ title: "Erreur", variant: "destructive" }),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: number) => apiRequest("DELETE", `/api/orders/${id}`),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/orders"] }); toast({ title: "Supprimé" }); },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingId !== null) {
      updateMutation.mutate({ id: editingId, data: formData });
    } else {
      createMutation.mutate(formData);
    }
    setIsOpen(false);
    setEditingId(null);
    setFormData(EMPTY_FORM);
    setClientSelectValue("");
  };

  const handleEdit = (item: Order) => {
    setEditingId(item.id);
    setFormData({
      nomPrenom: item.nomPrenom,
      designation: item.designation,
      avance: item.avance,
      date: item.date,
      numeroTelephone: item.numeroTelephone,
      remarque: item.remarque,
    });
    setIsOpen(true);
  };

  const handleDelete = (id: number) => {
    if (confirm("Supprimer ?")) deleteMutation.mutate(id);
  };

  const [searchQuery, setSearchQuery] = useState("");

  const filteredOrders = useMemo(() => {
    if (!searchQuery.trim()) return orders;
    const q = searchQuery.toLowerCase().trim();
    return orders.filter(o =>
      o.nomPrenom?.toLowerCase().includes(q) ||
      o.designation?.toLowerCase().includes(q) ||
      o.date?.toLowerCase().includes(q) ||
      o.numeroTelephone?.toLowerCase().includes(q) ||
      o.remarque?.toLowerCase().includes(q) ||
      String(o.avance).includes(q)
    );
  }, [orders, searchQuery]);

  const todayString = new Date().toISOString().split("T")[0];
  const totalAvance = orders.reduce((acc, o) => acc + Number(o.avance), 0);
  const todayCount = orders.filter((o) => o.date === todayString).length;

  return (
    <Dashboard contentOnly={true}>
      <div className="flex flex-col gap-8 p-8 max-w-7xl mx-auto bg-gradient-to-br from-gray-50 via-white to-gray-100 min-h-screen animate-enter">
        <header className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-gradient-to-br from-orange-500 to-red-600 rounded-2xl shadow-lg ring-4 ring-white text-white">
              <ShoppingCart className="w-8 h-8" />
            </div>
            <div>
              <h1 className="text-3xl font-black tracking-tight text-gray-900 uppercase italic">Suivi Commandes</h1>
              <p className="text-gray-500 font-medium">Gestion des commandes clients.</p>
            </div>
          </div>
          <Dialog open={isOpen} onOpenChange={(o) => { setIsOpen(o); if (!o) { setEditingId(null); setFormData(EMPTY_FORM); setClientSelectValue(""); } }}>
            <DialogTrigger asChild>
              <Button data-testid="button-new-order" className="gap-2 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-bold px-8 py-6 rounded-2xl shadow-xl hover:shadow-2xl transition-all hover:-translate-y-0.5 active:translate-y-0">
                <Plus className="w-5 h-5 stroke-[3px]" /> Nouvelle commande
              </Button>
            </DialogTrigger>
            <DialogContent className="rounded-[2rem] border-none shadow-2xl p-8">
              <DialogHeader>
                <DialogTitle className="text-2xl font-black text-gray-900 uppercase italic tracking-tight">
                  {editingId ? "Modifier la commande" : "Nouvelle commande"}
                </DialogTitle>
              </DialogHeader>
              <form onSubmit={handleSubmit} className="flex flex-col gap-5 py-4">
                <div className="grid gap-2">
                  <Label className="font-bold text-gray-700 uppercase tracking-wider text-xs px-1">Nom et Prénom</Label>
                  <Select
                    value={clientSelectValue}
                    onValueChange={(val) => {
                      setClientSelectValue(val);
                      const client = clients.find((c) => c.id.toString() === val);
                      setFormData({ ...formData, nomPrenom: client ? client.nomPrenom : formData.nomPrenom, numeroTelephone: client?.numeroTelephone || formData.numeroTelephone });
                    }}
                  >
                    <SelectTrigger className="h-12 rounded-xl border-gray-200 font-medium">
                      <SelectValue placeholder="Choisir un client existant" />
                    </SelectTrigger>
                    <SelectContent className="rounded-xl border-none shadow-xl max-h-72">
                      {clients.map((c) => (
                        <SelectItem key={c.id} value={c.id.toString()} className="rounded-lg font-medium">
                          {c.nomPrenom}{c.numeroTelephone ? ` (${c.numeroTelephone})` : ""}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <Input
                    className="mt-2"
                    placeholder="Ou saisir un nouveau client"
                    value={formData.nomPrenom}
                    onChange={(e) => { setFormData({ ...formData, nomPrenom: e.target.value }); setClientSelectValue(""); }}
                    required
                    data-testid="input-order-nom"
                  />
                </div>
                <div className="grid gap-2">
                  <Label className="font-bold text-gray-700 uppercase tracking-wider text-xs px-1">Désignation</Label>
                  <Input data-testid="input-order-designation" value={formData.designation} onChange={(e) => setFormData({ ...formData, designation: e.target.value })} required className="h-12 rounded-xl border-gray-200 font-medium" />
                </div>
                <div className="grid gap-2">
                  <Label className="font-bold text-gray-700 uppercase tracking-wider text-xs px-1">Avance (TND)</Label>
                  <Input data-testid="input-order-avance" type="number" step="0.001" value={formData.avance} onChange={(e) => setFormData({ ...formData, avance: Number(e.target.value) })} required className="h-12 rounded-xl border-gray-200 font-bold text-red-600" />
                </div>
                <div className="grid gap-2">
                  <Label className="font-bold text-gray-700 uppercase tracking-wider text-xs px-1">Date</Label>
                  <Input data-testid="input-order-date" type="date" value={formData.date} onChange={(e) => setFormData({ ...formData, date: e.target.value })} required className="h-12 rounded-xl border-gray-200 font-medium" />
                </div>
                <div className="grid gap-2">
                  <Label className="font-bold text-gray-700 uppercase tracking-wider text-xs px-1">Téléphone</Label>
                  <Input data-testid="input-order-telephone" value={formData.numeroTelephone} onChange={(e) => setFormData({ ...formData, numeroTelephone: e.target.value })} className="h-12 rounded-xl border-gray-200 font-medium" />
                </div>
                <div className="grid gap-2">
                  <Label className="font-bold text-gray-700 uppercase tracking-wider text-xs px-1">Remarque</Label>
                  <Textarea data-testid="input-order-remarque" value={formData.remarque} onChange={(e) => setFormData({ ...formData, remarque: e.target.value })} className="rounded-xl border-gray-200 font-medium min-h-[100px]" />
                </div>
                <Button type="submit" data-testid="button-submit-order" className="w-full h-14 bg-gradient-to-r from-red-600 to-red-700 text-white font-black uppercase tracking-widest rounded-2xl shadow-lg mt-4" disabled={createMutation.isPending || updateMutation.isPending}>
                  Enregistrer
                </Button>
              </form>
            </DialogContent>
          </Dialog>
        </header>

        <div className="grid gap-6 md:grid-cols-3">
          <Card className="bg-white/70 backdrop-blur-sm border-gray-200 shadow-sm hover:shadow-xl transition-all rounded-3xl group">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-xs font-black text-gray-500 uppercase tracking-widest">Total Commandes</CardTitle>
              <div className="p-2 bg-gray-100 rounded-xl group-hover:bg-gray-200"><TrendingUp className="w-4 h-4 text-gray-500" /></div>
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-black text-gray-900 tracking-tighter italic" data-testid="text-orders-total">{orders.length}</div>
              <p className="text-[10px] font-bold text-gray-400 mt-2 uppercase">Commandes enregistrées</p>
            </CardContent>
          </Card>
          <Card className="bg-white/70 backdrop-blur-sm border-gray-200 shadow-sm hover:shadow-xl transition-all rounded-3xl group">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-xs font-black text-gray-500 uppercase tracking-widest">Aujourd'hui</CardTitle>
              <div className="p-2 bg-orange-100 rounded-xl group-hover:bg-orange-200"><ShoppingCart className="w-4 h-4 text-orange-600" /></div>
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-black text-gray-900 tracking-tighter italic">{todayCount}</div>
              <p className="text-[10px] font-bold text-gray-400 mt-2 uppercase">Commandes du jour</p>
            </CardContent>
          </Card>
          <Card className="bg-white/70 backdrop-blur-sm border-gray-200 shadow-sm hover:shadow-xl transition-all rounded-3xl group">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-xs font-black text-gray-500 uppercase tracking-widest">Avances</CardTitle>
              <div className="p-2 bg-green-100 rounded-xl group-hover:bg-green-200"><DollarSign className="w-4 h-4 text-green-600" /></div>
            </CardHeader>
            <CardContent>
              <div className="text-4xl font-black text-red-600 tracking-tighter italic" data-testid="text-orders-avance">{totalAvance.toFixed(2)} <span className="text-lg uppercase not-italic">TND</span></div>
            </CardContent>
          </Card>
        </div>

        <Card className="border-gray-200 shadow-2xl bg-white/80 backdrop-blur-md overflow-hidden rounded-[2.5rem]">
          <CardContent className="p-0">
            <div className="p-3 border-b bg-gray-50/50 flex items-center gap-2">
              <Search className="w-4 h-4 text-gray-400 shrink-0" />
              <Input
                data-testid="input-search-orders"
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
                placeholder="Rechercher par client, désignation, date, avance, tél, remarque..."
                className="h-9 rounded-xl border-gray-200 text-sm bg-white"
              />
              {searchQuery && (
                <button onClick={() => setSearchQuery("")} className="text-gray-400 hover:text-gray-600 shrink-0">
                  <X className="w-4 h-4" />
                </button>
              )}
            </div>
            <div className="overflow-x-auto custom-scrollbar">
              <Table>
                <TableHeader>
                  <TableRow className="bg-gray-50/80 hover:bg-gray-50/80 border-b-2 border-gray-100">
                    <TableHead className="font-black text-gray-900 h-16 uppercase tracking-widest text-[10px]">Client</TableHead>
                    <TableHead className="font-black text-gray-900 h-16 uppercase tracking-widest text-[10px]">Désignation</TableHead>
                    <TableHead className="font-black text-gray-900 h-16 uppercase tracking-widest text-[10px]">Avance</TableHead>
                    <TableHead className="font-black text-gray-900 h-16 uppercase tracking-widest text-[10px]">Date</TableHead>
                    <TableHead className="font-black text-gray-900 h-16 uppercase tracking-widest text-[10px]">Téléphone</TableHead>
                    <TableHead className="font-black text-gray-900 h-16 uppercase tracking-widest text-[10px]">Remarques</TableHead>
                    <TableHead className="text-right font-black text-gray-900 h-16 uppercase tracking-widest text-[10px]">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {isLoading && (
                    <TableRow><TableCell colSpan={7} className="text-center py-8 text-gray-400 font-medium">Chargement...</TableCell></TableRow>
                  )}
                  {!isLoading && filteredOrders.length === 0 && (
                    <TableRow><TableCell colSpan={7} className="text-center py-8 text-gray-400 font-medium">Aucune commande</TableCell></TableRow>
                  )}
                  {filteredOrders.map((item) => (
                    <TableRow key={item.id} data-testid={`row-order-${item.id}`} className="transition-all duration-200 h-16 border-b border-gray-50 group hover:bg-gray-50/50">
                      <TableCell className="py-4 font-bold">{item.nomPrenom}</TableCell>
                      <TableCell className="py-4 font-medium">{item.designation}</TableCell>
                      <TableCell className="py-4 font-black text-red-600 italic tracking-tighter">{Number(item.avance).toFixed(2)} TND</TableCell>
                      <TableCell className="py-4 font-bold">{item.date ? new Date(item.date).toLocaleDateString("fr-FR", { day: "2-digit", month: "short", year: "numeric" }) : "-"}</TableCell>
                      <TableCell className="py-4 font-medium text-gray-500">{item.numeroTelephone}</TableCell>
                      <TableCell className="py-4 max-w-xs truncate font-medium text-gray-400">{item.remarque}</TableCell>
                      <TableCell className="text-right py-4" onClick={(e) => e.stopPropagation()}>
                        <div className="flex justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                          <Button variant="ghost" size="icon" data-testid={`button-edit-order-${item.id}`} onClick={() => handleEdit(item)} className="h-10 w-10 rounded-xl text-gray-400 hover:text-gray-900 hover:bg-white shadow-sm transition-all"><Edit2 className="w-4 h-4" /></Button>
                          <Button variant="ghost" size="icon" data-testid={`button-delete-order-${item.id}`} onClick={() => handleDelete(item.id)} className="h-10 w-10 rounded-xl text-red-400 hover:text-red-700 hover:bg-white shadow-sm transition-all"><Trash2 className="w-4 h-4" /></Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>
    </Dashboard>
  );
}
