import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Notification } from "@shared/schema";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Bell, Clock, Trash2, Bike, Droplets, HardHat, LayoutDashboard, UserPlus, CreditCard, Edit, AlertTriangle, HardDriveDownload } from "lucide-react";
import { format, formatDistanceToNow } from "date-fns";
import { fr } from "date-fns/locale";
import { 
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Button } from "@/components/ui/button";
import { useState, useEffect } from "react";
import { useToast } from "@/hooks/use-toast";

type NotifColor = {
  badge: string;
  dot: string;
  icon: React.ReactNode;
  row: string;
};

function getNotifStyle(action: string): NotifColor {
  // RED — past due / overdue
  if (["IMPAYÉ", "RETARD"].includes(action)) {
    return {
      badge: "bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-400 border border-red-200",
      dot: "bg-red-500",
      icon: <AlertTriangle className="w-3 h-3" />,
      row: "border-l-4 border-l-red-400",
    };
  }
  // GREEN — payments received
  if (action === "PAIEMENT") {
    return {
      badge: "bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-400 border border-green-200",
      dot: "bg-green-500",
      icon: <CreditCard className="w-3 h-3" />,
      row: "border-l-4 border-l-green-400",
    };
  }
  // BLUE — new moto sale
  if (action === "VENTE MOTO") {
    return {
      badge: "bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-400 border border-blue-200",
      dot: "bg-blue-500",
      icon: <Bike className="w-3 h-3" />,
      row: "border-l-4 border-l-blue-400",
    };
  }
  // ORANGE — accessory sales (oil, casque, selle, divers)
  if (["VENTE HUILE", "VENTE CASQUE", "VENTE SELLE", "VENTE DIVERS"].includes(action)) {
    return {
      badge: "bg-orange-100 text-orange-700 dark:bg-orange-900/40 dark:text-orange-400 border border-orange-300",
      dot: "bg-orange-600",
      icon: <LayoutDashboard className="w-3 h-3" />,
      row: "border-l-4 border-l-orange-500",
    };
  }
  // BLACK/SLATE — new client
  if (action === "NOUVEAU CLIENT") {
    return {
      badge: "bg-slate-900 text-slate-100 dark:bg-slate-100 dark:text-slate-900 border border-slate-700",
      dot: "bg-slate-800",
      icon: <UserPlus className="w-3 h-3" />,
      row: "border-l-4 border-l-slate-700",
    };
  }
  // PURPLE — backup / sauvegarde
  if (action === "SAUVEGARDE") {
    return {
      badge: "bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-400 border border-purple-200",
      dot: "bg-purple-500",
      icon: <HardDriveDownload className="w-3 h-3" />,
      row: "border-l-4 border-l-purple-400",
    };
  }
  // YELLOW — modifications, deletions, imports, csv
  return {
    badge: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/40 dark:text-yellow-400 border border-yellow-200",
    dot: "bg-yellow-500",
    icon: <Edit className="w-3 h-3" />,
    row: "border-l-4 border-l-yellow-400",
  };
}

