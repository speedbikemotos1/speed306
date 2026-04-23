export const COMPANY = {
  name: "Speed Bike Motos",
  address: "Route C35 BOUJARDGA, 2090 MORNAG",
  phone: "(+216) 28 126 691",
  mf: "1903544J/N/M/000",
};

export const TIMBRE = 1.0;

export function formatNum3(n: number): string {
  return n.toLocaleString("fr-TN", { minimumFractionDigits: 3, maximumFractionDigits: 3 });
}

const UNITS = ["", "un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf",
  "dix", "onze", "douze", "treize", "quatorze", "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf"];
const TENS = ["", "", "vingt", "trente", "quarante", "cinquante", "soixante", "soixante", "quatre-vingt", "quatre-vingt"];

function belowHundred(n: number): string {
  if (n < 20) return UNITS[n];
  const t = Math.floor(n / 10);
  const u = n % 10;
  if (t === 7 || t === 9) {
    return TENS[t] + (u === 1 && t === 7 ? "-et-" : "-") + UNITS[10 + u];
  }
  if (t === 8) return "quatre-vingt" + (u > 0 ? "-" + UNITS[u] : "s");
  return TENS[t] + (u === 1 ? "-et-un" : u > 0 ? "-" + UNITS[u] : "");
}

function belowThousand(n: number): string {
  if (n < 100) return belowHundred(n);
  const h = Math.floor(n / 100);
  const r = n % 100;
  const hundreds = (h === 1 ? "cent" : UNITS[h] + "-cent") + (r === 0 && h > 1 ? "s" : "");
  return r === 0 ? hundreds : hundreds + "-" + belowHundred(r);
}

export function nombreEnLettres(n: number): string {
  const total = Math.round(n * 1000);
  const dinars = Math.floor(total / 1000);
  const millimes = total % 1000;

  let result = "";
  if (dinars === 0) {
    result = "zéro";
  } else if (dinars < 1000) {
    result = belowThousand(dinars);
  } else if (dinars < 1000000) {
    const thousands = Math.floor(dinars / 1000);
    const rem = dinars % 1000;
    result = (thousands === 1 ? "mille" : belowThousand(thousands) + "-mille") + (rem > 0 ? "-" + belowThousand(rem) : "");
  } else {
    const millions = Math.floor(dinars / 1000000);
    const rem = dinars % 1000000;
    result = belowThousand(millions) + "-million" + (millions > 1 ? "s" : "") + (rem > 0 ? "-" + belowThousand(rem) : "");
  }

  result = result.charAt(0).toUpperCase() + result.slice(1) + " Dinar" + (dinars > 1 ? "s" : "");

  if (millimes > 0) {
    let mStr = "";
    if (millimes < 1000) mStr = belowThousand(millimes);
    result += " et " + mStr + " Millime" + (millimes > 1 ? "s" : "");
  }

  return result;
}

export function buildPrintHtml(bodyContent: string, title: string): string {
  return `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${title}</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    html, body {
      font-family: Arial, Helvetica, sans-serif;
      font-size: 11px;
      color: #000;
      background: #fff;
      width: 210mm;
    }
    body { padding: 15mm; }
    table { width: 100%; border-collapse: collapse; }
    th, td { vertical-align: top; }
    .text-right { text-align: right; }
    .text-center { text-align: center; }
    .text-left { text-align: left; }
    .bold { font-weight: bold; }
    img { display: block; }
    @page {
      size: A4 portrait;
      margin: 0;
    }
    @media print {
      html, body {
        width: 210mm;
        padding: 15mm;
        margin: 0;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
      }
    }
  </style>
</head>
<body>${bodyContent}</body>
</html>`;
}

export function openPrintWindow(html: string): void {
  const win = window.open("", "_blank");
  if (!win) return;
  win.document.write(html);
  win.document.close();
  win.focus();
  setTimeout(() => {
    win.print();
  }, 700);
}
