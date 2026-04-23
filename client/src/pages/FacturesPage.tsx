import Dashboard from "@/pages/Dashboard";
import { useQuery, useMutation } from "@tanstack/react-query";
import { queryClient, apiRequest } from "@/lib/queryClient";
import type { FactureLine, Client } from "@shared/schema";
import { useState, useRef, useMemo, useEffect } from "react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { Printer, Search, Receipt, X, Plus, Trash2, Pencil, AlertCircle, UserPlus, History, CheckCircle2, Lock } from "lucide-react";
import logoImg from "@assets/LOGOBranding_1771926826080.png";
import { formatNum3, COMPANY, TIMBRE, nombreEnLettres, buildPrintHtml, openPrintWindow } from "@/lib/printUtils";

// ─── Types ─────────────────────────────────────────────────────────────────────
type FactureGroup = {
  factureNumber: string;
  bonRef: string;
  date: string;
  commercial: string;
  client: string;
  idClient: string;
  matriculeFiscal: string;
  adresseClient: string;
  phoneClient: string;
  lines: FactureLine[];
  totalHt: number;
  totalTva: number;
  totalTtc: number;
  netAPayer: number;
};

type DraftLine = {
  id: number;
  ref: string;
  designation: string;
  qte: number;
  prix: number;
  tva: string;
  remise: number;
};

type ClientType = { id: number; nomPrenom: string; uniqueNumber?: string; numeroTelephone?: string; adresse?: string; cin?: string };

type FactureHeader = {
  id: number; factureNumber: string; bonRef: string; date: string; commercial: string;
  clientId?: number | null; clientName: string; idClient: string;
  matriculeFiscal: string; adresseClient: string; phoneClient: string;
  status: "draft" | "validated";
  lineCount?: number; totalHt?: number; totalTva?: number; totalTtc?: number;
};
type FactureWithLines = FactureHeader & { lines: FactureLine[] };

type OldFactureGroup = FactureGroup & { kind: "old" };
type NewFactureItem = FactureHeader & { kind: "new" };
type UnifiedFacture = OldFactureGroup | NewFactureItem;

type CurrentUser = { id: number; username: string; role: string };

// ─── Helpers ───────────────────────────────────────────────────────────────────
function groupByFactureOld(lines: FactureLine[]): OldFactureGroup[] {
  return groupByFacture(lines).map(g => ({ ...g, kind: "old" as const }));
}

function buildGroupFromV2(f: FactureWithLines): FactureGroup {
  const totalHt = f.lines.reduce((s, l) => s + l.montantHt, 0);
  const totalTva = f.lines.reduce((s, l) => s + l.montantTva, 0);
  const totalTtc = f.lines.reduce((s, l) => s + l.montantTtc, 0);
  return {
    factureNumber: f.factureNumber, bonRef: f.bonRef, date: f.date, commercial: f.commercial,
    client: f.clientName, idClient: f.idClient,
    matriculeFiscal: f.matriculeFiscal, adresseClient: f.adresseClient, phoneClient: f.phoneClient,
    lines: f.lines, totalHt, totalTva, totalTtc, netAPayer: totalTtc + TIMBRE,
  };
}

function groupByFacture(lines: FactureLine[]): FactureGroup[] {
  const map = new Map<string, FactureGroup>();
  for (const line of lines) {
    if (!map.has(line.factureNumber)) {
      map.set(line.factureNumber, {
        factureNumber: line.factureNumber,
        bonRef: line.bonRef ?? "",
        date: line.date,
        commercial: line.commercial,
        client: line.client,
        idClient: line.idClient,
        matriculeFiscal: (line as any).matriculeFiscal ?? "",
        adresseClient: (line as any).adresseClient ?? "",
        phoneClient: (line as any).phoneClient ?? "",
        lines: [],
        totalHt: 0,
        totalTva: 0,
        totalTtc: 0,
        netAPayer: 0,
      });
    }
    const g = map.get(line.factureNumber)!;
    g.lines.push(line);
    g.totalHt += line.montantHt;
    g.totalTva += line.montantTva;
    g.totalTtc += line.montantTtc;
  }
  for (const g of map.values()) {
    g.netAPayer = g.totalTtc + TIMBRE;
  }
  return Array.from(map.values()).sort((a, b) => b.factureNumber.localeCompare(a.factureNumber));
}

function calcLine(prix: number, tva: string, remise: number, qte: number) {
  const tvaPct = parseFloat(tva.replace("%", "")) || 0;
  const ht = prix * qte * (1 - remise / 100);
  const tvaAmt = ht * (tvaPct / 100);
  return { ht, tva: tvaAmt, ttc: ht + tvaAmt, prixTtc: prix * (1 + tvaPct / 100) * (1 - remise / 100) };
}

function buildTvaRows(lines: FactureLine[]) {
  const map = new Map<string, { base: number; montant: number }>();
  for (const l of lines) {
    if (!map.has(l.tva)) map.set(l.tva, { base: 0, montant: 0 });
    const e = map.get(l.tva)!;
    e.base += l.montantHt;
    e.montant += l.montantTva;
  }
  return Array.from(map.entries()).map(([tva, v]) => ({ base: v.base, tva, montant: v.montant }));
}

