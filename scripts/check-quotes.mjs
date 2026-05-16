import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const QUOTES = readExportedArray(path.join(root, "data", "quotes.js"), "QUOTES");
const CATEGORIES = readExportedArray(path.join(root, "data", "categories.js"), "CATEGORIES");

const ids = new Set();
const categoryIds = new Set(CATEGORIES.map((category) => category.id));
const errors = [];

for (const quote of QUOTES) {
  if (ids.has(quote.id)) errors.push(`ID duplicado: ${quote.id}`);
  ids.add(quote.id);
  if (!categoryIds.has(quote.category)) errors.push(`Categoria desconocida en ${quote.id}: ${quote.category}`);
  if (quote.text.length < 32) errors.push(`Frase demasiado corta en ${quote.id}`);
  if (quote.text.length > 138) errors.push(`Frase demasiado larga en ${quote.id}: ${quote.text.length}`);
}

if (errors.length > 0) {
  console.error(errors.join("\n"));
  process.exit(1);
}

console.log(`${QUOTES.length} frases revisadas en ${categoryIds.size - 1} categorias reales.`);

function readExportedArray(filePath, name) {
  const source = fs.readFileSync(filePath, "utf8");
  const marker = `export const ${name} = `;
  const start = source.indexOf(marker);
  if (start === -1) throw new Error(`No se encontro ${name} en ${filePath}`);
  const body = source.slice(start + marker.length).trim().replace(/;$/, "");
  return Function(`"use strict"; return (${body});`)();
}
