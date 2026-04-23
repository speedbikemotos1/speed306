import Dashboard from "@/pages/Dashboard";
import { useState, useRef, useMemo, useEffect } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { queryClient } from "@/lib/queryClient";
import { apiRequest } from "@/lib/queryClient";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { FileText, Plus, Trash2, Search, CheckCircle2, ChevronRight, AlertCircle, Printer, X, History, Pencil, UserPlus, Lock } from "lucide-react";
import type { DeliveryNoteLine } from "@shared/schema";
import logoImg from "@assets/LOGOBranding_1771926826080.png";
import { formatNum3, COMPANY, buildPrintHtml } from "@/lib/printUtils";

// ─── Types ────────────────────────────────────────────────────────────────────
type ProductFamily = { id: number; name: string };
type Product = { id: number; reference: string; designation: string; familyId: number | null; defaultPrice: number; tvaPct: number; availableQty: number; familyName: string | null };
type ProductSerial = { id: number; productId: number; serialNumber: string; purchasePrice: number; status: string };
type LivraisonLine = { id: number; ref: string; designation: string; serialNumber: string; prix: number; purchasePrice?: number; tvaPct: number; remise: number; prixTtc: number; montantHt: number; montantTva: number; montantTtc: number; productSerialId?: number };
type Livraison = { id: number; bonNumber: string; date: string; commercial: string; clientName: string; idClient: string; status: string; factureNumber?: string; lines?: LivraisonLine[]; totalHt?: number; totalTtc?: number };
type Client = { id: number; nomPrenom: string; uniqueNumber?: string; numeroTelephone?: string; adresse?: string; cin?: string };

type OldBonGroup = {
  kind: "old";
  bonNumber: string;
  date: string;
  commercial: string;
  client: string;
  idClient: string;
  factureNumber: string;
  lines: DeliveryNoteLine[];
  totalHt: number;
  totalTva: number;
  totalTtc: number;
};
type NewBonItem = { kind: "new" } & Livraison;
type UnifiedBL = OldBonGroup | NewBonItem;

const fmt = (n: number) => formatNum3(n);

function calcLine(prix: number, tva: number, remise: number) {
  const ht = prix * (1 - remise / 100);
  const tvaAmt = ht * (tva / 100);
  return { ht, tva: tvaAmt, ttc: ht + tvaAmt };
}

function groupByBon(lines: DeliveryNoteLine[]): OldBonGroup[] {
  const map = new Map<string, OldBonGroup>();
  for (const line of lines) {
    if (!map.has(line.bonNumber)) {
      map.set(line.bonNumber, { kind: "old", bonNumber: line.bonNumber, date: line.date, commercial: line.commercial, client: line.client, idClient: line.idClient, factureNumber: line.factureNumber, lines: [], totalHt: 0, totalTva: 0, totalTtc: 0 });
    }
    const g = map.get(line.bonNumber)!;
    g.lines.push(line);
    g.totalHt += line.montantHt;
    g.totalTva += line.montantTva;
    g.totalTtc += line.montantTtc;
  }
  return Array.from(map.values());
}

function triggerPrint(html: string) {
  const win = window.open("", "_blank", "width=850,height=1100");
  if (!win) return;
  win.document.write(html);
  win.document.close();
  win.focus();
  setTimeout(() => { win.print(); }, 600);
}

// ─── Print builders ───────────────────────────────────────────────────────────
function buildOldBLPrintHtml(bon: OldBonGroup, logoSrc: string): string {
  const linesHtml = bon.lines.map(line => {
    const snRow = line.serialNumber
      ? `<tr><td style="border:1px solid #ccc;padding:2px 6px;border-top:none;"></td><td style="border:1px solid #ccc;padding:2px 6px;border-top:none;font-style:italic;font-size:9px;color:#555;">${line.serialNumber}</td><td colspan="3" style="border:1px solid #ccc;padding:2px 6px;border-top:none;"></td></tr>`
      : "";
    return `<tr>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${line.ref}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;">${line.designation.trim()}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${Number(line.qte).toFixed(2)}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${line.tva.replace('%', '')}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:right;">${fmt(line.prix)}</td>
    </tr>${snRow}`;
  }).join("");
  return buildPrintHtml(`
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:12px;">
      <img src="${logoSrc}" alt="Logo" style="width:70px;height:70px;object-fit:contain;" />
      <div style="text-align:right;font-size:10px;line-height:1.6;"><div>${COMPANY.address}</div><div>${COMPANY.phone}</div><div>Matricule Fiscal : ${COMPANY.mf}</div></div>
    </div>
    <div style="text-align:center;font-weight:bold;font-size:13px;border-top:1px solid #000;border-bottom:1px solid #000;padding:4px 0;margin-bottom:12px;">Bon de Livraison N° : <u>${bon.bonNumber}</u></div>
    <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
      <div style="font-size:10px;"><strong>Date :</strong> ${bon.date}</div>
      <div style="border:1px solid #aaa;padding:6px 10px;font-size:10px;min-width:260px;">
        <div style="font-weight:bold;text-align:center;border-bottom:1px solid #ccc;padding-bottom:2px;margin-bottom:4px;">Client</div>
        <div><strong>Code :</strong> ${bon.idClient}</div><div><strong>Raison sociale :</strong> ${bon.client}</div>
      </div>
    </div>
    <table style="width:100%;border-collapse:collapse;font-size:10px;margin-bottom:12px;">
      <thead><tr style="background:#f0f0f0;"><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:80px;">Référence</th><th style="border:1px solid #888;padding:4px 6px;">Désignation</th><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:65px;">Quantité</th><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:65px;">TVA(%)</th><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:100px;">Prix Unitaire</th></tr></thead>
      <tbody>${linesHtml}</tbody>
    </table>
    <div style="display:flex;justify-content:flex-end;margin-bottom:20px;">
      <div style="font-size:10px;width:210px;">
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;padding:2px 8px;"><span>Montant HT :</span><strong>${fmt(bon.totalHt)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;border-top:none;padding:2px 8px;"><span>Montant TVA :</span><strong>${fmt(bon.totalTva)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;border-top:none;padding:3px 8px;font-weight:bold;"><span>Montant TTC :</span><span>${fmt(bon.totalTtc)}</span></div>
      </div>
    </div>
    <div style="display:flex;justify-content:space-between;margin-top:30px;font-size:10px;">
      <div style="text-align:center;"><div><strong>Signature et Cachet ${COMPANY.name}</strong></div><div style="margin-top:30px;border-top:1px solid #000;width:130px;"></div></div>
      <div style="text-align:center;"><div><strong>Signature et Cachet Client</strong></div><div style="margin-top:30px;border-top:1px solid #000;width:130px;"></div></div>
    </div>`, `BL ${bon.bonNumber}`);
}