// ─── Print HTML builder ────────────────────────────────────────────────────────
function buildFacturePrintHtml(fac: FactureGroup, logoSrc: string): string {
  const tvaRows = buildTvaRows(fac.lines);

  const productRows = fac.lines.map(line => `
    <tr>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${line.ref}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;">${line.designation.trim()}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${Number(line.qte).toFixed(2)}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:center;">${line.tva.replace('%', '')}</td>
      <td style="border:1px solid #ccc;padding:3px 6px;text-align:right;">${formatNum3(line.prix)}</td>
    </tr>`).join("");

  const blHeaderRow = fac.bonRef
    ? `<tr><td colspan="5" style="border:1px solid #ccc;padding:3px 6px;font-weight:bold;">B.L N° : ${fac.bonRef}&nbsp;&nbsp; du : ${fac.date}</td></tr>`
    : "";

  const tvaTableRows = tvaRows.map(r => `
    <tr>
      <td style="border:1px solid #ccc;padding:2px 6px;text-align:right;">${formatNum3(r.base)}</td>
      <td style="border:1px solid #ccc;padding:2px 6px;text-align:center;">${r.tva}</td>
      <td style="border:1px solid #ccc;padding:2px 6px;text-align:right;">${formatNum3(r.montant)}</td>
    </tr>`).join("");

  const body = `
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:12px;">
      <img src="${logoSrc}" alt="Logo" style="width:70px;height:70px;object-fit:contain;" />
      <div style="text-align:right;font-size:10px;line-height:1.6;">
        <div>${COMPANY.address}</div><div>${COMPANY.phone}</div><div>Matricule Fiscal : ${COMPANY.mf}</div>
      </div>
    </div>
    <div style="text-align:center;font-weight:bold;font-size:13px;border-top:1px solid #000;border-bottom:1px solid #000;padding:4px 0;margin-bottom:12px;">
      Facture N° : <u>${fac.factureNumber}</u>
    </div>
    <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
      <div style="font-size:10px;line-height:1.7;">
        <div><strong>Date :</strong> ${fac.date}</div>
        <div><strong>Bon de commande :</strong></div>
      </div>
      <div style="border:1px solid #aaa;padding:6px 10px;font-size:10px;min-width:280px;">
        <div style="font-weight:bold;text-align:center;border-bottom:1px solid #ccc;padding-bottom:2px;margin-bottom:4px;">Client</div>
        <div><strong>Code :</strong> ${fac.idClient}</div>
        <div><strong>Raison sociale :</strong> ${fac.client}</div>
        ${fac.matriculeFiscal ? `<div><strong>Matricule fiscal :</strong> ${fac.matriculeFiscal}</div>` : ""}
        ${fac.adresseClient ? `<div><strong>Adresse :</strong> ${fac.adresseClient}</div>` : ""}
        ${fac.phoneClient ? `<div><strong>Tél :</strong> ${fac.phoneClient}</div>` : ""}
      </div>
    </div>
    <table style="width:100%;border-collapse:collapse;font-size:10px;margin-bottom:12px;">
      <thead><tr style="background:#f0f0f0;">
        <th style="border:1px solid #888;padding:4px 6px;text-align:center;width:80px;">Référence</th>
        <th style="border:1px solid #888;padding:4px 6px;text-align:center;">Désignation</th>
        <th style="border:1px solid #888;padding:4px 6px;text-align:center;width:65px;">Quantité</th>
        <th style="border:1px solid #888;padding:4px 6px;text-align:center;width:65px;">TVA(%)</th>
        <th style="border:1px solid #888;padding:4px 6px;text-align:center;width:100px;">Prix Unitaire</th>
      </tr></thead>
      <tbody>${blHeaderRow}${productRows}</tbody>
    </table>
    <div style="display:flex;justify-content:space-between;margin-bottom:16px;gap:20px;">
      <table style="border-collapse:collapse;font-size:10px;align-self:flex-start;">
        <thead><tr style="background:#f0f0f0;">
          <th style="border:1px solid #888;padding:3px 8px;text-align:center;width:80px;">Base</th>
          <th style="border:1px solid #888;padding:3px 8px;text-align:center;width:60px;">TVA (%)</th>
          <th style="border:1px solid #888;padding:3px 8px;text-align:center;width:80px;">Montant</th>
        </tr></thead>
        <tbody>${tvaTableRows}</tbody>
      </table>
      <div style="font-size:10px;width:220px;">
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;padding:2px 8px;"><span>Montant HT :</span><strong>${formatNum3(fac.totalHt)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;border-top:none;padding:2px 8px;"><span>Montant TVA :</span><strong>${formatNum3(fac.totalTva)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;border-top:none;padding:2px 8px;"><span>Montant TTC :</span><strong>${formatNum3(fac.totalTtc)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #ccc;border-top:none;padding:2px 8px;"><span>Timbre :</span><strong>${formatNum3(TIMBRE)}</strong></div>
        <div style="display:flex;justify-content:space-between;border:1px solid #555;padding:3px 8px;font-weight:bold;background:#f9f9f9;"><span>Net à payer :</span><span>${formatNum3(fac.netAPayer)}</span></div>
      </div>
    </div>
    <div style="border:1px solid #ccc;padding:6px 10px;font-size:10px;margin-bottom:16px;">
      <strong>Arrêter la présente facture à la somme de :</strong>
      <span style="font-style:italic;margin-left:4px;">${nombreEnLettres(fac.netAPayer)}</span>
    </div>
    <div style="display:flex;justify-content:space-between;margin-top:28px;font-size:10px;">
      <div style="text-align:center;"><div><strong>Signature et Cachet</strong></div><div><strong>${COMPANY.name}</strong></div><div style="margin-top:28px;border-top:1px solid #000;width:130px;"></div></div>
      <div style="text-align:center;"><div><strong>Signature et Cachet</strong></div><div><strong>Client</strong></div><div style="margin-top:28px;border-top:1px solid #000;width:130px;"></div></div>
    </div>
    <div style="display:flex;justify-content:space-between;margin-top:15px;font-size:9px;color:#666;border-top:1px solid #ddd;padding-top:4px;"><span>${fac.date}</span><span>Page : 1</span></div>`;

  return buildPrintHtml(body, `Facture ${fac.factureNumber}`);
}

