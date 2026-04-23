
import { db } from "./server/db";
import { clients as clientsTable } from "./shared/schema";
import xlsx from "xlsx";
import path from "path";

async function run() {
  const filePath = path.resolve(process.cwd(), "attached_assets/Clients_150_Cleaned.xlsx");
  const workbook = xlsx.readFile(filePath);
  const sheet = workbook.Sheets[workbook.SheetNames[0]];
  const data = xlsx.utils.sheet_to_json(sheet);

  console.log(`Starting import of ${data.length} clients...`);
  
  const clientsToInsert = data.map((row: any) => ({
    uniqueNumber: String(row[' h'] || '').trim(),
    nomPrenom: String(row['Nom et prénom'] || '').trim(),
    typeCompany: String(row['Type client'] || '').trim(),
    categorie: String(row['Catégorie'] || '').trim(),
    famille: String(row['Famille'] || '').trim(),
    civilite: String(row['Civilité'] || '').trim(),
    adresse: String(row['Adresse'] || '').trim(),
    codePostal: String(row['Code postal'] || '').trim(),
    numeroTelephone: String(row['Téléphone'] || '').trim(),
    cin: String(row['Matricule fiscale'] || '').trim(),
    remarque: ''
  }));

  for (const client of clientsToInsert) {
    try {
      await db.insert(clientsTable).values(client);
    } catch (e: any) {
      console.error(`Failed to insert ${client.nomPrenom}: ${e.message}`);
    }
  }

  console.log("Import completed.");
  process.exit(0);
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