function buildNewBLPrintHtml(liv: Livraison, lines: LivraisonLine[], logoSrc: string): string {
  const totalHt = lines.reduce((s, l) => s + l.montantHt, 0);
  const totalTva = lines.reduce((s, l) => s + l.montantTva, 0);
  const totalTtc = lines.reduce((s, l) => s + l.montantTtc, 0);
  const linesHtml = lines.map(line => {
    const snRow = line.serialNumber
      ? `<tr><td style="border:1px solid #ccc;padding:2px 6px;border-top:none;"></td><td style="border:1px solid #ccc;padding:2px 6px;border-top:none;font-style:italic;font-size:9px;color:#555;">${line.serialNumber}</td><td colspan="3" style="border:1px solid #ccc;padding:2px 6px;border-top:none;"></td></tr>`
      : "";
    return `<tr><td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${line.ref}</td><td style="border:1px solid #ccc;padding:3px 6px;">${line.designation.trim()}</td><td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">1,00</td><td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${line.tvaPct}</td><td style="border:1px solid #ccc;padding:3px 6px;text-align:right;">${fmt(line.prix)}</td></tr>${snRow}`;
  }).join("");
  return buildPrintHtml(`
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:12px;">
      <img src="${logoSrc}" alt="Logo" style="width:70px;height:70px;object-fit:contain;" />
      <div style="text-align:right;font-size:10px;line-height:1.6;"><div>${COMPANY.address}</div><div>${COMPANY.phone}</div><div>Matricule Fiscal : ${COMPANY.mf}</div></div>
    </div>
    <div style="text-align:center;font-weight:bold;font-size:13px;border-top:1px solid #000;border-bottom:1px solid #000;padding:4px 0;margin-bottom:12px;">Bon de Livraison N° : <u>${liv.bonNumber}</u></div>
    <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
      <div style="font-size:10px;"><strong>Date :</strong> ${liv.date}</div>
      <div style="border:1px solid #aaa;padding:6px 10px;font-size:10px;min-width:260px;">
        <div style="font-weight:bold;text-align:center;border-bottom:1px solid #ccc;padding-bottom:2px;margin-bottom:4px;">Client</div>
        <div><strong>Code :</strong> ${liv.idClient}</div><div><strong>Raison sociale :</strong> ${liv.clientName}</div>
      </div>
    </div>
    <table style="width:100%;border-collapse:collapse;font-size:10px;margin-bottom:12px;">
      <thead><tr style="background:#f0f0f0;"><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:80px;">Référence</th><th style="border:1px solid #888;padding:4px 6px;">Désignation</th><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:65px;">Quantité</th><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:65px;">TVA(%)</th><th style="border:1px solid #888;padding:4px 6px;text-align:center;width:100px;">Prix Unitaire</th></tr></thead>
      <tbody>${linesHtml}</tbody>
    </table>
    <div style="display:flex;justify-content:flex-end;margin-bottom:20px;">
      <div style="font-size:10px;width:210px;">
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;padding:2px 8px;"><span>Montant HT :</span><strong>${fmt(totalHt)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;border-top:none;padding:2px 8px;"><span>Montant TVA :</span><strong>${fmt(totalTva)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;border-top:none;padding:3px 8px;font-weight:bold;"><span>Montant TTC :</span><span>${fmt(totalTtc)}</span></div>
      </div>
    </div>
    <div style="display:flex;justify-content:space-between;margin-top:30px;font-size:10px;">
      <div style="text-align:center;"><div><strong>Signature et Cachet ${COMPANY.name}</strong></div><div style="margin-top:30px;border-top:1px solid #000;width:130px;"></div></div>
      <div style="text-align:center;"><div><strong>Signature et Cachet Client</strong></div><div style="margin-top:30px;border-top:1px solid #000;width:130px;"></div></div>
    </div>`, `BL ${liv.bonNumber}`);
}

// ─── Print Previews ───────────────────────────────────────────────────────────
function OldBLPreview({ bon }: { bon: OldBonGroup }) {
  return (
    <div className="bg-white text-black font-sans text-[10.5px] w-full">
      <div className="flex items-start justify-between mb-3">
        <img src={logoImg} alt="Logo" className="w-20 h-20 object-contain" />
        <div className="text-right text-[10px] leading-5"><div>{COMPANY.address}</div><div>{COMPANY.phone}</div><div>Matricule Fiscal : {COMPANY.mf}</div></div>
      </div>
      <div className="text-center font-bold text-[13px] border-b border-t border-black py-1 mb-3">Bon de Livraison N° : <span className="underline">{bon.bonNumber}</span></div>
      <div className="flex justify-between mb-3 gap-4">
        <div className="text-[10px]"><span className="font-bold">Date :</span> {bon.date}</div>
        <div className="border border-gray-400 px-3 py-1.5 text-[10px] min-w-[260px]">
          <div className="font-bold text-center border-b border-gray-300 pb-0.5 mb-1">Client</div>
          <div><span className="font-bold">Code :</span> {bon.idClient}</div>
          <div><span className="font-bold">Raison sociale :</span> {bon.client}</div>
        </div>
      </div>
      <table className="w-full border-collapse text-[10px] mb-3">
        <thead><tr className="border border-gray-600 bg-gray-50"><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[80px]">Référence</th><th className="border border-gray-400 px-2 py-1 font-bold">Désignation</th><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[60px]">Quantité</th><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[60px]">TVA(%)</th><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[90px]">Prix Unitaire</th></tr></thead>
        <tbody>
          {bon.lines.map(line => (
            <>
              <tr key={`${line.id}-m`}><td className="border border-gray-300 px-2 py-1 text-center">{line.ref}</td><td className="border border-gray-300 px-2 py-1">{line.designation.trim()}</td><td className="border border-gray-300 px-2 py-1 text-center">{Number(line.qte).toFixed(2)}</td><td className="border border-gray-300 px-2 py-1 text-center">{line.tva.replace('%', '')}</td><td className="border border-gray-300 px-2 py-1 text-right">{fmt(line.prix)}</td></tr>
              {line.serialNumber && <tr key={`${line.id}-s`}><td className="px-2 pb-1"></td><td className="px-2 pb-1 italic text-[9px] text-gray-600">{line.serialNumber}</td><td /><td /><td /></tr>}
            </>
          ))}
        </tbody>
      </table>
      <div className="flex justify-end mb-5">
        <div className="text-[10px] w-[200px]">
          <div className="flex justify-between border border-gray-300 px-2 py-0.5"><span>Montant HT :</span><span className="font-bold">{fmt(bon.totalHt)}</span></div>
          <div className="flex justify-between border-x border-b border-gray-300 px-2 py-0.5"><span>Montant TVA :</span><span className="font-bold">{fmt(bon.totalTva)}</span></div>
          <div className="flex justify-between border-x border-b border-gray-300 px-2 py-0.5 font-bold"><span>Montant TTC :</span><span>{fmt(bon.totalTtc)}</span></div>
        </div>
      </div>
      <div className="flex justify-between mt-8 text-[10px]">
        <div className="text-center"><div className="font-bold">Signature et Cachet {COMPANY.name}</div><div className="mt-8 border-t border-black w-32"></div></div>
        <div className="text-center"><div className="font-bold">Signature et Cachet Client</div><div className="mt-8 border-t border-black w-32"></div></div>
      </div>
    </div>
  );
}

function NewBLPreview({ liv, lines }: { liv: Livraison; lines: LivraisonLine[] }) {
  const totalHt = lines.reduce((s, l) => s + l.montantHt, 0);
  const totalTva = lines.reduce((s, l) => s + l.montantTva, 0);
  const totalTtc = lines.reduce((s, l) => s + l.montantTtc, 0);
  return (
    <div className="bg-white text-black font-sans text-[10.5px] w-full">
      <div className="flex items-start justify-between mb-3">
        <img src={logoImg} alt="Logo" className="w-20 h-20 object-contain" />
        <div className="text-right text-[10px] leading-5"><div>{COMPANY.address}</div><div>{COMPANY.phone}</div><div>Matricule Fiscal : {COMPANY.mf}</div></div>
      </div>
      <div className="text-center font-bold text-[13px] border-b border-t border-black py-1 mb-3">Bon de Livraison N° : <span className="underline">{liv.bonNumber}</span></div>
      <div className="flex justify-between mb-3 gap-4">
        <div className="text-[10px]"><span className="font-bold">Date :</span> {liv.date}</div>
        <div className="border border-gray-400 px-3 py-1.5 text-[10px] min-w-[260px]">
          <div className="font-bold text-center border-b border-gray-300 pb-0.5 mb-1">Client</div>
          <div><span className="font-bold">Code :</span> {liv.idClient}</div>
          <div><span className="font-bold">Raison sociale :</span> {liv.clientName}</div>
        </div>
      </div>
      <table className="w-full border-collapse text-[10px] mb-3">
        <thead><tr className="bg-gray-50"><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[80px]">Référence</th><th className="border border-gray-400 px-2 py-1 font-bold">Désignation</th><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[60px]">Quantité</th><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[60px]">TVA(%)</th><th className="border border-gray-400 px-2 py-1 text-center font-bold w-[90px]">Prix Unitaire</th></tr></thead>
        <tbody>
          {lines.map(l => (
            <>
              <tr key={`${l.id}-m`}><td className="border border-gray-300 px-2 py-1 text-center">{l.ref}</td><td className="border border-gray-300 px-2 py-1">{l.designation.trim()}</td><td className="border border-gray-300 px-2 py-1 text-center">1,00</td><td className="border border-gray-300 px-2 py-1 text-center">{l.tvaPct}</td><td className="border border-gray-300 px-2 py-1 text-right">{fmt(l.prix)}</td></tr>
              {l.serialNumber && <tr key={`${l.id}-s`}><td className="px-2 pb-1"></td><td className="px-2 pb-1 italic text-[9px] text-gray-600">{l.serialNumber}</td><td /><td /><td /></tr>}
            </>
          ))}
        </tbody>
      </table>
      <div className="flex justify-end mb-5">
        <div className="text-[10px] w-[200px]">
          <div className="flex justify-between border border-gray-300 px-2 py-0.5"><span>Montant HT :</span><span className="font-bold">{fmt(totalHt)}</span></div>
          <div className="flex justify-between border-x border-b border-gray-300 px-2 py-0.5"><span>Montant TVA :</span><span className="font-bold">{fmt(totalTva)}</span></div>
          <div className="flex justify-between border-x border-b border-gray-300 px-2 py-0.5 font-bold"><span>Montant TTC :</span><span>{fmt(totalTtc)}</span></div>
        </div>
      </div>
      <div className="flex justify-between mt-8 text-[10px]">
        <div className="text-center"><div className="font-bold">Signature et Cachet {COMPANY.name}</div><div className="mt-8 border-t border-black w-32"></div></div>
        <div className="text-center"><div className="font-bold">Signature et Cachet Client</div><div className="mt-8 border-t border-black w-32"></div></div>
      </div>
    </div>
  );
}

