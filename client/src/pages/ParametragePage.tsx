import Dashboard from "@/pages/Dashboard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  HardDriveDownload, Download, RefreshCw, Clock, CheckCircle,
  Database, Users, FileText, Globe, CalendarDays, Info, Shield, XCircle, Loader2,
} from "lucide-react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { useState } from "react";

type BackupType = "generale" | "clients" | "bl";
type BackupInfo = {
  name: string;
  type: BackupType;
  size: number;
  date: string;
  monthly: boolean;
};

const TYPE_META: Record<BackupType, { label: string; icon: React.ReactNode; color: string; bg: string; border: string; desc: string }> = {
  generale: {
    label: "Complète",
    icon: <Globe className="w-4 h-4" />,
    color: "text-blue-700",
    bg: "bg-blue-50",
    border: "border-blue-200",
    desc: "Toutes les tables : ventes motos, huile, casques, selles, clients, BLs, factures, achats, commandes…",
  },
  clients: {
    label: "Clients",
    icon: <Users className="w-4 h-4" />,
    color: "text-emerald-700",
    bg: "bg-emerald-50",
    border: "border-emerald-200",
    desc: "Fiche complète de chaque client : nom, téléphone, CIN, adresse, banque, catégorie…",
  },
  bl: {
    label: "Bons de Livraison",
    icon: <FileText className="w-4 h-4" />,
    color: "text-violet-700",
    bg: "bg-violet-50",
    border: "border-violet-200",
    desc: "Toutes les lignes BL avec détails complets : réf, désignation, qté, prix HT, TVA, remise, TTC, numéro de série…",
  },
};

const TABS: BackupType[] = ["generale", "clients", "bl"];

