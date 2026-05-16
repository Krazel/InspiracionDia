import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const categories = readExportedArray(path.join(root, "data", "categories.js"), "CATEGORIES")
  .filter((category) => category.id !== "hoy");
const quotes = readExportedArray(path.join(root, "data", "quotes.js"), "QUOTES");

const outPath = path.join(root, "native-ios", "Resources", "content.json");
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, JSON.stringify({ categories, quotes }, null, 2), "utf8");
console.log(`Exported ${quotes.length} quotes to ${outPath}`);

function readExportedArray(filePath, name) {
  const source = fs.readFileSync(filePath, "utf8");
  const marker = `export const ${name} = `;
  const start = source.indexOf(marker);
  if (start === -1) throw new Error(`No se encontro ${name} en ${filePath}`);
  const body = source.slice(start + marker.length).trim().replace(/;$/, "");
  return Function(`"use strict"; return (${body});`)();
}
