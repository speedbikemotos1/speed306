import { cn } from "@/lib/utils";
import { CARTE_GRISE_STATUS } from "@shared/schema";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState } from "react";

interface StatusBadgeProps {
  status: string;
  currentRegistration?: string;
  onUpdate?: (newStatus: string, registrationNumber?: string) => void;
  editable?: boolean;
}

export function StatusBadge({ status, currentRegistration = "", onUpdate, editable = false }: StatusBadgeProps) {
  const [currentStatus, setCurrentStatus] = useState(status);
  const [showPlateDialog, setShowPlateDialog] = useState(false);
  const [pendingStatus, setPendingStatus] = useState<string | null>(null);

  // Extract just the digits from the current registration for editing
  const initDigits = (currentRegistration || "").replace(/[^0-9]/g, "").slice(0, 5);
  const [plateDigits, setPlateDigits] = useState(initDigits);

  // Displayed value: "12345 DN" when 5 digits, otherwise just the digits
  const plateInput = plateDigits.length === 5 ? `${plateDigits} DN` : plateDigits;

  const normalizedStatus = status?.replace(/['"]+/g, '') || "En cours";

  const getColor = (s: string) => {
    switch (s) {
      case "A Déposer":
        return "bg-red-100 text-red-700 border-red-200 hover:bg-red-200";
      case "Récupérée":
        return "bg-green-100 text-green-700 border-green-200 hover:bg-green-200";
      case "Impôt":
        return "bg-orange-100 text-orange-700 border-orange-200 hover:bg-orange-200";
      case "En cours":
        return "bg-purple-100 text-purple-700 border-purple-200 hover:bg-purple-200";
      case "Prête":
        return "bg-blue-100 text-blue-700 border-blue-200 hover:bg-blue-200";
      case "None":
        return "bg-gray-100 text-gray-500 border-gray-200 hover:bg-gray-200";
      default:
        return "bg-gray-100 text-gray-700 border-gray-200";
    }
  };

  const handleValueChange = (val: string) => {
    if (val === "Prête") {
      setPendingStatus(val);
      // Reset digits from current registration when dialog opens
      setPlateDigits((currentRegistration || "").replace(/[^0-9]/g, "").slice(0, 5));
      setShowPlateDialog(true);
    } else {
      setCurrentStatus(val);
      if (onUpdate) onUpdate(val);
    }
  };

  const handlePlateDigitChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    // If we're in full format and user is backspacing, strip suffix first
    if (plateDigits.length === 5 && val.length < plateInput.length) {
      setPlateDigits(plateDigits.slice(0, -1));
      return;
    }
    const digits = val.replace(/[^0-9]/g, "").slice(0, 5);
    setPlateDigits(digits);
  };

  const handlePlateConfirm = () => {
    if (pendingStatus) {
      setCurrentStatus(pendingStatus);
      if (onUpdate) onUpdate(pendingStatus, plateInput.trim() || undefined);
    }
    setShowPlateDialog(false);
    setPendingStatus(null);
  };

  const handlePlateCancel = () => {
    setShowPlateDialog(false);
    setPendingStatus(null);
  };

  if (editable && onUpdate) {
    return (
      <>
        <Select value={currentStatus} onValueChange={handleValueChange}>
          <SelectTrigger
            className={cn(
              "h-7 w-auto min-w-[110px] text-xs font-semibold rounded-full border px-3 transition-colors",
              getColor(currentStatus)
            )}
          >
            <span className="truncate">{currentStatus}</span>
          </SelectTrigger>
          <SelectContent>
            {CARTE_GRISE_STATUS.map((s) => (
              <SelectItem key={s} value={s} className="text-xs font-medium">
                {s}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Dialog open={showPlateDialog} onOpenChange={(open) => { if (!open) handlePlateCancel(); }}>
          <DialogContent className="sm:max-w-sm">
            <DialogHeader>
              <DialogTitle>Carte grise prête — Numéro d'immatriculation</DialogTitle>
            </DialogHeader>
            <div className="py-2">
              <Label htmlFor="plate-input" className="text-sm font-medium">
                Numéro de plaque
              </Label>
              <Input
                id="plate-input"
                data-testid="input-plate-number"
                className="mt-1.5 font-mono tracking-widest text-lg"
                placeholder="12345"
                value={plateInput}
                onChange={handlePlateDigitChange}
                onKeyDown={(e) => { if (e.key === "Enter") handlePlateConfirm(); }}
                maxLength={8}
                autoFocus
              />
              <p className="text-xs text-gray-400 mt-1.5">
                Saisissez les 5 chiffres — le suffixe <span className="font-mono font-bold">DN</span> sera ajouté automatiquement.
              </p>
            </div>
            <DialogFooter className="gap-2">
              <Button variant="outline" size="sm" onClick={handlePlateCancel}>
                Annuler
              </Button>
              <Button size="sm" onClick={handlePlateConfirm} data-testid="button-confirm-plate">
                Confirmer
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </>
    );
  }

  return (
    <span className={cn(
      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border",
      getColor(normalizedStatus)
    )}>
      {normalizedStatus}
    </span>
  );
}