// ─── Print Preview (on-screen) ─────────────────────────────────────────────────
function FacturePreview({ fac }: { fac: FactureGroup }) {
  const tvaRows = buildTvaRows(fac.lines);
  return (
    <div className="bg-white text-black font-sans text-[10.5px] w-full">
      <div className="flex items-start justify-between mb-3">
        <img src={logoImg} alt="Logo" className="w-20 h-20 object-contain" />
        <div className="text-right text-[10px] leading-5">
          <div>{COMPANY.address}</div><div>{COMPANY.phone}</div><div>Matricule Fiscal : {COMPANY.mf}</div>
        </div>
      </div>
      <div className="text-center font-bold text-[13px] border-b border-t border-black py-1 mb-3">
        Facture N° : <span className="underline">{fac.factureNumber}</span>
      </div>
      <div className="flex justify-between mb-3 gap-4">
        <div className="text-[10px] space-y-0.5">
          <div><span className="font-bold">Date :</span> {fac.date}</div>
          <div><span className="font-bold">Bon de commande :</span></div>
        </div>
        <div className="border border-gray-400 px-3 py-1.5 text-[10px] min-w-[280px]">
          <div className="font-bold text-center border-b border-gray-300 pb-0.5 mb-1">Client</div>
          <div><span className="font-bold">Code :</span> {fac.idClient}</div>
          <div><span className="font-bold">Raison sociale :</span> {fac.client}</div>
          {fac.matriculeFiscal && <div><span className="font-bold">Matricule fiscal :</span> {fac.matriculeFiscal}</div>}
          {fac.adresseClient && <div><span className="font-bold">Adresse :</span> {fac.adresseClient}</div>}
          {fac.phoneClient && <div><span className="font-bold">Tél :</span> {fac.phoneClient}</div>}
        </div>
      </div>
      <table className="w-full border-collapse text-[10px] mb-3">
        <thead>
          <tr>
            <th className="border border-gray-400 px-2 py-1 text-center font-bold w-[80px]">Référence</th>
            <th className="border border-gray-400 px-2 py-1 text-center font-bold">Désignation</th>
            <th className="border border-gray-400 px-2 py-1 text-center font-bold w-[60px]">Quantité</th>
            <th className="border border-gray-400 px-2 py-1 text-center font-bold w-[60px]">TVA(%)</th>
            <th className="border border-gray-400 px-2 py-1 text-center font-bold w-[90px]">Prix Unitaire</th>
          </tr>
        </thead>
        <tbody>
          {fac.bonRef && (
            <tr>
              <td colSpan={5} className="border border-gray-300 px-2 py-1 font-bold text-[10px]">
                B.L N° : {fac.bonRef}&nbsp;&nbsp; du : {fac.date}
              </td>
            </tr>
          )}
          {fac.lines.map(line => (
            <tr key={line.id} className="border border-gray-300">
              <td className="border border-gray-300 px-2 py-1 text-center">{line.ref}</td>
              <td className="border border-gray-300 px-2 py-1">{line.designation.trim()}</td>
              <td className="border border-gray-300 px-2 py-1 text-center">{Number(line.qte).toFixed(2)}</td>
              <td className="border border-gray-300 px-2 py-1 text-center">{line.tva.replace('%', '')}</td>
              <td className="border border-gray-300 px-2 py-1 text-right">{formatNum3(line.prix)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="flex justify-between mb-4 gap-4">
        <table className="border-collapse text-[10px] self-start">
          <thead>
            <tr>
              <th className="border border-gray-400 px-3 py-1 font-bold text-center w-[80px]">Base</th>
              <th className="border border-gray-400 px-3 py-1 font-bold text-center w-[60px]">TVA (%)</th>
              <th className="border border-gray-400 px-3 py-1 font-bold text-center w-[80px]">Montant</th>
            </tr>
          </thead>
          <tbody>
            {tvaRows.map((r, i) => (
              <tr key={i}>
                <td className="border border-gray-300 px-3 py-0.5 text-right">{formatNum3(r.base)}</td>
                <td className="border border-gray-300 px-3 py-0.5 text-center">{r.tva}</td>
                <td className="border border-gray-300 px-3 py-0.5 text-right">{formatNum3(r.montant)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="text-[10px] w-[220px]">
          <div className="flex justify-between border border-gray-300 px-2 py-0.5"><span>Montant HT :</span><span className="font-bold">{formatNum3(fac.totalHt)}</span></div>
          <div className="flex justify-between border-x border-b border-gray-300 px-2 py-0.5"><span>Montant TVA :</span><span className="font-bold">{formatNum3(fac.totalTva)}</span></div>
          <div className="flex justify-between border-x border-b border-gray-300 px-2 py-0.5"><span>Montant TTC :</span><span className="font-bold">{formatNum3(fac.totalTtc)}</span></div>
          <div className="flex justify-between border-x border-b border-gray-300 px-2 py-0.5"><span>Timbre :</span><span className="font-bold">{formatNum3(TIMBRE)}</span></div>
          <div className="flex justify-between border border-gray-600 px-2 py-1 font-black bg-gray-50"><span>Net à payer :</span><span>{formatNum3(fac.netAPayer)}</span></div>
        </div>
      </div>
      <div className="border border-gray-300 px-3 py-1.5 text-[10px] mb-4 italic">
        <span className="font-bold not-italic">Arrêter la présente facture à la somme de :</span>
        <span className="ml-1">{nombreEnLettres(fac.netAPayer)}</span>
      </div>
      <div className="flex justify-between mt-6 text-[10px]">
        <div className="text-center"><div className="font-bold">Signature et Cachet</div><div className="font-bold">{COMPANY.name}</div><div className="mt-8 border-t border-black w-32"></div></div>
        <div className="text-center"><div className="font-bold">Signature et Cachet</div><div className="font-bold">Client</div><div className="mt-8 border-t border-black w-32"></div></div>
      </div>
      <div className="flex justify-between mt-4 text-[9px] text-gray-500 border-t pt-1"><span>{fac.date}</span><span>Page : 1</span></div>
    </div>
  );
}

// ─── Print Dialog ──────────────────────────────────────────────────────────────
function PrintDialog({ fac, onClose }: { fac: FactureGroup; onClose: () => void }) {
  const imgRef = useRef<HTMLImageElement>(null);
  const handlePrint = () => {
    const logoSrc = imgRef.current?.src || logoImg;
    const html = buildFacturePrintHtml(fac, logoSrc);
    openPrintWindow(html);
  };
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <div className="flex items-center justify-between">
            <DialogTitle className="flex items-center gap-2"><Receipt className="w-4 h-4 text-emerald-600" />Facture — {fac.factureNumber}</DialogTitle>
            <Button onClick={handlePrint} size="sm" className="flex items-center gap-2 mr-8 bg-emerald-600 hover:bg-emerald-700" data-testid="btn-print-facture"><Printer className="w-4 h-4" />Imprimer</Button>
          </div>
        </DialogHeader>
        <div className="border rounded p-5 bg-white shadow-inner">
          <img ref={imgRef} src={logoImg} alt="" className="hidden" />
          <FacturePreview fac={fac} />
        </div>
      </DialogContent>
    </Dialog>
  );
}

// ─── Print Dialog (v2) — fetches lines on open like BLPrintDialog ──────────────
function PrintDialogV2({ id, factureNumber, onClose }: { id: number; factureNumber: string; onClose: () => void }) {
  const imgRef = useRef<HTMLImageElement>(null);
  const { data: full, isLoading } = useQuery<FactureWithLines>({ queryKey: ["/api/factures-v2", id] });
  const fac = full ? buildGroupFromV2(full) : null;
  const handlePrint = () => {
    if (!fac) return;
    const logoSrc = imgRef.current?.src || logoImg;
    openPrintWindow(buildFacturePrintHtml(fac, logoSrc));
  };
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <div className="flex items-center justify-between">
            <DialogTitle className="flex items-center gap-2"><Receipt className="w-4 h-4 text-emerald-600" />Facture — {factureNumber}</DialogTitle>
            <Button onClick={handlePrint} disabled={!fac} size="sm" className="flex items-center gap-2 mr-8 bg-emerald-600 hover:bg-emerald-700" data-testid="btn-print-facture"><Printer className="w-4 h-4" />Imprimer</Button>
          </div>
        </DialogHeader>
        <div className="border rounded p-5 bg-white shadow-inner">
          <img ref={imgRef} src={logoImg} alt="" className="hidden" />
          {isLoading || !fac ? <p className="text-gray-400 text-center py-8">Chargement...</p> : <FacturePreview fac={fac} />}
        </div>
      </DialogContent>
    </Dialog>
  );
}

// ─── Delete Dialog ─────────────────────────────────────────────────────────────
function DeleteDialog({ fac, onClose, onDeleted }: { fac: FactureGroup; onClose: () => void; onDeleted: () => void }) {
  const { toast } = useToast();
  const deleteMut = useMutation({
    mutationFn: () => apiRequest("DELETE", `/api/factures/${encodeURIComponent(fac.factureNumber)}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/factures"] });
      queryClient.invalidateQueries({ queryKey: ["/api/livraisons"] });
      queryClient.invalidateQueries({ queryKey: ["/api/bons-livraison"] });
      toast({ title: "Facture supprimée", description: `Facture ${fac.factureNumber} supprimée.` });
      onDeleted();
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-sm">
        <DialogHeader><DialogTitle className="flex items-center gap-2 text-destructive"><AlertCircle className="w-5 h-5" />Supprimer la facture</DialogTitle></DialogHeader>
        <p className="text-sm text-muted-foreground">Voulez-vous vraiment supprimer la <strong>Facture {fac.factureNumber}</strong> ({fac.client}) ? Cette action est irréversible.</p>
        <DialogFooter className="gap-2 sm:gap-0">
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button variant="destructive" onClick={() => deleteMut.mutate()} disabled={deleteMut.isPending} data-testid="btn-confirm-delete-facture">
            {deleteMut.isPending ? "Suppression..." : "Supprimer"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── New Client Dialog ─────────────────────────────────────────────────────────
function NewClientDialog({ onCreated, onClose }: { onCreated: (c: ClientType) => void; onClose: () => void }) {
  const { toast } = useToast();
  const [nomPrenom, setNomPrenom] = useState("");
  const [telephone, setTelephone] = useState("");
  const [adresse, setAdresse] = useState("");
  const [cin, setCin] = useState("");
  const createMut = useMutation({
    mutationFn: async () => {
      const res = await apiRequest("POST", "/api/clients", { nomPrenom, numeroTelephone: telephone, adresse, cin });
      return res.json();
    },
    onSuccess: (client: ClientType) => {
      queryClient.invalidateQueries({ queryKey: ["/api/clients"] });
      toast({ title: "Client créé", description: client.nomPrenom });
      onCreated(client);
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-sm">
        <DialogHeader><DialogTitle className="flex items-center gap-2"><UserPlus className="w-4 h-4 text-emerald-600" />Nouveau client</DialogTitle></DialogHeader>
        <div className="flex flex-col gap-3">
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Nom / Prénom *</label><Input value={nomPrenom} onChange={e => setNomPrenom(e.target.value)} placeholder="Nom complet" data-testid="input-new-client-nom-facture" /></div>
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Téléphone</label><Input value={telephone} onChange={e => setTelephone(e.target.value)} placeholder="(+216) ..." data-testid="input-new-client-tel-facture" /></div>
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Adresse</label><Input value={adresse} onChange={e => setAdresse(e.target.value)} placeholder="Adresse" data-testid="input-new-client-adresse-facture" /></div>
          <div><label className="text-xs font-semibold text-gray-600 mb-1 block">CIN / Matricule fiscal</label><Input value={cin} onChange={e => setCin(e.target.value)} placeholder="CIN ou MF" data-testid="input-new-client-cin-facture" /></div>
        </div>
        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button onClick={() => createMut.mutate()} disabled={!nomPrenom.trim() || createMut.isPending} className="bg-emerald-600 hover:bg-emerald-700" data-testid="btn-save-new-client-facture">
            {createMut.isPending ? "Création..." : "Créer le client"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Facture Form (create & edit) ─────────────────────────────────────────────
// editFac: { kind: "old" } → legacy historique edit (manager-only on backend)
//          { kind: "new", id } → v2 draft edit
//          null → create new (v2 draft)
function FactureForm({ editFac, editV2Id, onClose, onSaved }: { editFac: FactureGroup | null; editV2Id: number | null; onClose: () => void; onSaved: () => void }) {
  const { toast } = useToast();
  const isEdit = !!editFac;
  const isV2Edit = isEdit && editV2Id !== null;
  const isOldEdit = isEdit && editV2Id === null;
  const today = new Date().toLocaleDateString("fr-TN", { day: "2-digit", month: "2-digit", year: "numeric" });

  const [date, setDate] = useState(editFac?.date ?? today);
  const [commercial, setCommercial] = useState(editFac?.commercial ?? "HADJ SALEM Karim");
  const [bonRef, setBonRef] = useState(editFac?.bonRef ?? "");
  const [clientName, setClientName] = useState(editFac?.client ?? "");
  const [idClient, setIdClient] = useState(editFac?.idClient ?? "");
  const [matriculeFiscal, setMatriculeFiscal] = useState(editFac?.matriculeFiscal ?? "");
  const [adresseClient, setAdresseClient] = useState(editFac?.adresseClient ?? "");
  const [phoneClient, setPhoneClient] = useState(editFac?.phoneClient ?? "");
  const [clientSearch, setClientSearch] = useState("");
  const [showClientDropdown, setShowClientDropdown] = useState(false);
  const [showNewClient, setShowNewClient] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const [draftLines, setDraftLines] = useState<DraftLine[]>(() =>
    editFac ? editFac.lines.map((l, i) => ({
      id: i + 1, ref: l.ref, designation: l.designation,
      qte: l.qte, prix: l.prix, tva: l.tva, remise: l.remise,
    })) : [{ id: 1, ref: "", designation: "", qte: 1, prix: 0, tva: "19%", remise: 0 }]
  );

  const { data: nextNumberData } = useQuery<{ factureNumber: string }>({
    queryKey: ["/api/factures/next-number"],
    enabled: !isEdit,
  });
  const { data: clients = [] } = useQuery<Client[]>({ queryKey: ["/api/clients"] });

  const factureNumber = isEdit ? editFac!.factureNumber : (nextNumberData?.factureNumber ?? "");

  const filteredClients = useMemo(() => {
    if (!clientSearch.trim()) return [];
    const q = clientSearch.toLowerCase();
    return (clients as Client[]).filter(c =>
      (c.nomPrenom ?? "").toLowerCase().includes(q) ||
      (c.uniqueNumber ?? "").toLowerCase().includes(q)
    ).slice(0, 8);
  }, [clients, clientSearch]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setShowClientDropdown(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const selectClient = (c: Client) => {
    setClientName(c.nomPrenom);
    setIdClient(c.uniqueNumber ?? "");
    setMatriculeFiscal((c as any).cin ?? "");
    setAdresseClient((c as any).adresse ?? "");
    setPhoneClient(c.numeroTelephone ?? "");
    setClientSearch("");
    setShowClientDropdown(false);
  };

  const selectNewClient = (c: ClientType) => {
    setClientName(c.nomPrenom);
    setIdClient(c.uniqueNumber ?? "");
    setMatriculeFiscal(c.cin ?? "");
    setAdresseClient(c.adresse ?? "");
    setPhoneClient(c.numeroTelephone ?? "");
    setClientSearch("");
    setShowClientDropdown(false);
    setShowNewClient(false);
  };

  const clearClient = () => {
    setClientName(""); setIdClient(""); setMatriculeFiscal(""); setAdresseClient(""); setPhoneClient(""); setClientSearch("");
  };

  const addLine = () => setDraftLines(prev => [...prev, { id: Date.now(), ref: "", designation: "", qte: 1, prix: 0, tva: "19%", remise: 0 }]);
  const removeLine = (id: number) => setDraftLines(prev => prev.filter(l => l.id !== id));
  const updateLine = (id: number, field: keyof DraftLine, value: any) => setDraftLines(prev => prev.map(l => l.id !== id ? l : { ...l, [field]: value }));

  const buildLines = () => draftLines.filter(l => l.designation.trim()).map(l => {
    const calc = calcLine(l.prix, l.tva, l.remise, l.qte);
    return {
      factureNumber, bonRef: bonRef.trim(), date, commercial,
      client: clientName, idClient, matriculeFiscal, adresseClient, phoneClient,
      ref: l.ref, designation: l.designation, qte: l.qte, prix: l.prix, tva: l.tva, remise: l.remise,
      prixTtc: calc.prixTtc, montantHt: calc.ht, montantTva: calc.tva, montantTtc: calc.ttc,
    };
  });

  const saveMut = useMutation({
    mutationFn: async () => {
      const lines = buildLines();
      if (lines.length === 0) throw new Error("Ajoutez au moins une ligne avec une désignation.");
      if (!clientName.trim()) throw new Error("Saisissez le nom du client.");

      if (isOldEdit) {
        // Legacy historique edit (manager-only enforced by backend)
        await apiRequest("PUT", `/api/factures/${encodeURIComponent(factureNumber)}`, { lines });
      } else if (isV2Edit && editV2Id) {
        // V2 draft edit
        await apiRequest("PUT", `/api/factures-v2/${editV2Id}`, {
          header: { factureNumber, bonRef, date, commercial, clientName, idClient, matriculeFiscal, adresseClient, phoneClient },
          lines,
        });
      } else {
        // Create new V2 draft
        const res = await apiRequest("POST", "/api/factures-v2", {
          factureNumber, bonRef, date, commercial, clientName, idClient, matriculeFiscal, adresseClient, phoneClient,
        });
        const fac = await res.json();
        for (const line of lines) {
          await apiRequest("POST", `/api/factures-v2/${fac.id}/lines`, line);
        }
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/factures"] });
      queryClient.invalidateQueries({ queryKey: ["/api/factures-v2"] });
      queryClient.invalidateQueries({ queryKey: ["/api/factures/next-number"] });
      queryClient.invalidateQueries({ queryKey: ["/api/livraisons"] });
      queryClient.invalidateQueries({ queryKey: ["/api/bons-livraison"] });
      toast({ title: isEdit ? "Facture modifiée" : "Facture créée", description: `Facture ${factureNumber} enregistrée.` });
      onSaved();
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  const totals = draftLines.reduce((acc, l) => {
    const c = calcLine(l.prix, l.tva, l.remise, l.qte);
    return { ht: acc.ht + c.ht, tva: acc.tva + c.tva, ttc: acc.ttc + c.ttc };
  }, { ht: 0, tva: 0, ttc: 0 });

  const netAPayer = totals.ttc + TIMBRE;

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{isEdit ? `Modifier Facture ${factureNumber}` : "Nouvelle Facture"}</DialogTitle>
        </DialogHeader>

        <div className="flex flex-col gap-4">
          <Card>
            <CardHeader className="pb-2"><CardTitle className="text-sm font-bold uppercase text-gray-500">En-tête</CardTitle></CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">N° Facture</label><Input value={factureNumber} readOnly className="bg-gray-50 font-mono font-bold" /></div>
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Date</label><Input value={date} onChange={e => setDate(e.target.value)} data-testid="input-facture-date" /></div>
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">Commercial</label><Input value={commercial} onChange={e => setCommercial(e.target.value)} data-testid="input-facture-commercial" /></div>
                <div><label className="text-xs font-semibold text-gray-600 mb-1 block">N° BL référence</label><Input value={bonRef} onChange={e => setBonRef(e.target.value)} placeholder="ex: 26/000041" data-testid="input-facture-bonref" /></div>
              </div>

              <div className="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="text-xs font-semibold text-gray-600">Client *</label>
                    <button
                      type="button"
                      onClick={() => setShowNewClient(true)}
                      className="text-xs text-emerald-700 hover:text-emerald-900 flex items-center gap-1 font-medium"
                      data-testid="btn-new-client-facture-inline"
                    >
                      <UserPlus className="w-3 h-3" />Nouveau client
                    </button>
                  </div>
                  {clientName ? (
                    <div className="flex items-center gap-2 px-3 py-2 border rounded-lg border-emerald-300/50 bg-emerald-50/30">
                      <span className="flex-1 text-sm font-semibold">{clientName}</span>
                      <button onClick={clearClient} className="text-muted-foreground hover:text-foreground" data-testid="btn-clear-facture-client"><X className="w-3.5 h-3.5" /></button>
                    </div>
                  ) : (
                    <div className="relative" ref={dropdownRef}>
                      <Input
                        value={clientSearch}
                        onChange={e => { setClientSearch(e.target.value); setShowClientDropdown(true); }}
                        onFocus={() => clientSearch && setShowClientDropdown(true)}
                        placeholder="Taper pour rechercher un client..."
                        data-testid="input-facture-client"
                      />
                      {showClientDropdown && filteredClients.length > 0 && (
                        <div className="absolute top-full left-0 right-0 z-50 bg-white border rounded-lg shadow-lg max-h-48 overflow-y-auto mt-1">
                          {filteredClients.map((c: Client) => (
                            <button key={c.id} onMouseDown={() => selectClient(c)} className="w-full text-left px-3 py-2 text-sm hover:bg-emerald-50/40 flex justify-between items-center gap-2" data-testid={`btn-select-facture-client-${c.id}`}>
                              <span className="font-semibold">{c.nomPrenom}</span>
                              <span className="text-gray-400 text-xs font-mono">{c.uniqueNumber}</span>
                            </button>
                          ))}
                        </div>
                      )}
                      {showClientDropdown && clientSearch && filteredClients.length === 0 && (
                        <div className="absolute top-full left-0 right-0 z-50 bg-white border rounded-lg shadow-lg mt-1">
                          <p className="px-3 py-2 text-sm text-gray-400">Aucun client trouvé. Créez-en un nouveau.</p>
                        </div>
                      )}
                    </div>
                  )}
                </div>
                <div>
                  <label className="text-xs font-semibold text-gray-600 mb-1 block">Code client</label>
                  <Input value={idClient} onChange={e => setIdClient(e.target.value)} placeholder="411100xxx" data-testid="input-facture-idclient" />
                </div>
              </div>
              <div className="mt-2 grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="text-xs font-semibold text-gray-600 mb-1 block">Matricule fiscal client</label>
                  <Input value={matriculeFiscal} onChange={e => setMatriculeFiscal(e.target.value)} placeholder="Matricule fiscal" data-testid="input-facture-mf" />
                </div>
                <div>
                  <label className="text-xs font-semibold text-gray-600 mb-1 block">Adresse client</label>
                  <Input value={adresseClient} onChange={e => setAdresseClient(e.target.value)} placeholder="Adresse" data-testid="input-facture-adresse" />
                </div>
                <div>
                  <label className="text-xs font-semibold text-gray-600 mb-1 block">Téléphone client</label>
                  <Input value={phoneClient} onChange={e => setPhoneClient(e.target.value)} placeholder="(+216) ..." data-testid="input-facture-phone" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-2 flex-row items-center justify-between">
              <CardTitle className="text-sm font-bold uppercase text-gray-500">Lignes</CardTitle>
              <Button size="sm" variant="outline" onClick={addLine} className="gap-1" data-testid="btn-add-facture-line"><Plus className="w-3.5 h-3.5" />Ajouter</Button>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="border-b">
                    <tr>
                      {["Réf.", "Désignation", "Qté", "Prix HT", "TVA", "Remise%", "TTC", ""].map(h => (
                        <th key={h} className="px-2 py-1.5 text-left text-xs font-bold text-gray-500">{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {draftLines.map(l => {
                      const calc = calcLine(l.prix, l.tva, l.remise, l.qte);
                      return (
                        <tr key={l.id} className="border-b last:border-0" data-testid={`row-draft-facture-line-${l.id}`}>
                          <td className="px-1 py-1"><Input value={l.ref} onChange={e => updateLine(l.id, "ref", e.target.value)} className="h-7 w-20 text-xs" placeholder="REF" /></td>
                          <td className="px-1 py-1"><Input value={l.designation} onChange={e => updateLine(l.id, "designation", e.target.value)} className="h-7 w-44 text-xs" placeholder="Désignation" /></td>
                          <td className="px-1 py-1"><Input type="number" value={l.qte} onChange={e => updateLine(l.id, "qte", Number(e.target.value))} className="h-7 w-14 text-xs text-center" /></td>
                          <td className="px-1 py-1"><Input type="number" step="0.001" value={l.prix} onChange={e => updateLine(l.id, "prix", Number(e.target.value))} className="h-7 w-24 text-xs" /></td>
                          <td className="px-1 py-1">
                            <Select value={l.tva} onValueChange={v => updateLine(l.id, "tva", v)}>
                              <SelectTrigger className="h-7 w-18 text-xs"><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="19%">19%</SelectItem>
                                <SelectItem value="7%">7%</SelectItem>
                                <SelectItem value="0%">0%</SelectItem>
                              </SelectContent>
                            </Select>
                          </td>
                          <td className="px-1 py-1"><Input type="number" value={l.remise} onChange={e => updateLine(l.id, "remise", Number(e.target.value))} className="h-7 w-14 text-xs text-center" /></td>
                          <td className="px-1 py-1 font-mono text-xs font-bold text-right whitespace-nowrap">{formatNum3(calc.ttc)}</td>
                          <td className="px-1 py-1">
                            <Button variant="ghost" size="icon" className="h-6 w-6 text-destructive" onClick={() => removeLine(l.id)} disabled={draftLines.length === 1}><Trash2 className="w-3 h-3" /></Button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
              <div className="flex justify-end mt-3">
                <div className="text-xs bg-gray-50 border rounded p-3 flex gap-4 flex-wrap">
                  <div><span className="text-gray-400 uppercase font-bold">HT</span><p className="font-mono font-bold">{formatNum3(totals.ht)}</p></div>
                  <div><span className="text-gray-400 uppercase font-bold">TVA</span><p className="font-mono font-bold">{formatNum3(totals.tva)}</p></div>
                  <div><span className="text-gray-400 uppercase font-bold">TTC</span><p className="font-mono font-bold">{formatNum3(totals.ttc)}</p></div>
                  <div><span className="text-gray-400 uppercase font-bold">Timbre</span><p className="font-mono font-bold">{formatNum3(TIMBRE)}</p></div>
                  <div><span className="text-gray-400 uppercase font-bold text-emerald-700">Net à payer</span><p className="font-mono font-black text-emerald-700">{formatNum3(netAPayer)}</p></div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <DialogFooter className="gap-2">
          {!clientName && <p className="text-sm text-amber-600 flex items-center gap-1 mr-auto"><AlertCircle className="w-4 h-4" />Saisir le client avant d'enregistrer.</p>}
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button onClick={() => saveMut.mutate()} disabled={saveMut.isPending} className="bg-emerald-600 hover:bg-emerald-700" data-testid="btn-save-facture">
            {saveMut.isPending ? "Enregistrement..." : isEdit ? "Enregistrer les modifications" : "Créer la facture"}
          </Button>
        </DialogFooter>
      </DialogContent>

      {showNewClient && (
        <NewClientDialog
          onCreated={selectNewClient}
          onClose={() => setShowNewClient(false)}
        />
      )}
    </Dialog>
  );
}

// ─── V2 Detail / Validate Dialog ───────────────────────────────────────────────
function FactureV2DetailDialog({ id, onClose, onEdit, onPrint, onValidated }: {
  id: number; onClose: () => void; onEdit: () => void;
  onPrint: (g: FactureGroup) => void; onValidated: () => void;
}) {
  const { toast } = useToast();
  const { data: fac, isLoading } = useQuery<FactureWithLines>({ queryKey: ["/api/factures-v2", id] });

  const validateMut = useMutation({
    mutationFn: async () => apiRequest("POST", `/api/factures-v2/${id}/validate`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/factures-v2"] });
      queryClient.invalidateQueries({ queryKey: ["/api/factures-v2", id] });
      queryClient.invalidateQueries({ queryKey: ["/api/livraisons"] });
      queryClient.invalidateQueries({ queryKey: ["/api/bons-livraison"] });
      toast({ title: "Facture validée", description: "Le BL référencé a été marqué comme facturé." });
      onValidated();
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });

  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            Facture {fac?.factureNumber ?? "..."}
            {fac && (fac.status === "draft"
              ? <Badge variant="secondary" className="bg-amber-100 text-amber-800 text-[10px]">Brouillon</Badge>
              : <Badge variant="secondary" className="bg-green-100 text-green-800 text-[10px]">✓ Validée</Badge>)}
          </DialogTitle>
        </DialogHeader>
        {isLoading || !fac ? (
          <div className="py-10 text-center text-muted-foreground text-sm">Chargement...</div>
        ) : (
          <>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div><span className="text-xs text-muted-foreground">Date</span><p className="font-semibold">{fac.date}</p></div>
              <div><span className="text-xs text-muted-foreground">N° BL référence</span><p className="font-mono font-semibold text-indigo-700">{fac.bonRef || "—"}</p></div>
              <div><span className="text-xs text-muted-foreground">Client</span><p className="font-semibold">{fac.clientName}</p></div>
              <div><span className="text-xs text-muted-foreground">Code client</span><p className="font-mono text-xs">{fac.idClient || "—"}</p></div>
              <div><span className="text-xs text-muted-foreground">Commercial</span><p>{fac.commercial}</p></div>
              <div><span className="text-xs text-muted-foreground">Téléphone</span><p>{fac.phoneClient || "—"}</p></div>
            </div>
            <div className="mt-4 border rounded overflow-x-auto">
              <table className="w-full text-xs">
                <thead className="bg-muted/40">
                  <tr>{["Réf.", "Désignation", "Qté", "PU HT", "TVA", "Rem%", "TTC"].map(h => <th key={h} className="px-2 py-1.5 text-left font-semibold">{h}</th>)}</tr>
                </thead>
                <tbody>
                  {fac.lines.map(l => (
                    <tr key={l.id} className="border-t">
                      <td className="px-2 py-1 font-mono">{l.ref}</td>
                      <td className="px-2 py-1">{l.designation}</td>
                      <td className="px-2 py-1 text-center">{l.qte}</td>
                      <td className="px-2 py-1 font-mono text-right">{formatNum3(l.prix)}</td>
                      <td className="px-2 py-1 text-center">{l.tva}</td>
                      <td className="px-2 py-1 text-center">{l.remise}</td>
                      <td className="px-2 py-1 font-mono font-bold text-right">{formatNum3(l.montantTtc)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose}>Fermer</Button>
          {fac && (
            <Button variant="outline" className="gap-1" onClick={() => onPrint(buildGroupFromV2(fac))} data-testid="btn-print-v2-detail">
              <Printer className="w-4 h-4" />Imprimer
            </Button>
          )}
          {fac && fac.status === "draft" && (
            <>
              <Button variant="outline" className="gap-1" onClick={onEdit} data-testid="btn-edit-v2-detail">
                <Pencil className="w-4 h-4" />Modifier
              </Button>
              <Button onClick={() => validateMut.mutate()} disabled={validateMut.isPending} className="bg-emerald-600 hover:bg-emerald-700 gap-1" data-testid="btn-validate-facture-v2">
                <CheckCircle2 className="w-4 h-4" />{validateMut.isPending ? "Validation..." : "Valider la facture"}
              </Button>
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── V2 Delete dialog ──────────────────────────────────────────────────────────
function DeleteV2Dialog({ id, factureNumber, onClose, onDeleted }: { id: number; factureNumber: string; onClose: () => void; onDeleted: () => void }) {
  const { toast } = useToast();
  const m = useMutation({
    mutationFn: async () => apiRequest("DELETE", `/api/factures-v2/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/factures-v2"] });
      toast({ title: "Facture supprimée" });
      onDeleted();
    },
    onError: (e: any) => toast({ title: "Erreur", description: e.message, variant: "destructive" }),
  });
  return (
    <Dialog open onOpenChange={onClose}>
      <DialogContent className="max-w-md">
        <DialogHeader><DialogTitle>Supprimer la facture {factureNumber} ?</DialogTitle></DialogHeader>
        <p className="text-sm text-muted-foreground">Cette action est irréversible.</p>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Annuler</Button>
          <Button variant="destructive" onClick={() => m.mutate()} disabled={m.isPending}>{m.isPending ? "Suppression..." : "Supprimer"}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Main Page ─────────────────────────────────────────────────────────────────
export default function FacturesPage() {
  const { toast } = useToast();
  const [search, setSearch] = useState("");
  const [selectedFac, setSelectedFac] = useState<FactureGroup | null>(null);
  const [editFac, setEditFac] = useState<FactureGroup | null>(null);
  const [editV2Id, setEditV2Id] = useState<number | null>(null);
  const [deleteFac, setDeleteFac] = useState<FactureGroup | null>(null);
  const [deleteV2, setDeleteV2] = useState<{ id: number; factureNumber: string } | null>(null);
  const [detailV2Id, setDetailV2Id] = useState<number | null>(null);
  const [printV2, setPrintV2] = useState<{ id: number; factureNumber: string } | null>(null);
  const [showCreate, setShowCreate] = useState(false);

  const { data: user } = useQuery<CurrentUser>({ queryKey: ["/api/user"] });
  const isManager = user?.role === "manager";

  const { data: oldLines = [], isLoading: oldLoading } = useQuery<FactureLine[]>({ queryKey: ["/api/factures"] });
  const { data: v2List = [], isLoading: v2Loading } = useQuery<FactureHeader[]>({ queryKey: ["/api/factures-v2"] });

  const isLoading = oldLoading || v2Loading;

  const oldGroups = useMemo(() => groupByFactureOld(oldLines), [oldLines]);
  const newItems = useMemo<NewFactureItem[]>(() => v2List.map(f => ({ ...f, kind: "new" as const })), [v2List]);

  // Compute a net total per row for V2 (need totals — we'll fetch lines lazily via query? simpler: fetch v2 with lines via separate aggregate)
  // For listing display we don't have lines, so show "—" until detail is opened.
  const all: UnifiedFacture[] = useMemo(() => [...newItems, ...oldGroups], [newItems, oldGroups]);

  const filtered = useMemo(() => {
    const q = search.toLowerCase().trim();
    if (!q) return all;
    return all.filter(g => {
      const fNum = g.factureNumber.toLowerCase();
      const cli = (g.kind === "old" ? g.client : g.clientName).toLowerCase();
      const bon = g.bonRef.toLowerCase();
      const dt = g.date.toLowerCase();
      return fNum.includes(q) || cli.includes(q) || bon.includes(q) || dt.includes(q);
    });
  }, [all, search]);

  const filteredTotal = filtered.reduce((s, g) => s + (g.kind === "old" ? g.netAPayer : ((g.totalTtc ?? 0) + TIMBRE)), 0);
  const allTotal = all.reduce((s, g) => s + (g.kind === "old" ? g.netAPayer : ((g.totalTtc ?? 0) + TIMBRE)), 0);

  const handleEdit = (fac: UnifiedFacture) => {
    if (fac.kind === "old") {
      if (!isManager) {
        toast({ title: "Action réservée au gérant", description: "Seul le gérant peut modifier les factures historiques.", variant: "destructive" });
        return;
      }
      setEditFac(fac);
      setEditV2Id(null);
    } else {
      if (fac.status === "validated" && !isManager) {
        toast({ title: "Facture validée", description: "Modification réservée au gérant.", variant: "destructive" });
        return;
      }
      setEditFac(buildGroupFromV2({ ...fac, lines: [] } as any));
      setEditV2Id(fac.id);
      // Load lines then patch group
      apiRequest("GET", `/api/factures-v2/${fac.id}`).then(r => r.json()).then((full: FactureWithLines) => {
        setEditFac(buildGroupFromV2(full));
      });
    }
  };

  const handleDelete = (fac: UnifiedFacture) => {
    if (fac.kind === "old") {
      if (!isManager) {
        toast({ title: "Action réservée au gérant", description: "Seul le gérant peut supprimer les factures historiques.", variant: "destructive" });
        return;
      }
      setDeleteFac(fac);
    } else {
      if (fac.status === "validated" && !isManager) {
        toast({ title: "Facture validée", description: "Suppression réservée au gérant.", variant: "destructive" });
        return;
      }
      setDeleteV2({ id: fac.id, factureNumber: fac.factureNumber });
    }
  };

  const handleRowClick = (fac: UnifiedFacture) => {
    if (fac.kind === "old") setSelectedFac(fac);
    else setDetailV2Id(fac.id);
  };

  const handlePrint = (fac: UnifiedFacture) => {
    if (fac.kind === "old") setSelectedFac(fac);
    else setPrintV2({ id: fac.id, factureNumber: fac.factureNumber });
  };

  return (
    <Dashboard contentOnly>
      <div className="flex flex-col gap-4 h-full">

        {/* Page header */}
        <div className="flex items-center gap-3">
          <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-100 shrink-0">
            <Receipt className="w-5 h-5 text-emerald-600" />
          </div>
          <div className="min-w-0">
            <h2 className="text-lg font-black tracking-tight leading-none">Factures</h2>
            <p className="text-xs text-muted-foreground mt-0.5">
              {all.length} facture{all.length !== 1 ? "s" : ""} &nbsp;·&nbsp; Total historique : <span className="font-semibold text-foreground">{formatNum3(allTotal)} TND</span>
            </p>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <div className="relative w-64">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
              <Input
                data-testid="input-search-facture"
                className="pl-9 h-9 text-sm"
                placeholder="N° facture, client, BL, date..."
                value={search}
                onChange={e => setSearch(e.target.value)}
              />
              {search && (
                <button onClick={() => setSearch("")} className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground">
                  <X className="w-4 h-4" />
                </button>
              )}
            </div>
            <Button onClick={() => setShowCreate(true)} className="h-9 gap-1.5 shrink-0 bg-emerald-600 hover:bg-emerald-700" data-testid="btn-new-facture">
              <Plus className="w-4 h-4" />Nouvelle Facture
            </Button>
          </div>
        </div>

        {/* Table card */}
        <div className="rounded-xl border bg-card shadow-sm overflow-hidden flex-1 flex flex-col min-h-0">
          {isLoading ? (
            <div className="flex items-center justify-center flex-1 text-muted-foreground gap-2">
              <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin" />
              Chargement...
            </div>
          ) : filtered.length === 0 ? (
            <div className="flex flex-col items-center justify-center flex-1 gap-3 text-muted-foreground py-16">
              <div className="w-14 h-14 rounded-2xl bg-muted/50 flex items-center justify-center">
                <Receipt className="w-7 h-7 opacity-40" />
              </div>
              <div className="text-center">
                <p className="font-semibold text-sm">Aucune facture trouvée</p>
                {search && <p className="text-xs mt-1">Essayez d'autres termes de recherche</p>}
              </div>
            </div>
          ) : (
            <>
              <div className="overflow-x-auto overflow-y-auto flex-1">
                <table className="w-full text-sm min-w-[720px]">
                  <thead className="sticky top-0 z-10">
                    <tr className="bg-muted/60 backdrop-blur border-b border-border">
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">N° Facture</th>
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Date</th>
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider">Client</th>
                      <th className="text-left px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">N° BL</th>
                      <th className="text-center px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Statut</th>
                      <th className="text-center px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Lignes</th>
                      <th className="text-right px-4 py-2.5 font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Net à payer</th>
                      <th className="px-3 py-2.5 text-right font-semibold text-muted-foreground text-[11px] uppercase tracking-wider whitespace-nowrap">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/40">
                    {filtered.map((fac) => {
                      const cli = fac.kind === "old" ? fac.client : fac.clientName;
                      const lockEdit = fac.kind === "old"
                        ? !isManager
                        : (fac.status === "validated" && !isManager);
                      const lockDelete = lockEdit;
                      const statusBadge = fac.kind === "old"
                        ? <Badge variant="secondary" className="bg-slate-100 text-slate-700 hover:bg-slate-100 text-[10px] gap-1"><History className="w-3 h-3" />Historique</Badge>
                        : fac.status === "draft"
                          ? <Badge variant="secondary" className="bg-amber-100 text-amber-800 hover:bg-amber-100 text-[10px]">Brouillon</Badge>
                          : <Badge variant="secondary" className="bg-green-100 text-green-800 hover:bg-green-100 text-[10px]">✓ Validée</Badge>;
                      return (
                        <tr
                          key={`${fac.kind}-${fac.kind === "new" ? fac.id : fac.factureNumber}`}
                          data-testid={`row-facture-${fac.factureNumber}`}
                          className="hover:bg-emerald-50/40 dark:hover:bg-emerald-950/20 transition-colors group cursor-pointer"
                          onClick={() => handleRowClick(fac)}
                        >
                          <td className="px-4 py-3">
                            <span className="font-mono font-bold text-emerald-700 text-xs tracking-wide">{fac.factureNumber}</span>
                          </td>
                          <td className="px-4 py-3 text-muted-foreground text-xs whitespace-nowrap">{fac.date}</td>
                          <td className="px-4 py-3 max-w-[200px]">
                            <span className="font-medium text-sm truncate block">{cli}</span>
                            {fac.idClient && <span className="text-[10px] text-muted-foreground font-mono">{fac.idClient}</span>}
                          </td>
                          <td className="px-4 py-3 text-xs font-mono">
                            {fac.bonRef
                              ? <span className="text-indigo-700 font-semibold">{fac.bonRef}</span>
                              : <span className="text-muted-foreground/50">—</span>}
                          </td>
                          <td className="px-4 py-3 text-center">{statusBadge}</td>
                          <td className="px-4 py-3 text-center">
                            {fac.kind === "old"
                              ? <Badge variant="secondary" className="text-[11px] px-2">{fac.lines.length}</Badge>
                              : <Badge variant="secondary" className="text-[11px] px-2">{fac.lineCount ?? 0}</Badge>}
                          </td>
                          <td className="px-4 py-3 text-right">
                            {fac.kind === "old" ? (
                              <>
                                <span className="font-bold tabular-nums text-sm">{formatNum3(fac.netAPayer)}</span>
                                <span className="text-muted-foreground text-xs ml-1">TND</span>
                              </>
                            ) : (
                              <>
                                <span className="font-bold tabular-nums text-sm">{formatNum3((fac.totalTtc ?? 0) + TIMBRE)}</span>
                                <span className="text-muted-foreground text-xs ml-1">TND</span>
                              </>
                            )}
                          </td>
                          <td className="px-3 py-3" onClick={e => e.stopPropagation()}>
                            <div className="flex gap-0.5 justify-end items-center opacity-60 group-hover:opacity-100 transition-opacity">
                              <Button variant="ghost" size="sm" className="h-7 w-7 p-0 text-muted-foreground hover:text-foreground hover:bg-muted" onClick={() => handlePrint(fac)} title="Aperçu & Imprimer" data-testid={`btn-print-facture-${fac.factureNumber}`}>
                                <Printer className="w-3.5 h-3.5" />
                              </Button>
                              {isManager && (
                                <>
                                  <Button
                                    variant="ghost" size="sm"
                                    className="h-7 w-7 p-0 text-blue-500 hover:text-blue-700 hover:bg-blue-50"
                                    onClick={() => handleEdit(fac)}
                                    title="Modifier"
                                    data-testid={`btn-edit-facture-${fac.factureNumber}`}
                                  >
                                    <Pencil className="w-3.5 h-3.5" />
                                  </Button>
                                  <Button
                                    variant="ghost" size="sm"
                                    className="h-7 w-7 p-0 text-rose-400 hover:text-rose-600 hover:bg-rose-50"
                                    onClick={() => handleDelete(fac)}
                                    title="Supprimer"
                                    data-testid={`btn-delete-facture-${fac.factureNumber}`}
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
                  {search ? `${filtered.length} résultat${filtered.length !== 1 ? "s" : ""} sur ${all.length}` : `${all.length} facture${all.length !== 1 ? "s" : ""}`}
                </span>
                <span className="text-xs font-bold">
                  Total historique affiché : <span className="text-emerald-700 tabular-nums">{formatNum3(filteredTotal)} TND</span>
                </span>
              </div>
            </>
          )}
        </div>
      </div>

      {selectedFac && <PrintDialog fac={selectedFac} onClose={() => setSelectedFac(null)} />}
      {printV2 && <PrintDialogV2 id={printV2.id} factureNumber={printV2.factureNumber} onClose={() => setPrintV2(null)} />}
      {detailV2Id !== null && (
        <FactureV2DetailDialog
          id={detailV2Id}
          onClose={() => setDetailV2Id(null)}
          onPrint={() => { const id = detailV2Id; const num = newItems.find(n => n.id === id)?.factureNumber || ""; setDetailV2Id(null); setPrintV2({ id: id!, factureNumber: num }); }}
          onEdit={() => {
            const id = detailV2Id;
            setDetailV2Id(null);
            apiRequest("GET", `/api/factures-v2/${id}`).then(r => r.json()).then((full: FactureWithLines) => {
              setEditFac(buildGroupFromV2(full));
              setEditV2Id(id);
            });
          }}
          onValidated={() => setDetailV2Id(null)}
        />
      )}
      {(showCreate || editFac) && (
        <FactureForm
          editFac={editFac}
          editV2Id={editV2Id}
          onClose={() => { setShowCreate(false); setEditFac(null); setEditV2Id(null); }}
          onSaved={() => { setShowCreate(false); setEditFac(null); setEditV2Id(null); }}
        />
      )}
      {deleteFac && (
        <DeleteDialog fac={deleteFac} onClose={() => setDeleteFac(null)} onDeleted={() => setDeleteFac(null)} />
      )}
      {deleteV2 && (
        <DeleteV2Dialog id={deleteV2.id} factureNumber={deleteV2.factureNumber} onClose={() => setDeleteV2(null)} onDeleted={() => setDeleteV2(null)} />
      )}
    </Dashboard>
  );
}