// ─── New Client Dialog ────────────────────────────────────────────────────────
function NewClientDialog({ onCreated, onClose }: { onCreated: (c: Client) => void; onClose: () => void }) {
  const { toast } = useToast();
  const [nomPrenom, setNomPrenom] = useState("");
  const [telephone, setTelephone] = useState("");
  const [adresse, setAdresse] = useState("");
  const [cin, setCin] = useState("");
  const createMut = useMutation({
    mutationFn: async () => { const res = await apiRequest("POST", "/api/clients", { nomPrenom, numeroTelephone: telephone, adresse, cin }); return res.json(); },
    onSuccess: (client: Client) => { queryClient.invalidateQueries({ queryKey: ["/api/clients"] }); toast({ title: "Client créé", description: client.nomPrenom }); onCreated(client); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-sm">
        <DialogHeader><DialogTitle className="flex items-center gap-2"><UserPlus className="w-4 h-4 text-blue-600" />Nouveau client</DialogTitle></DialogHeader>
        <div className="flex flex-col gap-3">
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Nom / Prénom *</label><Input value={nomPrenom} onChange={e => setNomPrenom(e.target.value)} placeholder="Nom complet" data-testid="input-new-client-nom" /></div>
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Téléphone</label><Input value={telephone} onChange={e => setTelephone(e.target.value)} placeholder="(+216) ..." /></div>
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Adresse</label><Input value={adresse} onChange={e => setAdresse(e.target.value)} placeholder="Adresse" /></div>
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">CIN / Matricule fiscal</label><Input value={cin} onChange={e => setCin(e.target.value)} placeholder="CIN ou MF" /></div>
        </div>
        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button onClick={() => createMut.mutate()} disabled={!nomPrenom.trim() || createMut.isPending} className="bg-blue-600 hover:bg-blue-700">
            {createMut.isPending ? "Création..." : "Créer le client"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Client Picker ────────────────────────────────────────────────────────────
function ClientPicker({ clientName, idClient, onSelect, onClear }: {
  clientName: string; idClient: string; onSelect: (c: Client) => void; onClear: () => void;
}) {
  const [clientSearch, setClientSearch] = useState("");
  const [showDropdown, setShowDropdown] = useState(false);
  const [showNewClient, setShowNewClient] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const { data: clients = [] } = useQuery<Client[]>({ queryKey: ["/api/clients"] });

  const filteredClients = useMemo(() => {
    if (!clientSearch.trim()) return [];
    const q = clientSearch.toLowerCase();
    return clients.filter((c: Client) =>
      (c.nomPrenom ?? "").toLowerCase().includes(q) || (c.uniqueNumber ?? "").toLowerCase().includes(q)
    ).slice(0, 8);
  }, [clients, clientSearch]);

  useEffect(() => {
    const handler = (e: MouseEvent) => { if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) setShowDropdown(false); };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  return (
    <div>
      <div className="flex items-center justify-between mb-1">
        <label className="text-xs font-semibold text-gray-600">Client *</label>
        <button type="button" onClick={() => setShowNewClient(true)} className="text-xs text-blue-600 hover:text-blue-800 flex items-center gap-1 font-medium" data-testid="btn-new-client-inline">
          <UserPlus className="w-3 h-3" />Nouveau client
        </button>
      </div>
      {clientName ? (
        <div className="flex items-center gap-2 px-3 py-2 border rounded-lg border-blue-300/50 bg-blue-50/30">
          <span className="flex-1 text-sm font-semibold">{clientName}</span>
          {idClient && <span className="text-xs text-muted-foreground font-mono">{idClient}</span>}
          <button onClick={onClear} className="text-muted-foreground hover:text-foreground" data-testid="btn-clear-client"><X className="w-3.5 h-3.5" /></button>
        </div>
      ) : (
        <div className="relative" ref={dropdownRef}>
          <Input value={clientSearch} onChange={e => { setClientSearch(e.target.value); setShowDropdown(true); }} onFocus={() => clientSearch && setShowDropdown(true)} placeholder="Taper pour rechercher un client..." data-testid="input-client-search" />
          {showDropdown && filteredClients.length > 0 && (
            <div className="absolute top-full left-0 right-0 z-50 bg-white border rounded-lg shadow-lg max-h-48 overflow-y-auto mt-1">
              {filteredClients.map((c: Client) => (
                <button key={c.id} onMouseDown={() => { onSelect(c); setClientSearch(""); setShowDropdown(false); }} className="w-full text-left px-3 py-2 text-sm hover:bg-blue-50/40 flex justify-between items-center gap-2" data-testid={`btn-select-client-${c.id}`}>
                  <span className="font-semibold">{c.nomPrenom}</span>
                  <span className="text-gray-400 text-xs font-mono">{c.uniqueNumber}</span>
                </button>
              ))}
            </div>
          )}
          {showDropdown && clientSearch && filteredClients.length === 0 && (
            <div className="absolute top-full left-0 right-0 z-50 bg-white border rounded-lg shadow-lg mt-1">
              <p className="px-3 py-2 text-sm text-gray-400">Aucun client trouvé. Créez-en un nouveau.</p>
            </div>
          )}
        </div>
      )}
      {showNewClient && <NewClientDialog onCreated={(c) => { onSelect(c); setShowNewClient(false); }} onClose={() => setShowNewClient(false)} />}
    </div>
  );
}

// ─── BL Print Dialog ──────────────────────────────────────────────────────────
function BLPrintDialog({ bl, onClose }: { bl: UnifiedBL; onClose: () => void }) {
  const imgRef = useRef<HTMLImageElement>(null);
  const { data: livDetail } = useQuery<Livraison & { lines: LivraisonLine[] }>({
    queryKey: ["/api/livraisons", (bl as NewBonItem).id],
    enabled: bl.kind === "new",
  });
  const lines = bl.kind === "new" ? (livDetail?.lines ?? []) : [];
  const handlePrint = () => {
    const logoSrc = imgRef.current?.src || logoImg;
    if (bl.kind === "old") triggerPrint(buildOldBLPrintHtml(bl, logoSrc));
    else triggerPrint(buildNewBLPrintHtml(bl as NewBonItem, lines, logoSrc));
  };
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <div className="flex items-center justify-between">
            <DialogTitle className="flex items-center gap-2"><FileText className="w-4 h-4 text-blue-600" />Bon de Livraison — {bl.bonNumber}</DialogTitle>
            <Button onClick={handlePrint} size="sm" className="flex items-center gap-2 mr-8 bg-blue-600 hover:bg-blue-700" data-testid="btn-print-bl-dialog"><Printer className="w-4 h-4" />Imprimer</Button>
          </div>
        </DialogHeader>
        <div className="border rounded p-5 bg-white shadow-inner">
          <img ref={imgRef} src={logoImg} alt="" className="hidden" />
          {bl.kind === "old" ? <OldBLPreview bon={bl} /> : livDetail ? <NewBLPreview liv={bl as NewBonItem} lines={lines} /> : <p className="text-gray-400 text-center py-8">Chargement...</p>}
        </div>
      </DialogContent>
    </Dialog>
  );
}

// ─── BL Detail Dialog (validate/delete) ──────────────────────────────────────
function BLDetailDialog({ bl, onClose }: { bl: NewBonItem; onClose: () => void }) {
  const { toast } = useToast();
  const imgRef = useRef<HTMLImageElement>(null);
  const { data: liv, isLoading } = useQuery<Livraison & { lines: LivraisonLine[] }>({ queryKey: ["/api/livraisons", bl.id] });
  const lines = liv?.lines ?? [];
  const totals = lines.reduce((acc, l) => ({ ht: acc.ht + l.montantHt, tva: acc.tva + l.montantTva, ttc: acc.ttc + l.montantTtc }), { ht: 0, tva: 0, ttc: 0 });
  const isDraft = (liv?.status ?? bl.status) === "draft";

  const validateMut = useMutation({
    mutationFn: () => apiRequest("POST", `/api/livraisons/${bl.id}/validate`),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/livraisons"] }); queryClient.invalidateQueries({ queryKey: ["/api/livraisons", bl.id] }); queryClient.invalidateQueries({ queryKey: ["/api/stock/products"] }); toast({ title: "Bon validé ✓" }); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  const deleteMut = useMutation({
    mutationFn: () => apiRequest("DELETE", `/api/livraisons/${bl.id}`),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["/api/livraisons"] }); toast({ title: "Bon supprimé" }); onClose(); },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  const handlePrint = () => {
    if (!liv) return;
    triggerPrint(buildNewBLPrintHtml(liv, lines, imgRef.current?.src || logoImg));
  };

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <div className="flex items-center justify-between flex-wrap gap-2">
            <div className="flex items-center gap-3">
              <DialogTitle className="flex items-center gap-2"><FileText className="w-4 h-4 text-blue-600" />BL N° {bl.bonNumber}</DialogTitle>
              <Badge variant="secondary" className={isDraft ? "bg-amber-100 text-amber-800" : "bg-green-100 text-green-800"}>
                {isDraft ? "Brouillon" : "✓ Validé"}
              </Badge>
            </div>
            <div className="flex gap-2 mr-8">
              <Button variant="outline" size="sm" onClick={handlePrint} className="gap-1" data-testid="btn-print-bl-detail"><Printer className="w-3.5 h-3.5" />Imprimer</Button>
              {isDraft && (
                <>
                  <Button variant="outline" size="sm" className="gap-1 text-rose-600 border-rose-200 hover:bg-rose-50" onClick={() => deleteMut.mutate()} disabled={deleteMut.isPending} data-testid="btn-delete-bl-detail"><Trash2 className="w-3.5 h-3.5" />Supprimer</Button>
                  <Button size="sm" className="gap-1 bg-blue-700 hover:bg-blue-800" onClick={() => validateMut.mutate()} disabled={lines.length === 0 || validateMut.isPending} data-testid="btn-validate-bl-detail"><CheckCircle2 className="w-3.5 h-3.5" />{validateMut.isPending ? "Validation..." : "Valider"}</Button>
                </>
              )}
            </div>
          </div>
        </DialogHeader>
        <img ref={imgRef} src={logoImg} alt="" className="hidden" />
        {isLoading ? (
          <p className="text-center text-gray-400 py-8">Chargement...</p>
        ) : (
          <>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm mb-4">
              {[["Date", liv?.date ?? "—"], ["Commercial", liv?.commercial ?? "—"], ["Client", liv?.clientName ?? "—"], ["ID Client", liv?.idClient ?? "—"]].map(([label, val]) => (
                <div key={label}><span className="text-[10px] font-black uppercase text-gray-400">{label}</span><p className="font-semibold truncate">{val}</p></div>
              ))}
            </div>
            <div className="overflow-x-auto border rounded-xl">
              <table className="w-full text-sm">
                <thead className="bg-gray-50 border-b"><tr>{["Réf.", "Désignation", "N° Série", "Prix HT", "TVA%", "Remise%", "Montant TTC"].map(h => <th key={h} className="px-3 py-2 text-left text-xs font-black text-gray-500 uppercase whitespace-nowrap">{h}</th>)}</tr></thead>
                <tbody>
                  {lines.map(l => (
                    <tr key={l.id} className="border-b last:border-0 hover:bg-gray-50">
                      <td className="px-3 py-2.5 font-mono font-bold text-blue-700 text-xs">{l.ref}</td>
                      <td className="px-3 py-2.5 font-semibold">{l.designation}</td>
                      <td className="px-3 py-2.5 font-mono text-xs text-green-700 font-bold">{l.serialNumber || "—"}</td>
                      <td className="px-3 py-2.5 font-mono text-xs">{fmt(l.prix)}</td>
                      <td className="px-3 py-2.5 text-xs">{l.tvaPct}%</td>
                      <td className="px-3 py-2.5 text-xs">{l.remise}%</td>
                      <td className="px-3 py-2.5 font-mono font-bold text-xs">{fmt(l.montantTtc)}</td>
                    </tr>
                  ))}
                  {lines.length === 0 && <tr><td colSpan={7} className="px-3 py-6 text-center text-gray-400">Aucune ligne.</td></tr>}
                </tbody>
              </table>
            </div>
            <div className="flex justify-end mt-3">
              <div className="bg-gray-50 border rounded-xl px-4 py-3 flex gap-6 text-xs">
                <div><span className="text-gray-400 uppercase font-bold block">HT</span><span className="font-mono font-bold">{fmt(totals.ht)} TND</span></div>
                <div><span className="text-gray-400 uppercase font-bold block">TVA</span><span className="font-mono font-bold">{fmt(totals.tva)} TND</span></div>
                <div><span className="text-blue-600 uppercase font-bold block">TTC</span><span className="font-mono font-black text-blue-700">{fmt(totals.ttc)} TND</span></div>
              </div>
            </div>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
}

// ─── BL Delete Dialog ─────────────────────────────────────────────────────────
function BLDeleteDialog({ bl, onClose, onDeleted }: { bl: UnifiedBL; onClose: () => void; onDeleted: () => void }) {
  const { toast } = useToast();
  const clientLabel = bl.kind === "new" ? bl.clientName : bl.client;
  const deleteMut = useMutation({
    mutationFn: () => bl.kind === "new"
      ? apiRequest("DELETE", `/api/livraisons/${(bl as NewBonItem).id}`)
      : apiRequest("DELETE", `/api/bons-livraison/${encodeURIComponent(bl.bonNumber)}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/livraisons"] });
      queryClient.invalidateQueries({ queryKey: ["/api/delivery-notes"] });
      queryClient.invalidateQueries({ queryKey: ["/api/delivery-note-lines"] });
      toast({ title: "Bon supprimé" });
      onDeleted();
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-sm">
        <DialogHeader><DialogTitle className="flex items-center gap-2 text-destructive"><AlertCircle className="w-5 h-5" />Supprimer le BL</DialogTitle></DialogHeader>
        <p className="text-sm text-muted-foreground">Voulez-vous vraiment supprimer le <strong>BL {bl.bonNumber}</strong> ({clientLabel}) ? Cette action est irréversible.</p>
        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button variant="destructive" onClick={() => deleteMut.mutate()} disabled={deleteMut.isPending} data-testid="btn-confirm-delete-bl">
            {deleteMut.isPending ? "Suppression..." : "Supprimer"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── BL Create Dialog ─────────────────────────────────────────────────────────
function BLFormDialog({ onClose, onSaved }: { onClose: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const today = new Date().toLocaleDateString("fr-TN", { day: "2-digit", month: "2-digit", year: "numeric" });
  const [date, setDate] = useState(today);
  const [commercial, setCommercial] = useState("HADJ SALEM Karim");
  const [clientName, setClientName] = useState("");
  const [idClient, setIdClient] = useState("");
  const [productSearch, setProductSearch] = useState("");
  const [filterFamily, setFilterFamily] = useState("all");
  const [serialModal, setSerialModal] = useState<{ product: Product } | null>(null);
  const [draftLines, setDraftLines] = useState<LivraisonLine[]>([]);

  const { data: nextNumber } = useQuery<{ bonNumber: string }>({ queryKey: ["/api/livraisons/next-number"] });
  const { data: families = [] } = useQuery<ProductFamily[]>({ queryKey: ["/api/product-families"] });
  const { data: products = [] } = useQuery<Product[]>({
    queryKey: ["/api/stock/products", filterFamily, productSearch],
    queryFn: () => {
      const p = new URLSearchParams();
      if (filterFamily !== "all") p.set("familyId", filterFamily);
      if (productSearch) p.set("search", productSearch);
      return fetch(`/api/stock/products?${p}`, { credentials: "include" }).then(r => r.json());
    },
  });
  const { data: availableSerials = [], isLoading: loadingSerials } = useQuery<ProductSerial[]>({
    queryKey: ["/api/stock/serials", serialModal?.product?.id, "available"],
    queryFn: () => serialModal ? fetch(`/api/stock/serials?productId=${serialModal.product.id}&available=true`, { credentials: "include" }).then(r => r.json()) : Promise.resolve([]),
    enabled: !!serialModal,
  });

  const selectSerial = (serial: ProductSerial) => {
    if (!serialModal) return;
    const p = serialModal.product;
    const c = calcLine(p.defaultPrice, p.tvaPct, 0);
    setDraftLines(prev => [...prev, { id: Date.now(), ref: p.reference, designation: p.designation, serialNumber: serial.serialNumber, prix: p.defaultPrice, purchasePrice: serial.purchasePrice, tvaPct: p.tvaPct, remise: 0, prixTtc: c.ttc, montantHt: c.ht, montantTva: c.tva, montantTtc: c.ttc, productSerialId: serial.id }]);
    setSerialModal(null);
  };
  const updateDraftLine = (id: number, field: "prix" | "remise", value: number) => setDraftLines(prev => prev.map(l => { if (l.id !== id) return l; const prix = field === "prix" ? value : l.prix; const remise = field === "remise" ? value : l.remise; const c = calcLine(prix, l.tvaPct, remise); return { ...l, prix, remise, prixTtc: c.ttc, montantHt: c.ht, montantTva: c.tva, montantTtc: c.ttc }; }));
  const removeDraftLine = (id: number) => setDraftLines(prev => prev.filter(l => l.id !== id));
  const totals = draftLines.reduce((acc, l) => ({ ht: acc.ht + l.montantHt, tva: acc.tva + l.montantTva, ttc: acc.ttc + l.montantTtc }), { ht: 0, tva: 0, ttc: 0 });

  const createMut = useMutation({
    mutationFn: async () => {
      const res = await apiRequest("POST", "/api/livraisons", { bonNumber: nextNumber?.bonNumber, date, commercial, clientName, idClient, status: "draft" });
      const liv: Livraison = await res.json();
      for (const line of draftLines) {
        await apiRequest("POST", `/api/livraisons/${liv.id}/lines`, { ref: line.ref, designation: line.designation, serialNumber: line.serialNumber, prix: line.prix, tvaPct: line.tvaPct, remise: line.remise, prixTtc: line.prixTtc, montantHt: line.montantHt, montantTva: line.montantTva, montantTtc: line.montantTtc, productSerialId: line.productSerialId });
      }
      return liv;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/livraisons"] });
      queryClient.invalidateQueries({ queryKey: ["/api/livraisons/next-number"] });
      queryClient.invalidateQueries({ queryKey: ["/api/stock/products"] });
      toast({ title: "Bon créé", description: `${nextNumber?.bonNumber} — ${draftLines.length} ligne(s)` });
      onSaved();
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  const canSave = draftLines.length > 0 && !!clientName.trim();

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto">
        <DialogHeader><DialogTitle>Nouveau Bon de Livraison</DialogTitle></DialogHeader>
        <div className="flex flex-col gap-4">
          <Card>
            <CardHeader className="pb-2"><CardTitle className="text-sm font-bold uppercase text-gray-500">En-tête</CardTitle></CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">N° BL</label><Input value={nextNumber?.bonNumber ?? ""} readOnly className="bg-gray-50 font-mono font-bold" data-testid="input-livraison-number" /></div>
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Date</label><Input value={date} onChange={e => setDate(e.target.value)} data-testid="input-livraison-date" /></div>
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Commercial</label><Input value={commercial} onChange={e => setCommercial(e.target.value)} data-testid="input-livraison-commercial" /></div>
              </div>
              <div className="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-3">
                <ClientPicker clientName={clientName} idClient={idClient} onSelect={c => { setClientName(c.nomPrenom); setIdClient(c.uniqueNumber ?? ""); }} onClear={() => { setClientName(""); setIdClient(""); }} />
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Code client</label><Input value={idClient} onChange={e => setIdClient(e.target.value)} placeholder="411100xxx" data-testid="input-livraison-idclient" /></div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2"><CardTitle className="text-sm font-bold uppercase text-gray-500">Ajouter un produit</CardTitle></CardHeader>
            <CardContent>
              <div className="flex gap-3 flex-wrap mb-3">
                <Select value={filterFamily} onValueChange={setFilterFamily}>
                  <SelectTrigger className="w-44" data-testid="select-livraison-family"><SelectValue placeholder="Famille" /></SelectTrigger>
                  <SelectContent><SelectItem value="all">Toutes familles</SelectItem>{families.map(f => <SelectItem key={f.id} value={f.id.toString()}>{f.name}</SelectItem>)}</SelectContent>
                </Select>
                <div className="relative flex-1 min-w-48">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <Input className="pl-9" placeholder="Réf. ou désignation..." value={productSearch} onChange={e => setProductSearch(e.target.value)} data-testid="input-search-product-livraison" />
                </div>
              </div>
              <div className="overflow-x-auto border rounded-xl">
                <table className="w-full text-sm">
                  <thead className="bg-gray-50 border-b"><tr>{["Réf.", "Désignation", "Famille", "Prix vente", "TVA", "Qté dispo", ""].map(h => <th key={h} className="px-3 py-2 text-left text-xs font-bold text-gray-500">{h}</th>)}</tr></thead>
                  <tbody>
                    {products.slice(0, 8).map((p: Product) => (
                      <tr key={p.id} className="border-b last:border-0 hover:bg-blue-50/40 transition-colors" data-testid={`row-product-bl-${p.id}`}>
                        <td className="px-3 py-2 font-mono font-bold text-blue-700 text-xs">{p.reference}</td>
                        <td className="px-3 py-2 text-sm">{p.designation}</td>
                        <td className="px-3 py-2 text-gray-400 text-xs">{p.familyName ?? "—"}</td>
                        <td className="px-3 py-2 font-mono text-xs">{fmt(p.defaultPrice)} TND</td>
                        <td className="px-3 py-2 text-gray-500 text-xs">{p.tvaPct}%</td>
                        <td className="px-3 py-2">
                          <Badge variant="secondary" className={p.availableQty > 0 ? "bg-green-100 text-green-800 hover:bg-green-100" : "bg-red-100 text-red-800 hover:bg-red-100"} data-testid={`text-dispo-${p.id}`}>{p.availableQty}</Badge>
                        </td>
                        <td className="px-3 py-2">
                          <Button size="sm" variant="outline" disabled={!p.availableQty} onClick={() => setSerialModal({ product: p })} className="gap-1 text-xs" data-testid={`button-select-serial-${p.id}`}>
                            Choisir N/S <ChevronRight className="w-3 h-3" />
                          </Button>
                        </td>
                      </tr>
                    ))}
                    {products.length === 0 && <tr><td colSpan={7} className="px-3 py-6 text-center text-gray-400">Aucun produit.</td></tr>}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>

          {draftLines.length > 0 && (
            <Card>
              <CardHeader className="pb-2"><CardTitle className="text-sm font-bold uppercase text-gray-500">Lignes — {draftLines.length} article(s)</CardTitle></CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead className="border-b"><tr>{["Réf.", "Désignation", "N° Série", "Prix HT", "TVA%", "Remise%", "TTC", ""].map(h => <th key={h} className="px-2 py-1.5 text-left text-xs font-bold text-gray-500">{h}</th>)}</tr></thead>
                    <tbody>
                      {draftLines.map(l => (
                        <tr key={l.id} className="border-b last:border-0">
                          <td className="px-1 py-1 font-mono font-bold text-blue-700 text-xs">{l.ref}</td>
                          <td className="px-1 py-1 text-gray-700 max-w-40 truncate text-xs">{l.designation}</td>
                          <td className="px-1 py-1 font-mono text-xs text-green-700 font-bold">{l.serialNumber || "—"}</td>
                          <td className="px-1 py-1"><Input type="number" step="0.001" value={l.prix} onChange={e => updateDraftLine(l.id, "prix", Number(e.target.value))} className="h-7 w-24 text-xs" /></td>
                          <td className="px-1 py-1 text-gray-500 text-xs">{l.tvaPct}%</td>
                          <td className="px-1 py-1"><Input type="number" value={l.remise} onChange={e => updateDraftLine(l.id, "remise", Number(e.target.value))} className="h-7 w-14 text-xs text-center" /></td>
                          <td className="px-1 py-1 font-mono font-bold text-xs whitespace-nowrap">{fmt(l.montantTtc)}</td>
                          <td className="px-1 py-1"><Button variant="ghost" size="icon" className="h-6 w-6 text-destructive" onClick={() => removeDraftLine(l.id)}><Trash2 className="w-3 h-3" /></Button></td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="flex justify-end mt-3">
                  <div className="text-xs bg-gray-50 border rounded p-3 flex gap-4">
                    <div><span className="text-gray-400 uppercase font-bold">HT</span><p className="font-mono font-bold">{fmt(totals.ht)}</p></div>
                    <div><span className="text-gray-400 uppercase font-bold">TVA</span><p className="font-mono font-bold">{fmt(totals.tva)}</p></div>
                    <div><span className="text-blue-600 uppercase font-bold">TTC</span><p className="font-mono font-black text-blue-600">{fmt(totals.ttc)}</p></div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        <DialogFooter className="gap-2">
          {!clientName && <p className="text-sm text-amber-600 flex items-center gap-1 mr-auto"><AlertCircle className="w-4 h-4" />Saisir le client avant d'enregistrer.</p>}
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button onClick={() => createMut.mutate()} disabled={!canSave || createMut.isPending} className="bg-blue-600 hover:bg-blue-700" data-testid="button-save-livraison">
            {createMut.isPending ? "Enregistrement..." : "Créer le bon"}
          </Button>
        </DialogFooter>

        {/* Serial picker sub-dialog */}
        <Dialog open={!!serialModal} onOpenChange={o => !o && setSerialModal(null)}>
          <DialogContent className="max-w-md">
            <DialogHeader><DialogTitle>Choisir un numéro de série</DialogTitle></DialogHeader>
            {serialModal && (
              <div className="flex flex-col gap-3">
                <p className="text-sm font-semibold text-gray-700">{serialModal.product.designation}</p>
                {loadingSerials && <p className="text-center text-gray-400 py-4">Chargement...</p>}
                <div className="max-h-64 overflow-y-auto flex flex-col gap-1">
                  {availableSerials.filter(s => !draftLines.some(l => l.productSerialId === s.id)).map(s => (
                    <button key={s.id} onClick={() => selectSerial(s)} className="w-full flex items-center justify-between px-3 py-2.5 rounded-lg border hover:bg-blue-50 hover:border-blue-300 transition-colors text-sm" data-testid={`button-serial-${s.id}`}>
                      <span className="font-mono font-bold text-gray-800">{s.serialNumber}</span>
                      <span className="text-xs text-orange-600 font-mono">{formatNum3(s.purchasePrice)} TND achat</span>
                    </button>
                  ))}
                  {!loadingSerials && availableSerials.filter(s => !draftLines.some(l => l.productSerialId === s.id)).length === 0 && (
                    <div className="text-center py-4 text-gray-400"><AlertCircle className="w-6 h-6 mx-auto mb-1 text-amber-400" /><p className="text-sm font-semibold">Aucun numéro disponible.</p></div>
                  )}
                </div>
                <div className="border-t pt-3">
                  <p className="text-xs text-gray-500 mb-2">Produit sans numéro de série :</p>
                  <Button variant="outline" size="sm" className="w-full text-sm" onClick={() => {
                    if (!serialModal) return;
                    const p = serialModal.product;
                    const c = calcLine(p.defaultPrice, p.tvaPct, 0);
                    setDraftLines(prev => [...prev, { id: Date.now(), ref: p.reference, designation: p.designation, serialNumber: "", prix: p.defaultPrice, purchasePrice: undefined, tvaPct: p.tvaPct, remise: 0, prixTtc: c.ttc, montantHt: c.ht, montantTva: c.tva, montantTtc: c.ttc }]);
                    setSerialModal(null);
                  }}>Ajouter sans numéro de série</Button>
                </div>
              </div>
            )}
            <DialogFooter><Button variant="outline" onClick={() => setSerialModal(null)}>Annuler</Button></DialogFooter>
          </DialogContent>
        </Dialog>
      </DialogContent>
    </Dialog>
  );
}

// ─── Old BL Edit Dialog (manager-only) ────────────────────────────────────────
function OldBLEditDialog({ bl, onClose, onSaved }: { bl: OldBonGroup; onClose: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const [date, setDate] = useState(bl.date);
  const [client, setClient] = useState(bl.client);
  const [idClient, setIdClient] = useState(bl.idClient);
  const [factureNumber, setFactureNumber] = useState(bl.factureNumber);
  const [lines, setLines] = useState(() => bl.lines.map(l => ({
    id: l.id,
    ref: l.ref,
    designation: l.designation,
    qte: l.qte,
    prix: l.prix,
    tva: l.tva,
    remise: l.remise,
    serialNumber: l.serialNumber,
    matriculeFiscal: l.matriculeFiscal,
    adresseClient: l.adresseClient,
    phoneClient: l.phoneClient,
    commercial: l.commercial,
  })));

  const updateLine = (id: number, field: string, value: any) =>
    setLines(prev => prev.map(l => l.id === id ? { ...l, [field]: value } : l));
  const removeLine = (id: number) => setLines(prev => prev.filter(l => l.id !== id));
  const addLine = () => setLines(prev => [...prev, {
    id: Date.now(), ref: "", designation: "", qte: 1, prix: 0, tva: "19%", remise: 0,
    serialNumber: "", matriculeFiscal: "", adresseClient: "", phoneClient: "", commercial: bl.commercial,
  }]);

  const totals = lines.reduce((acc, l) => {
    const tvaPct = parseFloat(String(l.tva).replace("%", "").trim()) || 0;
    const c = calcLine(l.prix, tvaPct, l.remise);
    return { ht: acc.ht + c.ht * l.qte, tva: acc.tva + c.tva * l.qte, ttc: acc.ttc + c.ttc * l.qte };
  }, { ht: 0, tva: 0, ttc: 0 });

  const saveMut = useMutation({
    mutationFn: async () => {
      if (lines.length === 0) throw new Error("Ajoutez au moins une ligne.");
      if (!client.trim()) throw new Error("Le nom du client est requis.");
      const payload = lines.map(l => {
        const tvaPct = parseFloat(String(l.tva).replace("%", "").trim()) || 0;
        const c = calcLine(l.prix, tvaPct, l.remise);
        return {
          bonNumber: bl.bonNumber, date, commercial: l.commercial || bl.commercial,
          client, idClient, matriculeFiscal: l.matriculeFiscal || "", adresseClient: l.adresseClient || "", phoneClient: l.phoneClient || "",
          factureNumber, ref: l.ref, designation: l.designation,
          qte: l.qte, prix: l.prix, tva: l.tva, remise: l.remise,
          prixTtc: c.ttc, montantHt: c.ht * l.qte, montantTva: c.tva * l.qte, montantTtc: c.ttc * l.qte,
          serialNumber: l.serialNumber || "",
        };
      });
      await apiRequest("PUT", `/api/bons-livraison/${encodeURIComponent(bl.bonNumber)}`, { lines: payload });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/bons-livraison"] });
      queryClient.invalidateQueries({ queryKey: ["/api/factures"] });
      toast({ title: "BL modifié", description: `BL ${bl.bonNumber} enregistré.` });
      onSaved();
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Modifier BL {bl.bonNumber}</DialogTitle>
        </DialogHeader>
        <div className="flex flex-col gap-4">
          <Card>
            <CardHeader className="pb-2"><CardTitle className="text-sm font-bold uppercase text-gray-500">En-tête</CardTitle></CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div><label className="text-xs font-semibold">Date</label><Input value={date} onChange={e => setDate(e.target.value)} data-testid="input-edit-bl-date" /></div>
                <div><label className="text-xs font-semibold">N° Facture</label><Input value={factureNumber} onChange={e => setFactureNumber(e.target.value)} data-testid="input-edit-bl-facture" /></div>
                <div className="col-span-2 sm:col-span-1"><label className="text-xs font-semibold">Client</label><Input value={client} onChange={e => setClient(e.target.value)} data-testid="input-edit-bl-client" /></div>
                <div><label className="text-xs font-semibold">ID Client</label><Input value={idClient} onChange={e => setIdClient(e.target.value)} data-testid="input-edit-bl-idclient" /></div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2 flex flex-row items-center justify-between">
              <CardTitle className="text-sm font-bold uppercase text-gray-500">Lignes</CardTitle>
              <Button size="sm" variant="outline" onClick={addLine} className="gap-1" data-testid="btn-add-edit-bl-line"><Plus className="w-3 h-3" />Ajouter</Button>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-xs">
                  <thead className="bg-muted/50">
                    <tr className="text-left">
                      <th className="px-2 py-1 font-semibold">Réf</th>
                      <th className="px-2 py-1 font-semibold">Désignation</th>
                      <th className="px-2 py-1 font-semibold w-16">Qté</th>
                      <th className="px-2 py-1 font-semibold w-24">Prix HT</th>
                      <th className="px-2 py-1 font-semibold w-16">TVA</th>
                      <th className="px-2 py-1 font-semibold w-16">Rem.%</th>
                      <th className="px-2 py-1 font-semibold">N° Série</th>
                      <th className="px-2 py-1 font-semibold w-8"></th>
                    </tr>
                  </thead>
                  <tbody>
                    {lines.map(l => (
                      <tr key={l.id} className="border-t">
                        <td className="px-1 py-1"><Input value={l.ref} onChange={e => updateLine(l.id, "ref", e.target.value)} className="h-7 text-xs" /></td>
                        <td className="px-1 py-1"><Input value={l.designation} onChange={e => updateLine(l.id, "designation", e.target.value)} className="h-7 text-xs" /></td>
                        <td className="px-1 py-1"><Input type="number" value={l.qte} onChange={e => updateLine(l.id, "qte", parseFloat(e.target.value) || 0)} className="h-7 text-xs" /></td>
                        <td className="px-1 py-1"><Input type="number" step="0.001" value={l.prix} onChange={e => updateLine(l.id, "prix", parseFloat(e.target.value) || 0)} className="h-7 text-xs" /></td>
                        <td className="px-1 py-1"><Input value={l.tva} onChange={e => updateLine(l.id, "tva", e.target.value)} className="h-7 text-xs" /></td>
                        <td className="px-1 py-1"><Input type="number" value={l.remise} onChange={e => updateLine(l.id, "remise", parseFloat(e.target.value) || 0)} className="h-7 text-xs" /></td>
                        <td className="px-1 py-1"><Input value={l.serialNumber} onChange={e => updateLine(l.id, "serialNumber", e.target.value)} className="h-7 text-xs" /></td>
                        <td className="px-1 py-1"><Button variant="ghost" size="icon" className="h-6 w-6 text-destructive" onClick={() => removeLine(l.id)}><Trash2 className="w-3 h-3" /></Button></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="mt-3 flex justify-end gap-6 text-sm">
                <span>HT: <span className="font-bold tabular-nums">{fmt(totals.ht)}</span></span>
                <span>TVA: <span className="font-bold tabular-nums">{fmt(totals.tva)}</span></span>
                <span>TTC: <span className="font-bold tabular-nums text-blue-700">{fmt(totals.ttc)}</span></span>
              </div>
            </CardContent>
          </Card>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button onClick={() => saveMut.mutate()} disabled={saveMut.isPending} className="bg-blue-600 hover:bg-blue-700" data-testid="btn-save-edit-bl">
            {saveMut.isPending ? "Enregistrement..." : "Enregistrer"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Main Page ────────────────────────────────────────────────────────────────
export default function LivraisonPage() {
  const [showCreate, setShowCreate] = useState(false);
  const [printBL, setPrintBL] = useState<UnifiedBL | null>(null);
  const [detailBL, setDetailBL] = useState<NewBonItem | null>(null);
  const [editOldBL, setEditOldBL] = useState<OldBonGroup | null>(null);
  const [deleteBL, setDeleteBL] = useState<UnifiedBL | null>(null);
  const [search, setSearch] = useState("");
  const { toast } = useToast();

  const { data: newLivraisons = [], isLoading: loadingNew } = useQuery<Livraison[]>({ queryKey: ["/api/livraisons"] });
  const { data: oldLines = [], isLoading: loadingOld } = useQuery<DeliveryNoteLine[]>({ queryKey: ["/api/bons-livraison"] });
  const { data: currentUser } = useQuery<{ role?: string }>({ queryKey: ["/api/user"] });
  const isManager = currentUser?.role === "manager";

  const oldBons = useMemo(() => groupByBon(oldLines), [oldLines]);

  const unified: UnifiedBL[] = useMemo(() => {
    const items: UnifiedBL[] = [
      ...oldBons.map(b => b as UnifiedBL),
      ...newLivraisons.map(l => ({ kind: "new" as const, ...l })),
    ];
    return items.sort((a, b) => b.bonNumber.localeCompare(a.bonNumber));
  }, [oldBons, newLivraisons]);

  const filtered = useMemo(() => {
    const q = search.toLowerCase().trim();
    if (!q) return unified;
    return unified.filter(bl => {
      const client = bl.kind === "old" ? bl.client : bl.clientName;
      return bl.bonNumber.toLowerCase().includes(q) || client.toLowerCase().includes(q) || bl.date.toLowerCase().includes(q);
    });
  }, [unified, search]);

  const isLoading = loadingNew || loadingOld;
  const totalBLs = unified.length;
  const filteredTotal = filtered.reduce((s, bl) => s + (bl.kind === "old" ? bl.totalTtc : (bl.totalTtc ?? 0)), 0);

  return (
    <Dashboard contentOnly>
      <div className="flex flex-col gap-4 h-full">

        {/* Page header */}
        <div className="flex items-center gap-3">
          <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-blue-50 border border-blue-100 shrink-0">
            <FileText className="w-5 h-5 text-blue-600" />
          </div>
          <div className="min-w-0">
            <h2 className="text-lg font-black tracking-tight leading-none">Bons de Livraison</h2>
            <p className="text-xs text-muted-foreground mt-0.5">
              {totalBLs} BL{totalBLs !== 1 ? "s" : ""} &nbsp;·&nbsp; Total : <span className="font-semibold text-foreground">{fmt(filteredTotal)} TND</span>
            </p>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <div className="relative w-64">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
              <Input data-testid="input-search-bl" className="pl-9 h-9 text-sm" placeholder="N° BL, client, date..." value={search} onChange={e => setSearch(e.target.value)} />
              {search && <button onClick={() => setSearch("")} className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"><X className="w-4 h-4" /></button>}
            </div>
            <Button className="h-9 gap-1.5 shrink-0 bg-blue-600 hover:bg-blue-700" onClick={() => setShowCreate(true)} data-testid="button-new-livraison">
              <Plus className="w-4 h-4" />Nouveau BL
            </Button>
          </div>
        </div>

        {/* Table */}
        <div className="rounded-xl border bg-card shadow-sm overflow-hidden flex-1 flex flex-col min-h-0">
          {isLoading ? (
            <div className="flex items-center justify-center flex-1 text-muted-foreground gap-2">
              <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin" />Chargement...
            </div>
          ) : filtered.length === 0 ? (
            <div className="flex flex-col items-center justify-center flex-1 gap-3 text-muted-foreground py-16">
              <div className="w-14 h-14 rounded-2xl bg-muted/50 flex items-center justify-center"><FileText className="w-7 h-7 opacity-40" /></div>
              <div className="text-center">
                <p className="font-semibold text-sm">Aucun bon de livraison trouvé</p>
                {search && <p className="text-xs mt-1">Essayez d'autres termes de recherche</p>}
              </div>
            </div>
          ) : (
            <>
              <div className="overflow-x-auto overflow-y-auto flex-1">
                <table className="w-full text-sm min-w-[760px]">
                  <thead className="sticky top-0 z-10">
                    <tr className="bg-muted/60 backdrop-blur border-b border-border">
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">N° BL</th>
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Date</th>
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider">Client</th>
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">N° Facture</th>
                      <th className="text-center px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Statut</th>
                      <th className="text-center px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Lignes</th>
                      <th className="text-right px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Total TTC</th>
                      <th className="px-3 py-2.5 text-right font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/40">
                    {filtered.map(bl => {
                      const client = bl.kind === "old" ? bl.client : bl.clientName;
                      const idCl = bl.idClient;
                      const factNum = bl.kind === "old" ? bl.factureNumber : bl.factureNumber;
                      const lineCount = bl.lines?.length ?? 0;
                      return (
                        <tr key={`${bl.kind}-${bl.bonNumber}`} data-testid={`row-bl-${bl.bonNumber}`}
                          className="hover:bg-blue-50/40 dark:hover:bg-blue-950/20 transition-colors group cursor-pointer"
                          onClick={() => setPrintBL(bl)}>
                          <td className="px-4 py-3"><span className="font-mono font-bold text-blue-700 text-xs tracking-wide">{bl.bonNumber}</span></td>
                          <td className="px-4 py-3 text-muted-foreground text-xs whitespace-nowrap">{bl.date}</td>
                          <td className="px-4 py-3 max-w-[200px]">
                            <span className="font-medium text-sm truncate block">{client}</span>
                            {idCl && <span className="text-[10px] text-muted-foreground font-mono">{idCl}</span>}
                          </td>
                          <td className="px-4 py-3 text-xs font-mono">
                            {factNum
                              ? <span className="text-emerald-700 font-semibold">{factNum}</span>
                              : <span className="text-muted-foreground/50">—</span>}
                          </td>
                          <td className="px-4 py-3 text-center">
                            {bl.kind === "old" ? (
                              <Badge variant="secondary" className="bg-gray-100 text-gray-600 hover:bg-gray-100 gap-1 text-[10px]"><History className="w-3 h-3" />Historique</Badge>
                            ) : bl.status === "validated" ? (
                              <Badge variant="secondary" className="bg-green-100 text-green-800 hover:bg-green-100 text-[10px]">✓ Validé</Badge>
                            ) : (
                              <Badge variant="secondary" className="bg-amber-100 text-amber-800 hover:bg-amber-100 text-[10px]">Brouillon</Badge>
                            )}
                          </td>
                          <td className="px-4 py-3 text-center">
                            <Badge variant="secondary" className="text-[11px] px-2">{lineCount ?? "—"}</Badge>
                          </td>
                          <td className="px-4 py-3 text-right">
                            <span className="font-bold tabular-nums text-sm">
                              {bl.kind === "old" ? fmt(bl.totalTtc) : bl.totalTtc ? fmt(bl.totalTtc) : "—"}
                            </span>
                            {(bl.kind === "old" || bl.totalTtc) && <span className="text-muted-foreground text-xs ml-1">TND</span>}
                          </td>
                          <td className="px-3 py-3" onClick={e => e.stopPropagation()}>
                            <div className="flex gap-0.5 justify-end items-center">
                              <Button variant="ghost" size="sm" className="h-7 w-7 p-0 text-muted-foreground hover:text-foreground hover:bg-muted" onClick={() => setPrintBL(bl)} title="Aperçu & Imprimer" data-testid={`btn-print-bl-${bl.bonNumber}`}>
                                <Printer className="w-3.5 h-3.5" />
                              </Button>
                              {isManager && (
                                <>
                                  <Button
                                    variant="ghost" size="sm"
                                    className="h-7 w-7 p-0 text-blue-500 hover:text-blue-700 hover:bg-blue-50"
                                    onClick={() => {
                                      if (bl.kind === "new") setDetailBL(bl as NewBonItem);
                                      else setEditOldBL(bl as OldBonGroup);
                                    }}
                                    title={bl.kind === "new" ? "Détail / Valider" : "Modifier"}
                                    data-testid={`btn-edit-bl-${bl.bonNumber}`}
                                  >
                                    <Pencil className="w-3.5 h-3.5" />
                                  </Button>
                                  <Button
                                    variant="ghost" size="sm"
                                    className="h-7 w-7 p-0 text-rose-400 hover:text-rose-600 hover:bg-rose-50"
                                    onClick={() => setDeleteBL(bl)}
                                    title="Supprimer"
                                    data-testid={`btn-delete-bl-${bl.bonNumber}`}
                                  >
                                    <Trash2 className="w-3.5 h-3.5" />
                                  </Button>
                                </>
                              )}
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
              {/* Footer summary */}
              <div className="border-t bg-muted/30 px-4 py-2 flex items-center justify-between shrink-0">
                <span className="text-xs text-muted-foreground">
                  {search ? `${filtered.length} résultat${filtered.length !== 1 ? "s" : ""} sur ${totalBLs}` : `${totalBLs} BL${totalBLs !== 1 ? "s" : ""}`}
                </span>
                <span className="text-xs font-bold">Total affiché : <span className="text-blue-700 tabular-nums">{fmt(filteredTotal)} TND</span></span>
              </div>
            </>
          )}
        </div>
      </div>

      {showCreate && <BLFormDialog onClose={() => setShowCreate(false)} onSaved={() => setShowCreate(false)} />}
      {printBL && <BLPrintDialog bl={printBL} onClose={() => setPrintBL(null)} />}
      {detailBL && <BLDetailDialog bl={detailBL} onClose={() => setDetailBL(null)} />}
      {deleteBL && <BLDeleteDialog bl={deleteBL} onClose={() => setDeleteBL(null)} onDeleted={() => setDeleteBL(null)} />}
      {editOldBL && <OldBLEditDialog bl={editOldBL} onClose={() => setEditOldBL(null)} onSaved={() => setEditOldBL(null)} />}
    </Dashboard>
  );
}
