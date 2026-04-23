import { SalesTable } from "@/components/SalesTable";
import { CreateSaleDialog } from "@/components/CreateSaleDialog";
import { NotificationsPanel } from "@/components/NotificationsPanel";
import logoImg from "@assets/LOGOBranding_1771926826080.png";
import { useSales } from "@/hooks/use-sales";
import { useHelmetSales } from "@/hooks/use-helmets";
import { Bike, HardHat, Droplets, Shield, Split, LayoutDashboard, ShoppingCart, CalendarDays, LogOut, CircleUser, Menu, Users, FileText, Receipt, HardDriveDownload, Tag, ChevronDown, Package, Truck, Boxes } from "lucide-react";
import { Link, useLocation } from "wouter";
import { useAuth } from "@/hooks/use-auth";
import { Button } from "@/components/ui/button";
import { Sheet, SheetClose, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { useState, useRef, useEffect } from "react";

function NavDropdown({
  label,
  icon,
  isActive,
  links,
  currentLocation,
}: {
  label: string;
  icon: React.ReactNode;
  isActive: boolean;
  links: { href: string; icon: React.ReactNode; label: string }[];
  currentLocation: string;
}) {
  const [open, setOpen] = useState(false);
  const [dropPos, setDropPos] = useState({ top: 0, left: 0 });
  const ref = useRef<HTMLDivElement>(null);
  const btnRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  const handleToggle = () => {
    if (!open && btnRef.current) {
      const rect = btnRef.current.getBoundingClientRect();
      setDropPos({ top: rect.bottom + 4, left: rect.left });
    }
    setOpen(o => !o);
  };

  return (
    <div ref={ref} className="relative">
      <button
        ref={btnRef}
        onClick={handleToggle}
        className={`flex items-center gap-1.5 px-3 py-2 rounded-md transition-all duration-200 font-bold text-xs whitespace-nowrap ${
          isActive
            ? "bg-primary text-primary-foreground shadow-sm scale-105"
            : "text-muted-foreground hover:bg-muted hover:text-foreground"
        }`}
      >
        {icon}
        {label}
        <ChevronDown className={`w-3 h-3 ml-0.5 opacity-60 transition-transform ${open ? "rotate-180" : ""}`} />
      </button>
      {open && (
        <div
          style={{ position: "fixed", top: dropPos.top, left: dropPos.left, zIndex: 9999 }}
          className="w-48 rounded-lg border bg-white shadow-lg py-1"
        >
          {links.map(({ href, icon: linkIcon, label: linkLabel }) => (
            <Link key={href} href={href}>
              <a
                onClick={() => setOpen(false)}
                className={`flex items-center gap-2.5 px-3 py-2 text-xs font-semibold transition-colors hover:bg-muted ${
                  currentLocation === href ? "text-primary bg-primary/5" : "text-muted-foreground hover:text-foreground"
                }`}
              >
                {linkIcon}
                {linkLabel}
              </a>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}


export default function Dashboard({ children, contentOnly = false }: { children?: React.ReactNode, contentOnly?: boolean }) {
  const [location] = useLocation();
  const { logoutMutation, user } = useAuth();
  const { data: sales = [] } = useSales();
  const { data: helmetSales = [] } = useHelmetSales();

  const motoCount = sales.filter((s: any) => (s.chassisNumber ?? "").toString().trim() !== "").length;
  const helmetCount = helmetSales.reduce((acc, s) => acc + Number(s.quantite ?? 1), 0);

  const accessoireLinks = [
    { href: "/oil", icon: <Droplets className="w-3.5 h-3.5" />, label: "Huile" },
    { href: "/helmets", icon: <Shield className="w-3.5 h-3.5" />, label: "Casques" },
    { href: "/cache-selle", icon: <CircleUser className="w-3.5 h-3.5" />, label: "Cache-Selle" },
    { href: "/differ", icon: <Split className="w-3.5 h-3.5" />, label: "Divers" },
    { href: "/commande", icon: <ShoppingCart className="w-3.5 h-3.5" />, label: "Commandes" },
  ];

  const venteLinks = [
    { href: "/stock/motos", icon: <Boxes className="w-3.5 h-3.5" />, label: "Stock Motos" },
    { href: "/reception", icon: <Truck className="w-3.5 h-3.5" />, label: "Bon de Réception" },
    { href: "/livraison", icon: <FileText className="w-3.5 h-3.5" />, label: "Bons de Livraison" },
    { href: "/factures", icon: <Receipt className="w-3.5 h-3.5" />, label: "Factures" },
    { href: "/reservation", icon: <CalendarDays className="w-3.5 h-3.5" />, label: "Réservations" },
  ];

  const isAccessoireActive = accessoireLinks.some(l => location === l.href);
  const isVenteActive = venteLinks.some(l => location === l.href);

  return (
    <div className="h-screen bg-background flex flex-col overflow-hidden">
      <header className="border-b bg-card/80 backdrop-blur-md sticky top-0 z-50 shadow-sm shrink-0">
        <div className="px-3 h-14 flex items-center justify-between gap-2 lg:gap-6">

          {/* Logo */}
          <div className="flex items-center gap-2 shrink-0">
            <div className="p-1 bg-white rounded-xl overflow-hidden border shadow-sm transition-transform hover:scale-105 shrink-0 flex items-center justify-center">
              <img src={logoImg} alt="Speed Bike" className="w-10 h-10 md:w-11 md:h-11 object-contain" />
            </div>
            <div className="hidden md:flex flex-col justify-center pl-1">
              <h1 className="text-xl font-black tracking-tight uppercase italic text-primary leading-none">Speed Bike</h1>
            </div>
          </div>

          {/* Desktop nav */}
          <nav className="hidden lg:flex items-center gap-1">
            <NavLink href="/" icon={<LayoutDashboard className="w-3.5 h-3.5" />} label="Dash" active={location === "/"} isPrimary />
            <NavLink href="/gestion/clients" icon={<Users className="w-3.5 h-3.5" />} label="Clients" active={location === "/gestion/clients"} isPrimary />

            <div className="h-6 w-px bg-gray-300 mx-1.5" />

            <NavDropdown
              label="Accessoires & Pièces"
              icon={<Package className="w-3.5 h-3.5" />}
              isActive={isAccessoireActive}
              links={accessoireLinks}
              currentLocation={location}
            />

            <NavDropdown
              label="Vente"
              icon={<Receipt className="w-3.5 h-3.5" />}
              isActive={isVenteActive}
              links={venteLinks}
              currentLocation={location}
            />
          </nav>

          {/* Right actions */}
          <div className="flex items-center gap-1.5 md:gap-2">
            <div className="hidden 2xl:flex items-center gap-2 mr-1">
              <StatBadge icon={<Bike className="w-3.5 h-3.5" />} label="Motos" count={motoCount} color="blue" />
              <StatBadge icon={<HardHat className="w-3.5 h-3.5" />} label="Casques" count={helmetCount} color="slate" />
            </div>

            {user && (
              <Link href="/tarif">
                <a
                  data-testid="link-tarif"
                  title="Tarif Pièces"
                  className={`flex items-center gap-1.5 px-2 py-1.5 rounded-lg border transition-all duration-200 font-bold text-xs whitespace-nowrap shadow-sm ${
                    location === "/tarif"
                      ? "bg-indigo-700 text-white border-indigo-700"
                      : "bg-white text-indigo-600 border-indigo-200 hover:bg-indigo-50 hover:text-indigo-800"
                  }`}
                >
                  <Tag className="w-3.5 h-3.5" />
                  <span className="hidden lg:inline">Tarif</span>
                </a>
              </Link>
            )}

            {user && (
              <Link href="/gestion/parametrage">
                <a
                  data-testid="link-parametrage"
                  title="Paramétrage & Sauvegardes"
                  className={`flex items-center gap-1.5 px-2 py-1.5 rounded-lg border transition-all duration-200 font-bold text-xs whitespace-nowrap shadow-sm ${
                    location === "/gestion/parametrage"
                      ? "bg-slate-800 text-white border-slate-700"
                      : "bg-white text-slate-600 border-slate-200 hover:bg-slate-100 hover:text-slate-800"
                  }`}
                >
                  <HardDriveDownload className="w-3.5 h-3.5" />
                  <span className="hidden lg:inline">Backup</span>
                </a>
              </Link>
            )}

            <div className="flex items-center gap-0.5 bg-muted/30 p-1 rounded-full border">
              <NotificationsPanel />
              <CreateSaleDialog />
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full h-8 w-8 text-muted-foreground hover:text-destructive transition-colors"
                onClick={() => logoutMutation.mutate()}
              >
                <LogOut className="w-4 h-4" />
              </Button>
            </div>

            {/* Mobile nav sheet */}
            <Sheet>
              <SheetTrigger asChild>
                <Button variant="ghost" size="icon" className="lg:hidden h-8 w-8 rounded-lg border" data-testid="button-mobile-menu">
                  <Menu className="w-4 h-4" />
                </Button>
              </SheetTrigger>
              <SheetContent side="right" className="w-64 p-0">
                <SheetHeader className="px-4 py-3 border-b">
                  <SheetTitle className="text-sm font-black uppercase italic text-primary">Navigation</SheetTitle>
                </SheetHeader>
                <nav className="flex flex-col gap-1 p-3 overflow-y-auto">
                  {([
                    { href: "/", icon: <LayoutDashboard className="w-4 h-4" />, label: "Dashboard" },
                    { href: "/gestion/clients", icon: <Users className="w-4 h-4" />, label: "Clients" },
                    { href: "/oil", icon: <Droplets className="w-4 h-4" />, label: "Huile" },
                    { href: "/stock/motos", icon: <Boxes className="w-4 h-4" />, label: "Stock Motos" },
                    { href: "/reception", icon: <Truck className="w-4 h-4" />, label: "Bon de Réception" },
                    { href: "/livraison", icon: <FileText className="w-4 h-4" />, label: "Bons de Livraison" },
                    { href: "/reservation", icon: <CalendarDays className="w-4 h-4" />, label: "Réservations" },
                    null,
                    { href: "/helmets", icon: <Shield className="w-4 h-4" />, label: "Casques" },
                    { href: "/cache-selle", icon: <CircleUser className="w-4 h-4" />, label: "Cache-Selle" },
                    { href: "/differ", icon: <Split className="w-4 h-4" />, label: "Divers" },
                    { href: "/commande", icon: <ShoppingCart className="w-4 h-4" />, label: "Commandes" },
                    null,
                    { href: "/factures", icon: <Receipt className="w-4 h-4" />, label: "Factures" },
                    null,
                    { href: "/tarif", icon: <Tag className="w-4 h-4" />, label: "Tarif Pièces" },
                    { href: "/gestion/parametrage", icon: <HardDriveDownload className="w-4 h-4" />, label: "Backup & Paramétrage" },
                  ] as const).map((item, idx) =>
                    item === null ? (
                      <div key={idx} className="h-px bg-border mx-2 my-1" />
                    ) : (
                      <SheetClose asChild key={item.href}>
                        <Link href={item.href}>
                          <a className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-semibold transition-colors ${
                            location === item.href
                              ? "bg-primary text-primary-foreground"
                              : "text-muted-foreground hover:bg-muted hover:text-foreground"
                          }`}>
                            {item.icon}{item.label}
                          </a>
                        </Link>
                      </SheetClose>
                    )
                  )}
                </nav>
              </SheetContent>
            </Sheet>
          </div>
        </div>
      </header>

      <main className="flex-1 overflow-y-auto p-2 sm:p-4 min-h-0">
        {contentOnly ? children : <SalesTable />}
      </main>

      <footer className="border-t py-4 text-center text-[10px] font-medium uppercase tracking-widest text-muted-foreground bg-muted/10 shrink-0">
        <p>© 2026 Speed Bike Motos • Premium Management System</p>
      </footer>
    </div>
  );
}

function NavLink({ href, icon, label, active, isPrimary = false }: {
  href: string; icon: React.ReactNode; label: string; active: boolean; isPrimary?: boolean;
}) {
  return (
    <Link href={href}>
      <a className={`flex items-center gap-1.5 px-3 py-2 rounded-md transition-all duration-200 font-bold text-xs whitespace-nowrap ${
        active
          ? isPrimary
            ? "bg-red-100 text-red-700 shadow-sm scale-105 border border-red-200"
            : "bg-primary text-primary-foreground shadow-sm scale-105"
          : isPrimary
            ? "text-gray-700 hover:bg-red-50 hover:text-red-600"
            : "text-muted-foreground hover:bg-muted hover:text-foreground"
      }`}>
        <span className="shrink-0">{icon}</span>
        <span>{label}</span>
      </a>
    </Link>
  );
}

function StatBadge({ icon, label, count, color }: {
  icon: React.ReactNode; label: string; count: number; color: "blue" | "slate";
}) {
  const colors = {
    blue: "bg-blue-50 text-blue-700 border-blue-100",
    slate: "bg-slate-50 text-slate-700 border-slate-100",
  };
  return (
    <div className={`flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-bold border shadow-sm whitespace-nowrap ${colors[color]}`}>
      {icon}
      <span>{label}: {count}</span>
    </div>
  );
}
