import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const spanishQuotes = readExportedArray(path.join(root, "data", "quotes.js"), "QUOTES");
const englishQuotes = readExportedArray(path.join(root, "data", "quotes-en.js"), "QUOTES_EN");
const CATEGORIES = readExportedArray(path.join(root, "data", "categories.js"), "CATEGORIES");

const categoryIds = new Set(CATEGORIES.map((category) => category.id));
const quoteCategoryIds = CATEGORIES.map((category) => category.id).filter((id) => id !== "hoy");
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
validateCatalogShape("Spanish", spanishQuotes);
validateCatalogShape("English", englishQuotes);

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
  const normalizedTexts = new Map();
  for (const quote of quotes) {
    if (ids.has(quote.id)) errors.push(`${label} duplicate ID: ${quote.id}`);
    if (texts.has(quote.text)) errors.push(`${label} duplicate text: ${quote.id}`);
    ids.add(quote.id);
    texts.add(quote.text);
    const normalized = normalizeText(quote.text);
    if (normalizedTexts.has(normalized)) {
      errors.push(`${label} normalized duplicate text: ${normalizedTexts.get(normalized)} / ${quote.id}`);
    }
    normalizedTexts.set(normalized, quote.id);
    if (!categoryIds.has(quote.category)) errors.push(`${label} unknown category in ${quote.id}: ${quote.category}`);
    if (quote.text.length < 32) errors.push(`${label} quote too short: ${quote.id}`);
    if (quote.text.length > 138) errors.push(`${label} quote too long: ${quote.id} (${quote.text.length})`);
  }

  for (let leftIndex = 0; leftIndex < quotes.length; leftIndex += 1) {
    for (let rightIndex = leftIndex + 1; rightIndex < quotes.length; rightIndex += 1) {
      const left = tokenSet(quotes[leftIndex].text);
      const right = tokenSet(quotes[rightIndex].text);
      if (Math.min(left.size, right.size) < 7) continue;
      const overlap = [...left].filter((token) => right.has(token)).length;
      const union = new Set([...left, ...right]).size;
      if (overlap / union >= 0.86) {
        errors.push(`${label} near-duplicate text: ${quotes[leftIndex].id} / ${quotes[rightIndex].id}`);
      }
    }
  }
}

function validateCatalogShape(label, quotes) {
  if (quotes.length !== quoteCategoryIds.length * 60) {
    errors.push(`${label} catalog must contain exactly 720 quotes; found ${quotes.length}`);
  }
  for (const category of quoteCategoryIds) {
    const categoryQuotes = quotes.filter((quote) => quote.category === category);
    if (categoryQuotes.length !== 60) {
      errors.push(`${label} category ${category} must contain 60 quotes; found ${categoryQuotes.length}`);
      continue;
    }
    const expectedIds = Array.from(
      { length: 60 },
      (_, index) => `${category}-${String(index + 1).padStart(3, "0")}`,
    );
    const actualIds = categoryQuotes.map(({ id }) => id);
    if (actualIds.some((id, index) => id !== expectedIds[index])) {
      errors.push(`${label} category ${category} IDs must be ordered from 001 to 060`);
    }
  }
}

function normalizeText(text) {
  return text
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim()
    .replace(/\s+/g, " ");
}

function tokenSet(text) {
  return new Set(normalizeText(text).split(" ").filter(Boolean));
}

function readExportedArray(filePath, name) {
  const source = fs.readFileSync(filePath, "utf8");
  const marker = `export const ${name} = `;
  const start = source.indexOf(marker);
  if (start === -1) throw new Error(`No se encontro ${name} en ${filePath}`);
  const body = source.slice(start + marker.length).trim().replace(/;$/, "");
  return Function(`"use strict"; return (${body});`)();
}
