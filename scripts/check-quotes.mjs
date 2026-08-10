import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const spanishQuotes = readExportedArray(path.join(root, "data", "quotes.js"), "QUOTES");
const englishQuotes = readExportedArray(path.join(root, "data", "quotes-en.js"), "QUOTES_EN");
const CATEGORIES = readExportedArray(path.join(root, "data", "categories.js"), "CATEGORIES");

const categoryIds = new Set(CATEGORIES.map((category) => category.id));
const errors = [];
const expectedSpanishCategoryNames = new Map([
  ["animo", "Ánimo"],
  ["foco", "Foco"],
  ["calma", "Calma"],
  ["disciplina", "Disciplina"],
  ["autoestima", "Autoestima"],
  ["gratitud", "Gratitud"],
  ["valentia", "Valentía"],
  ["habitos", "Hábitos"],
  ["creatividad", "Creatividad"],
  ["resiliencia", "Resiliencia"],
  ["relaciones", "Relaciones"],
  ["energia", "Energía"],
]);

for (const [id, expectedName] of expectedSpanishCategoryNames) {
  const category = CATEGORIES.find((item) => item.id === id);
  if (category?.name !== expectedName) {
    errors.push(`Spanish category name mismatch for ${id}: ${category?.name ?? "missing"}`);
  }
}

validateQuotes("Spanish", spanishQuotes);
validateQuotes("English", englishQuotes);

const spanishById = new Map(spanishQuotes.map((quote) => [quote.id, quote]));
const englishById = new Map(englishQuotes.map((quote) => [quote.id, quote]));

for (const [id, spanishQuote] of spanishById) {
  const englishQuote = englishById.get(id);
  if (!englishQuote) errors.push(`Missing English quote: ${id}`);
  if (englishQuote && englishQuote.category !== spanishQuote.category) {
    errors.push(`Category mismatch for ${id}: ${spanishQuote.category} / ${englishQuote.category}`);
  }
}

for (const id of englishById.keys()) {
  if (!spanishById.has(id)) errors.push(`English quote has no Spanish source: ${id}`);
}

if (errors.length > 0) {
  console.error(errors.join("\n"));
  process.exit(1);
}

console.log(`${spanishQuotes.length} Spanish quotes and ${englishQuotes.length} English quotes checked across ${categoryIds.size - 1} categories.`);

function validateQuotes(label, quotes) {
  const ids = new Set();
  const texts = new Set();
  for (const quote of quotes) {
    if (ids.has(quote.id)) errors.push(`${label} duplicate ID: ${quote.id}`);
    if (texts.has(quote.text)) errors.push(`${label} duplicate text: ${quote.id}`);
    ids.add(quote.id);
    texts.add(quote.text);
    if (!categoryIds.has(quote.category)) errors.push(`${label} unknown category in ${quote.id}: ${quote.category}`);
    if (quote.text.length < 32) errors.push(`${label} quote too short: ${quote.id}`);
    if (quote.text.length > 138) errors.push(`${label} quote too long: ${quote.id} (${quote.text.length})`);
  }
}

function readExportedArray(filePath, name) {
  const source = fs.readFileSync(filePath, "utf8");
  const marker = `export const ${name} = `;
  const start = source.indexOf(marker);
  if (start === -1) throw new Error(`No se encontro ${name} en ${filePath}`);
  const body = source.slice(start + marker.length).trim().replace(/;$/, "");
  return Function(`"use strict"; return (${body});`)();
}
