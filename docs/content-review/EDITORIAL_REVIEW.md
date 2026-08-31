# Warm Words bilingual editorial review

Date: 2026-08-24

## Result

- 720 original English/Spanish quote pairs across 12 categories.
- 60 pairs per category, with parallel IDs from `001` through `060`.
- The owner-approved expansion added 360 new bilingual pairs after category-specific drafting, a second editorial pass, deterministic validation, and a final full-catalog review.
- Sixteen weaker pairs from the earlier audit were rewritten in place while preserving their IDs. The expansion review then improved 55 further pairs: three overlaps caught during integration and 52 items identified by the final independent category audit.
- No famous quotations, author attributions, scraped text, medical promises, diagnoses, or external quote collections were introduced.
- Personal quotes remain user data and are not part of this catalog.

## Quality gate

Every catalog update must pass `scripts/check-quotes.mjs`. The validator requires:

- exact English/Spanish ID and category parity;
- exactly 60 quotes in every category;
- stable ordered IDs;
- 32–138 characters per language;
- no exact or normalization-only duplicates;
- no high-overlap near duplicates;
- only known categories.

Automated checks do not decide whether writing is good. All 720 pairs also received a bilingual editorial pass for natural language, useful specificity, category fit, tone, translation equivalence, accidental cliché, unsafe advice, and semantic repetition.

## Source trail

- `draft-a.json` and `draft-b.json`: reviewed source material for IDs `001–030`.
- `proposals/core-031-060.json`: Motivation, Focus, Calm, and Discipline additions.
- `proposals/growth-031-060.json`: Self-worth, Gratitude, Courage, and Habits additions.
- `proposals/life-031-060.json`: Creativity, Resilience, Relationships, and Energy additions.
- `scripts/integrate-quote-expansion.mjs`: deterministic merge that preserves IDs `001–030`, validates complete proposals, adds IDs `031–060`, and refuses incomplete categories.
- `data/quotes.js` and `data/quotes-en.js`: canonical production sources.
- `native-ios/Resources/content.json` and `content-en.json`: generated runtime resources.
