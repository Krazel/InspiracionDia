import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const CATEGORY_COPY_EN = {
  animo: { name: "Motivation", description: "To help you take the next step." },
  foco: { name: "Focus", description: "To return to what matters." },
  calma: { name: "Calm", description: "To quiet the noise within." },
  disciplina: { name: "Discipline", description: "To act without waiting for motivation." },
  autoestima: { name: "Self-worth", description: "To treat yourself with greater care." },
  gratitud: { name: "Gratitude", description: "To notice what already supports you." },
  valentia: { name: "Courage", description: "To move through fear." },
  habitos: { name: "Habits", description: "To repeat what helps you thrive." },
  creatividad: { name: "Creativity", description: "To see from a different angle." },
  resiliencia: { name: "Resilience", description: "To rebuild with dignity." },
  relaciones: { name: "Relationships", description: "To care for meaningful bonds." },
  energia: { name: "Energy", description: "To keep moving without burning out." }
};

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const categories = readExportedArray(path.join(root, "data", "categories.js"), "CATEGORIES")
  .filter((category) => category.id !== "hoy")
  .map((category) => ({ ...category, ...CATEGORY_COPY_EN[category.id] }));
const quotes = readExportedArray(path.join(root, "data", "quotes-en.js"), "QUOTES_EN");

const outPath = path.join(root, "native-ios", "Resources", "content-en.json");
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, JSON.stringify({ categories, quotes }, null, 2), "utf8");
console.log(`Exported ${quotes.length} English quotes to ${outPath}`);

function readExportedArray(filePath, name) {
  const source = fs.readFileSync(filePath, "utf8");
  const marker = `export const ${name} = `;
  const start = source.indexOf(marker);
  if (start === -1) throw new Error(`No se encontro ${name} en ${filePath}`);
  const body = source.slice(start + marker.length).trim().replace(/;$/, "");
  return Function(`"use strict"; return (${body});`)();
}
