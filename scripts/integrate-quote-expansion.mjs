import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const proposalPaths = [
  "docs/content-review/proposals/core-031-060.json",
  "docs/content-review/proposals/growth-031-060.json",
  "docs/content-review/proposals/life-031-060.json",
].map((relativePath) => path.join(root, relativePath));
const categories = readExportedArray(path.join(root, "data", "categories.js"), "CATEGORIES")
  .map(({ id }) => id)
  .filter((id) => id !== "hoy");
const categoryOrder = new Map(categories.map((id, index) => [id, index]));
const proposals = proposalPaths.flatMap((proposalPath) => {
  const parsed = JSON.parse(fs.readFileSync(proposalPath, "utf8"));
  if (!Array.isArray(parsed)) throw new Error(`Proposal must be an array: ${proposalPath}`);
  return parsed;
});

validateProposals();
integrateLanguage({ language: "es", exportName: "QUOTES", fileName: "quotes.js" });
integrateLanguage({ language: "en", exportName: "QUOTES_EN", fileName: "quotes-en.js" });

console.log("Integrated the expanded bilingual catalog: 720 Spanish and 720 English quotes.");

function validateProposals() {
  if (proposals.length !== categories.length * 30) {
    throw new Error(`Expected 360 proposed pairs; found ${proposals.length}`);
  }
  const seenIds = new Set();
  for (const proposal of proposals) {
    if (!categoryOrder.has(proposal.category)) {
      throw new Error(`Unknown proposal category: ${proposal.category}`);
    }
    if (!seenIds.add(proposal.id)) throw new Error(`Duplicate proposal ID: ${proposal.id}`);
    const expectedPrefix = `${proposal.category}-`;
    const suffix = numericSuffix(proposal.id);
    if (!proposal.id.startsWith(expectedPrefix) || suffix < 31 || suffix > 60) {
      throw new Error(`Proposal ID must match category and range 031-060: ${proposal.id}`);
    }
    for (const language of ["en", "es"]) {
      const text = proposal[language];
      if (typeof text !== "string" || text !== text.trim()) {
        throw new Error(`Invalid ${language} text in ${proposal.id}`);
      }
      if (text.length < 32 || text.length > 138) {
        throw new Error(`${proposal.id}/${language} must contain 32-138 characters; found ${text.length}`);
      }
    }
  }
  for (const category of categories) {
    const actual = proposals
      .filter((proposal) => proposal.category === category)
      .map((proposal) => proposal.id)
      .sort((left, right) => numericSuffix(left) - numericSuffix(right));
    const expected = Array.from(
      { length: 30 },
      (_, index) => `${category}-${String(index + 31).padStart(3, "0")}`,
    );
    if (actual.some((id, index) => id !== expected[index])) {
      throw new Error(`${category} proposals must contain every ID from 031 to 060`);
    }
  }
}

function integrateLanguage({ language, exportName, fileName }) {
  const filePath = path.join(root, "data", fileName);
  const existing = readExportedArray(filePath, exportName)
    .filter((quote) => numericSuffix(quote.id) <= 30);
  const additions = proposals.map((proposal) => ({
    id: proposal.id,
    category: proposal.category,
    text: proposal[language],
  }));
  const quotes = [...existing, ...additions].sort((left, right) => {
    const categoryDifference = categoryOrder.get(left.category) - categoryOrder.get(right.category);
    return categoryDifference || numericSuffix(left.id) - numericSuffix(right.id);
  });
  if (quotes.length !== categories.length * 60) {
    throw new Error(`${language} catalog should contain 720 quotes; found ${quotes.length}`);
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
