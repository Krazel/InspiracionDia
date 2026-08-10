import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const draftPaths = [
  path.join(root, "docs", "content-review", "draft-a.json"),
  path.join(root, "docs", "content-review", "draft-b.json"),
];
const categories = readExportedArray(path.join(root, "data", "categories.js"), "CATEGORIES")
  .map(({ id }) => id)
  .filter((id) => id !== "hoy");
const categoryOrder = new Map(categories.map((id, index) => [id, index]));
const drafts = draftPaths.map((draftPath) => JSON.parse(fs.readFileSync(draftPath, "utf8")));

integrateLanguage({
  language: "es",
  exportName: "QUOTES",
  filePath: path.join(root, "data", "quotes.js"),
});
integrateLanguage({
  language: "en",
  exportName: "QUOTES_EN",
  filePath: path.join(root, "data", "quotes-en.js"),
});

console.log("Integrated the reviewed bilingual catalog: 360 Spanish and 360 English quotes.");

function integrateLanguage({ language, exportName, filePath }) {
  const existing = readExportedArray(filePath, exportName);
  const merged = new Map(existing.map((quote) => [quote.id, quote]));

  for (const draft of drafts) {
    for (const [category, pairs] of Object.entries(draft.categories)) {
      if (!categoryOrder.has(category)) throw new Error(`Unknown draft category: ${category}`);
      for (const pair of pairs) {
        const text = pair[language];
        if (typeof text !== "string") throw new Error(`Missing ${language} text for ${pair.id}`);
        if (pair.id.slice(0, pair.id.lastIndexOf("-")) !== category) {
          throw new Error(`Draft ID/category mismatch: ${pair.id} / ${category}`);
        }
        merged.set(pair.id, { id: pair.id, category, text });
      }
    }

    for (const review of draft.weakExisting ?? []) {
      const current = merged.get(review.id);
      if (!current) throw new Error(`Weak-quote replacement target is missing: ${review.id}`);
      const text = review.replacement?.[language];
      if (typeof text !== "string") throw new Error(`Missing ${language} replacement for ${review.id}`);
      merged.set(review.id, { ...current, text });
    }
  }

  const quotes = [...merged.values()].sort((left, right) => {
    const categoryDifference = categoryOrder.get(left.category) - categoryOrder.get(right.category);
    if (categoryDifference !== 0) return categoryDifference;
    return numericSuffix(left.id) - numericSuffix(right.id);
  });

  if (quotes.length !== categories.length * 30) {
    throw new Error(`${language} catalog should contain 360 quotes; found ${quotes.length}`);
  }
  for (const category of categories) {
    const count = quotes.filter((quote) => quote.category === category).length;
    if (count !== 30) throw new Error(`${language}/${category} should contain 30 quotes; found ${count}`);
  }

  const rendered = quotes
    .map(({ id, category, text }) =>
      `  { id: ${JSON.stringify(id)}, category: ${JSON.stringify(category)}, text: ${JSON.stringify(text)} },`
    )
    .join("\n");
  fs.writeFileSync(filePath, `export const ${exportName} = [\n${rendered}\n];\n`, "utf8");
}

function numericSuffix(id) {
  const suffix = Number(id.slice(id.lastIndexOf("-") + 1));
  if (!Number.isInteger(suffix)) throw new Error(`Invalid quote ID: ${id}`);
  return suffix;
}

function readExportedArray(filePath, name) {
  const source = fs.readFileSync(filePath, "utf8");
  const marker = `export const ${name} = `;
  const start = source.indexOf(marker);
  if (start === -1) throw new Error(`Missing ${name} in ${filePath}`);
  const body = source.slice(start + marker.length).trim().replace(/;$/, "");
  return Function(`"use strict"; return (${body});`)();
}
