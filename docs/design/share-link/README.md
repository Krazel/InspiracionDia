# Shared quote — approved contract

Canonical screen: `warm-words-shared-personal-quote-approved.png` (`WW-SCREEN-004` in `design/APPROVALS.md`).

- The screen opens only from a validated Warm Words share link.
- It shows the exact bundled quote selected by stable ID, or the literal normalized personal quote carried in the URL fragment.
- A personal quote is not imported automatically. `Save to Personal & Favorites` deduplicates it, stores one local Personal quote, and marks it favorite.
- A bundled quote uses `Save to Favorites` and keeps its catalog ID across English and Spanish.
- `Not now` and the close button make no data change.
- Invalid, unknown, unsupported, or oversized payloads show localized feedback and never create content.
- The reference is English; Spanish localizes controls and category labels without translating received personal text.
- The runtime reuses `premium-mountains.png`; this mockup is documentation and is not bundled as an app resource.