export default function ParametragePage() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<BackupType>("generale");

  const { data: backups = [], isLoading } = useQuery<BackupInfo[]>({
    queryKey: ["/api/backups"],
    refetchInterval: 30_000,
  });

  const { data: health, isLoading: healthLoading } = useQuery<{ status: string }>({
    queryKey: ["/api/health"],
    refetchInterval: 60_000,
  });
  const dbOk = !healthLoading && health?.status === "ok";

  const triggerMutation = useMutation({
    mutationFn: () => apiRequest("POST", "/api/backups/trigger"),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/backups"] });
      toast({
        title: "3 sauvegardes créées",
        description: "Complète + Clients + Bons de Livraison — disponibles ci-dessous.",
      });
    },
    onError: (err: any) => {
      toast({ title: "Erreur", description: err.message, variant: "destructive" });
    },
  });

  function downloadBackup(name: string) {
    const a = document.createElement("a");
    a.href = `/api/backups/download/${name}`;
    a.download = name;
    a.click();
  }

  const filtered = backups.filter(b => b.type === activeTab);
  const meta = TYPE_META[activeTab];

  return (
    <Dashboard contentOnly>
      <div className="flex flex-col gap-6 p-6 max-w-4xl mx-auto min-h-screen">

        {/* Page header */}
        <div className="flex items-center gap-4 pt-2">
          <div className="p-3 bg-gradient-to-br from-slate-700 to-slate-900 rounded-2xl shadow-lg">
            <HardDriveDownload className="w-7 h-7 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-black tracking-tight text-gray-900 uppercase italic">Sauvegardes</h1>
            <p className="text-gray-500 text-sm">Copies de sécurité automatiques de votre base de données.</p>
          </div>
        </div>

        {/* ── How it works ── */}
        <Card className="border-blue-100 bg-blue-50/60 rounded-2xl shadow-sm">
          <CardHeader className="pb-2">
            <CardTitle className="flex items-center gap-2 text-xs font-black text-blue-700 uppercase tracking-widest">
              <Info className="w-3.5 h-3.5" /> Comment ça fonctionne ?
            </CardTitle>
          </CardHeader>
          <CardContent className="grid sm:grid-cols-3 gap-4 text-sm">
            <div className="flex flex-col gap-1">
              <span className="font-bold text-blue-800">📦 Ce que c'est</span>
              <span className="text-blue-700/80">Une sauvegarde est une photo de vos données à un instant T. Si une erreur se produit (suppression accidentelle, bug…), vous pouvez tout restaurer.</span>
            </div>
            <div className="flex flex-col gap-1">
              <span className="font-bold text-blue-800">⚡ Données en direct</span>
              <span className="text-blue-700/80">L'application enregistre chaque vente/client directement dans Supabase. La sauvegarde est un filet de sécurité en plus, pas le seul endroit où vos données existent.</span>
            </div>
            <div className="flex flex-col gap-1">
              <span className="font-bold text-blue-800">🔁 Restaurer</span>
              <span className="text-blue-700/80">Téléchargez le fichier .sql → allez dans Supabase → SQL Editor → collez le contenu → cliquez Run. Tout est restauré.</span>
            </div>
          </CardContent>
        </Card>

        {/* ── Schedule ── */}
        <Card className="border-gray-200 bg-white/80 rounded-2xl shadow-sm">
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center gap-2 text-xs font-black text-gray-500 uppercase tracking-widest">
              <Clock className="w-3.5 h-3.5" /> Planification automatique
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-xs text-gray-500 mb-4">
              Chaque déclenchement crée <strong>3 fichiers</strong> simultanément : Complète + Clients + BLs.
            </p>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {[
                { time: "12:00", retention: "7 jours", monthly: false },
                { time: "15:00", retention: "7 jours", monthly: false },
                { time: "18:00", retention: "30 jours", monthly: true },
                { time: "22:00", retention: "7 jours", monthly: false },
              ].map(({ time, retention, monthly }) => (
                <div key={time} className={`rounded-xl p-3 border ${monthly ? "bg-amber-50 border-amber-200" : "bg-gray-50 border-gray-200"}`}>
                  <div className={`text-lg font-black ${monthly ? "text-amber-700" : "text-gray-700"}`}>{time}</div>
                  <div className="flex items-center gap-1 mt-1">
                    <CalendarDays className={`w-3 h-3 ${monthly ? "text-amber-500" : "text-gray-400"}`} />
                    <span className={`text-xs font-semibold ${monthly ? "text-amber-600" : "text-gray-500"}`}>{retention}</span>
                  </div>
                  {monthly && <Badge className="mt-1.5 text-[10px] bg-amber-100 text-amber-700 border-amber-300 px-1.5 py-0">Mensuel</Badge>}
                </div>
              ))}
            </div>
            <p className="text-[11px] text-gray-400 mt-3">
              Heure de Tunis (UTC+1). Les fichiers plus anciens que la durée de rétention sont supprimés automatiquement.
            </p>
          </CardContent>
        </Card>

        {/* ── Database status ── */}
        <Card className="border-gray-200 bg-white/80 rounded-2xl shadow-sm">
          <CardContent className="flex items-center gap-3 py-4">
            <div className={`p-2 rounded-lg border ${healthLoading ? "bg-gray-50 border-gray-100" : dbOk ? "bg-green-50 border-green-100" : "bg-red-50 border-red-100"}`}>
              <Database className={`w-4 h-4 ${healthLoading ? "text-gray-400" : dbOk ? "text-green-600" : "text-red-600"}`} />
            </div>
            <div className="flex-1">
              <p className="font-bold text-gray-800 text-sm">Supabase PostgreSQL</p>
              <p className="text-xs text-gray-500">Données en direct dans Supabase (prod) / Replit local (dev)</p>
            </div>
            {healthLoading ? (
              <Badge className="bg-gray-100 text-gray-500 border-gray-200 shrink-0">
                <Loader2 className="w-3 h-3 mr-1 animate-spin" />Vérification…
              </Badge>
            ) : dbOk ? (
              <Badge className="bg-green-100 text-green-700 border-green-200 shrink-0" data-testid="badge-db-status">
                <CheckCircle className="w-3 h-3 mr-1" />Connecté
              </Badge>
            ) : (
              <Badge className="bg-red-100 text-red-700 border-red-200 shrink-0" data-testid="badge-db-status">
                <XCircle className="w-3 h-3 mr-1" />Erreur
              </Badge>
            )}
          </CardContent>
        </Card>

        {/* ── Backup files ── */}
        <Card className="border-gray-200 bg-white/80 rounded-2xl shadow-sm">
          <CardHeader className="pb-0">
            <div className="flex items-center justify-between flex-wrap gap-3">
              <CardTitle className="flex items-center gap-2 text-xs font-black text-gray-500 uppercase tracking-widest">
                <HardDriveDownload className="w-3.5 h-3.5" /> Fichiers disponibles
              </CardTitle>
              <Button
                data-testid="button-trigger-backup"
                size="sm"
                onClick={() => triggerMutation.mutate()}
                disabled={triggerMutation.isPending}
                className="gap-2 bg-slate-800 hover:bg-slate-700 text-white rounded-xl text-xs"
              >
                <RefreshCw className={`w-3.5 h-3.5 ${triggerMutation.isPending ? "animate-spin" : ""}`} />
                {triggerMutation.isPending ? "Génération…" : "Générer maintenant (3 fichiers)"}
              </Button>
            </div>

            {/* Tab selector */}
            <div className="flex gap-2 mt-4 flex-wrap">
              {TABS.map(t => {
                const m = TYPE_META[t];
                const count = backups.filter(b => b.type === t).length;
                return (
                  <button
                    key={t}
                    data-testid={`tab-backup-${t}`}
                    onClick={() => setActiveTab(t)}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg border text-xs font-bold transition-all ${
                      activeTab === t
                        ? `${m.bg} ${m.color} ${m.border} shadow-sm`
                        : "bg-gray-50 text-gray-500 border-gray-200 hover:bg-gray-100"
                    }`}
                  >
                    {m.icon}
                    {m.label}
                    <span className={`ml-1 px-1.5 py-0.5 rounded-full text-[10px] font-black ${activeTab === t ? `${m.bg} ${m.color}` : "bg-gray-200 text-gray-500"}`}>
                      {count}
                    </span>
                  </button>
                );
              })}
            </div>
          </CardHeader>

          <CardContent className="pt-4">
            {/* Active tab description */}
            <div className={`flex items-start gap-2 p-3 rounded-xl ${meta.bg} ${meta.border} border mb-4`}>
              <span className={meta.color}>{meta.icon}</span>
              <div>
                <p className={`text-xs font-bold ${meta.color}`}>Sauvegarde {meta.label}</p>
                <p className={`text-xs ${meta.color} opacity-80`}>{meta.desc}</p>
              </div>
            </div>

            {/* File list */}
            {isLoading ? (
              <div className="flex items-center gap-2 text-gray-400 text-sm py-6 justify-center">
                <RefreshCw className="w-4 h-4 animate-spin" /> Chargement…
              </div>
            ) : filtered.length === 0 ? (
              <div className="text-center py-8">
                <HardDriveDownload className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                <p className="text-sm text-gray-400">Aucun fichier disponible.</p>
                <p className="text-xs text-gray-400 mt-1">Cliquez sur "Générer maintenant" pour créer vos premières sauvegardes.</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {filtered.map(b => (
                  <div
                    key={b.name}
                    data-testid={`row-backup-${b.name}`}
                    className="flex items-center justify-between py-3 gap-3"
                  >
                    <div className="flex flex-col min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="text-xs font-bold text-gray-700 truncate">{b.date}</span>
                        {b.monthly ? (
                          <Badge className="text-[10px] bg-amber-100 text-amber-700 border-amber-300 px-1.5 py-0">
                            <Shield className="w-2.5 h-2.5 mr-0.5" />30 jours
                          </Badge>
                        ) : (
                          <Badge className="text-[10px] bg-gray-100 text-gray-500 border-gray-200 px-1.5 py-0">
                            7 jours
                          </Badge>
                        )}
                      </div>
                      <span className="text-[11px] text-gray-400 mt-0.5">{b.size} KB · {b.name}</span>
                    </div>
                    <Button
                      data-testid={`button-download-${b.name}`}
                      size="sm"
                      variant="outline"
                      onClick={() => downloadBackup(b.name)}
                      className={`shrink-0 gap-1.5 rounded-xl text-xs border-gray-200 hover:${meta.border} hover:${meta.color}`}
                    >
                      <Download className="w-3.5 h-3.5" />
                      Télécharger
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* ── Share tip ── */}
        <Card className="border-gray-100 bg-gray-50/80 rounded-2xl shadow-sm">
          <CardContent className="py-4 flex items-start gap-3">
            <Info className="w-4 h-4 text-gray-400 mt-0.5 shrink-0" />
            <p className="text-xs text-gray-500">
              <strong className="text-gray-600">Partager un fichier :</strong> après téléchargement (.sql), vous pouvez l'envoyer par email, le déposer sur Google Drive, ou l'envoyer sur WhatsApp comme pièce jointe. Pour restaurer, collez-le dans Supabase → SQL Editor → Run.
            </p>
          </CardContent>
        </Card>

      </div>
    </Dashboard>
  );
}
