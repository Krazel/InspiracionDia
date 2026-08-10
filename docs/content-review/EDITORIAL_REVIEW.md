# Warm Words bilingual editorial review

Date: 2026-08-10

## Result

- 360 original English/Spanish quote pairs across 12 categories.
- 30 pairs per category, with parallel IDs from `001` through `030`.
- 180 new pairs were added after two independent category reviews and a final integration review.
- 12 weaker existing pairs were rewritten in place, preserving their IDs so saved favorites and references survive an update.
- No famous quotations, author attributions, scraped text, medical promises, or external quote collections were introduced.
- Personal quotes remain user data and are not part of this catalog.

## Quality gate

Every catalog update must pass `scripts/check-quotes.mjs`. The validator requires:

- exact English/Spanish ID and category parity;
- exactly 30 quotes in every category;
- stable ordered IDs;
- 32–138 characters per language;
- no exact or normalization-only duplicates;
- no high-overlap near duplicates;
- only known categories.

Automated checks do not decide whether writing is good. New content also requires a bilingual editorial pass for natural language, useful specificity, category fit, tone, and accidental cliché before integration.

## Source trail

- `draft-a.json`: Motivation, Focus, Calm, Discipline, Self-worth, Gratitude.
- `draft-b.json`: Courage, Habits, Creativity, Resilience, Relationships, Energy.
- `scripts/integrate-reviewed-quotes.mjs`: deterministic merge that preserves existing IDs, applies approved rewrites, adds IDs `016–030`, and refuses an incomplete category.
- `data/quotes.js` and `data/quotes-en.js`: canonical production sources.
- `native-ios/Resources/content.json` and `content-en.json`: generated runtime resources.
