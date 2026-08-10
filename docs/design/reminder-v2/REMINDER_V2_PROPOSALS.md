# Warm Words — reminder and personal-category visual proposals

Date: 2026-08-09
Status: **complete set approved for implementation**

These complete-screen proposals were generated with the built-in image-generation tool. They define one coherent direction using the existing ivory, cream, antique-gold and ink visual language. They are references only and are not runtime assets. Their English copy is historical; the approved runtime now applies the same layout in English and Spanish.

## Recommended set

1. `warm-words-today-compact-proposal.png`
   - Today fits without scrolling.
   - Removes the promotional strip and Explore categories.
   - Reduces hero height and empty internal space while preserving the existing quote, favorite and share experience.
2. `warm-words-onboarding-proposal.png`
   - One-screen first launch asking for time and days.
   - 07:30 and all seven days are selected by default; every day is recommended.
   - Notification permission is requested only after Set reminder.
3. `warm-words-settings-proposal.png`
   - Reminder toggle, time, days and quote categories are edited as one draft.
   - Save reminder applies the changes once; All categories is recommended.
4. `warm-words-new-category-proposal.png`
   - New personal quote remains one sheet.
   - Choosing Create a new category reveals a 24-character name field and creates the category with its first quote.

## Sharing scope

Personal quotes already use the normal iOS Share sheet as text followed by `Warm Words`. This simple local sharing remains the recommendation. There is no account, server, import flow or image-card generator in this scope.

## Approval record

- Selected direction: **complete recommended set — Today compact, onboarding, Settings and inline new category**
- Approval date: **2026-08-09**
- Requested changes: **none**
- Owner refinement, 2026-08-10: the Today quote surface must read as a narrow portrait card rather than a square. Runtime target: 276 pt maximum width × 330 pt minimum height at normal Dynamic Type, centered; accessibility sizes may use the available width and grow vertically.
- Continuing authority: the owner explicitly authorized any additional image needed to finish this scope without another approval round.
- Implementation rule: preserve the approved hierarchy, palette and compact behavior while adapting controls for accessibility and real SwiftUI constraints.

## Prompt summaries

- Today: complete compact portrait screen, existing premium landscape card, balanced 320–340pt hero, actions and tab bar visible without scrolling, no promotional copy.
- Onboarding: one quiet cream card with 07:30 time wheel, seven selected weekday chips, Set reminder and Not now.
- Settings: single reminder editor with toggle, compact time, seven selected days, All categories, one save action, test and preview.
- New category: existing personal-quote sheet expanded inline with Create a new category, name field and Add quote.

All prompts required English-only text, accessible target sizing, no new colors, no account or cloud UI, no watermark and no device frame.