export function NotificationsPanel() {
  const queryClient = useQueryClient();
  const { toast } = useToast();
  const [isOpen, setIsOpen] = useState(false);
  
  const { data: notifications = [], isLoading } = useQuery<Notification[]>({
    queryKey: ["/api/notifications"],
    refetchInterval: 5000,
    staleTime: 0,
  });

  const unreadCount = notifications.filter(n => n.isRead === false).length;
  const topUnread = notifications.find(n => n.isRead === false);
  const dotColor = topUnread ? getNotifStyle(topUnread.action).dot : "bg-destructive";

  const markAsReadMutation = useMutation({
    mutationFn: async () => {
      const response = await fetch("/api/notifications/mark-read", {
        method: "POST",
        credentials: "include",
      });
      if (!response.ok) throw new Error("Failed to mark as read");
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/notifications"] });
    },
  });

  const clearNotificationsMutation = useMutation({
    mutationFn: async () => {
      const response = await fetch("/api/notifications", {
        method: "DELETE",
        credentials: "include",
      });
      if (!response.ok) throw new Error("Failed to clear notifications");
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/notifications"] });
      toast({ title: "Succès", description: "Notifications supprimées." });
    },
    onError: () => {
      toast({ title: "Erreur", description: "Impossible de supprimer les notifications.", variant: "destructive" });
    },
  });

  useEffect(() => {
    if (isOpen && unreadCount > 0) {
      markAsReadMutation.mutate();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen, unreadCount]);

  const formatNotificationDate = (timestamp: any) => {
    const date = timestamp instanceof Date ? timestamp : new Date(timestamp);
    if (isNaN(date.getTime())) return "";
    const now = new Date();
    const diffInHours = (now.getTime() - date.getTime()) / (1000 * 60 * 60);
    if (diffInHours < 24) {
      return formatDistanceToNow(date, { addSuffix: true, locale: fr });
    } else {
      return format(date, "dd MMM yyyy 'à' HH:mm", { locale: fr });
    }
  };

  return (
    <Popover open={isOpen} onOpenChange={setIsOpen}>
      <PopoverTrigger asChild>
        <Button variant="ghost" size="icon" className="relative hover-elevate">
          <Bell className="w-5 h-5" />
          {unreadCount > 0 && (
            <span className={`absolute top-2 right-2 w-2 h-2 rounded-full ${dotColor}`} />
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-96 p-0" align="end">
        <div className="p-4 border-b flex items-center justify-between bg-muted/30">
          <div>
            <h4 className="font-bold text-sm flex items-center gap-2">
              <Bell className="w-4 h-4" /> Notifications
            </h4>
            {/* Color legend */}
            <div className="flex flex-wrap gap-1.5 mt-2">
              <span className="flex items-center gap-1 text-[9px] font-semibold text-blue-700 bg-blue-50 border border-blue-200 rounded px-1.5 py-0.5"><Bike className="w-2.5 h-2.5" />Moto</span>
              <span className="flex items-center gap-1 text-[9px] font-semibold text-green-700 bg-green-50 border border-green-200 rounded px-1.5 py-0.5"><CreditCard className="w-2.5 h-2.5" />Paiement</span>
              <span className="flex items-center gap-1 text-[9px] font-semibold text-orange-700 bg-orange-50 border border-orange-300 rounded px-1.5 py-0.5"><LayoutDashboard className="w-2.5 h-2.5" />Accessoires</span>
              <span className="flex items-center gap-1 text-[9px] font-semibold text-slate-100 bg-slate-800 border border-slate-700 rounded px-1.5 py-0.5"><UserPlus className="w-2.5 h-2.5" />Client</span>
              <span className="flex items-center gap-1 text-[9px] font-semibold text-yellow-800 bg-yellow-50 border border-yellow-200 rounded px-1.5 py-0.5"><Edit className="w-2.5 h-2.5" />Modif.</span>
              <span className="flex items-center gap-1 text-[9px] font-semibold text-red-700 bg-red-50 border border-red-200 rounded px-1.5 py-0.5"><AlertTriangle className="w-2.5 h-2.5" />Retard</span>
              <span className="flex items-center gap-1 text-[9px] font-semibold text-purple-700 bg-purple-50 border border-purple-200 rounded px-1.5 py-0.5"><HardDriveDownload className="w-2.5 h-2.5" />Backup</span>
            </div>
          </div>
          {notifications.length > 0 && (
            <Button
              variant="ghost"
              size="sm"
              className="h-7 text-xs text-muted-foreground hover:text-destructive shrink-0 self-start"
              onClick={() => clearNotificationsMutation.mutate()}
              disabled={clearNotificationsMutation.isPending}
            >
              <Trash2 className="w-3 h-3 mr-1" />
              Effacer
            </Button>
          )}
        </div>
        <ScrollArea className="h-[420px]">
          <div className="flex flex-col">
            {isLoading ? (
              <div className="p-8 text-center text-sm text-muted-foreground">
                Chargement...
              </div>
            ) : notifications.length === 0 ? (
              <div className="p-8 text-center text-sm text-muted-foreground">
                Aucune notification récente.
              </div>
            ) : (
              notifications.map((notif) => {
                const style = getNotifStyle(notif.action);
                return (
                  <div 
                    key={notif.id} 
                    className={`p-4 border-b last:border-0 hover:bg-muted/40 transition-colors flex flex-col gap-1.5 ${style.row} ${
                      notif.isRead === false ? 'bg-muted/20' : ''
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className={`flex items-center gap-1 text-[10px] px-1.5 py-0.5 rounded font-bold uppercase ${style.badge}`}>
                        {style.icon}
                        {notif.action}
                      </span>
                      {notif.isRead === false && (
                        <span className={`w-2 h-2 rounded-full ${style.dot}`} />
                      )}
                    </div>
                    <div className="text-xs font-semibold text-foreground leading-tight">{notif.target}</div>
                    {notif.details && (
                      <div className="text-[11px] text-muted-foreground leading-snug">{notif.details}</div>
                    )}
                    <div className="flex items-center gap-1 text-[10px] text-muted-foreground mt-0.5">
                      <Clock className="w-3 h-3" />
                      {notif.timestamp && formatNotificationDate(notif.timestamp)}
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </ScrollArea>
      </PopoverContent>
    </Popover>
  );
}
