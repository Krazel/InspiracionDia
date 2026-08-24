# Warm Words 1.0 — TestFlight preparation

Status: version 1.0 build 26 was signed, validated, uploaded, processed by Apple, and assigned to the internal group `Warm Words Internal` on 2026-08-24. It is the latest TestFlight build and contains 720 quotes per language. App Review and public release remain separate unauthorized actions.

## Verified release identity

- App Store Connect Apple ID: `6800058458`
- Bundle ID: `com.dmkr.inspiraciondia.B2X6D3A9J9`
- Apple Team ID: `B2X6D3A9J9`
- Version: `1.0`
- Platform: iPhone only, portrait, iOS 16+
- Primary App Store localization: English (U.S.)
- Additional localization: Spanish (Spain)
- On-device name: `Warm Words`
- App Store names: `Warm Words: Daily Quotes` / `Warm Words: Frases Diarias`
- Monetization in this candidate: free, no ads, no purchases, no StoreKit products

## Manual workflow

`.github/workflows/build-ios-testflight.yml` is deliberately separate from normal unsigned CI. It:

1. Runs only through `workflow_dispatch` and only for the repository owner.
2. Accepts a positive, unique build number; build `20` is the first uploaded TestFlight build.
3. Runs content validation, XcodeGen, and XCTest before signing.
4. Validates the distribution profile's Team ID and bundle ID.
5. Archives and exports an `app-store-connect` IPA with Apple Distribution signing.
6. Verifies the signature, version, bundle, privacy manifest, catalogs, and compiled assets.
7. Stores the signed IPA for three days.
8. Uploads only when `upload_to_testflight` is explicitly set to `true` after authorization.

The protected environment and seven credentials are configured. Run `31429710903`, job `93589855913`, completed all tests, Analyze, signed archive inspection, export, validation, and upload from commit `423da40`.

## Protected GitHub environment

The environment `app-store-production` exists and is restricted to `agent/warm-words-ios-ipa`. It stores only these values:

- `BUILD_CERTIFICATE_BASE64`: Apple Distribution `.p12`, base64 encoded.
- `P12_PASSWORD`: password for that `.p12`.
- `BUILD_PROVISION_PROFILE_BASE64`: App Store distribution profile for `com.dmkr.inspiraciondia.B2X6D3A9J9`, base64 encoded.
- `KEYCHAIN_PASSWORD`: random temporary CI keychain password.
- `APP_STORE_CONNECT_API_KEY_ID`: required only for upload.
- `APP_STORE_CONNECT_ISSUER_ID`: required only for upload.
- `APP_STORE_CONNECT_API_KEY_BASE64`: private `.p8`, base64 encoded; required only for upload.

Do not put these values in repository secrets, source files, logs, artifacts, issue comments, or documentation. Creating credentials, adding secrets, or running the upload step requires explicit authorization at that moment.

## Completed TestFlight sequence

1. The bilingual catalog and local validators passed.
2. The unsigned macOS build, XCTest, and Release build passed.
3. Apple Distribution signing, the App Store profile, and the protected GitHub environment were configured after explicit authorization.
4. Build 20 passed XCTest, Analyze, archive inspection, `codesign`, App Store export, and Apple validation.
5. Apple processed the upload and exposed build 20 for internal testing.
6. `Warm Words Internal` was created with automatic future distribution disabled; build 20 and the account owner were added manually.

## Remaining release gates

- Dedicated public privacy and support pages under `https://krazel.github.io/warm-words/` returned 404 on 2026-08-11; the private store record still uses provisional GitHub URLs. Replace them only after the dedicated pages and support alias are live, and do not expose the repository or personal contact details.
- Smart sharing remains disabled until the public landing and AASA file exist, the app has the Associated Domains entitlement, and the signed profile supports it. The landing must fall back to `https://apps.apple.com/app/id6800058458`.
- English and Spanish App Store screenshots must come from the final signed build.
- Copyright, private App Review contact, truthful DSA confirmation, final privacy publication, build selection, and owner review remain incomplete. Optional public fields stay empty unless required.
- Optional supporter subscriptions remain outside 1.0 until real App Store products, localized prices, restore purchases, terms, privacy, and review configuration are explicitly authorized.

## Prepared TestFlight copy

English beta description:

> Warm Words is a bilingual daily quote app for iPhone. Browse 720 original quotes, save favorites, add personal quotes, share visual cards, and configure gentle local reminders for the days and time you choose.

English “What to Test”:

> Please test first-launch reminder setup; opening, closing, and reopening Settings; English/Spanish switching and persistence; Today without scrolling at standard text sizes; all category cards and the Habits icon; favorites; adding and deleting a Personal quote; notification allow/deny and scheduling; and visual quote sharing through WhatsApp or another share extension.

Spanish beta description:

> Warm Words es una app bilingüe de frases diarias para iPhone. Explora 720 frases originales, guarda favoritas, añade frases personales, comparte tarjetas visuales y configura recordatorios locales para los días y la hora que elijas.

Spanish “Qué probar”:

> Prueba la configuración inicial del recordatorio; abrir, cerrar y volver a abrir Ajustes; el cambio y la persistencia de inglés/español; Today sin desplazamiento con texto estándar; todas las tarjetas de categoría y el icono de Hábitos; favoritos; añadir y eliminar una frase Personal; permitir o denegar notificaciones y su programación; y compartir una tarjeta visual por WhatsApp u otra extensión.

The feedback email and Beta App Review contact fields remain empty because they require accurate contact details and must not be invented. A dedicated support alias belongs on public support material; the minimum real App Review contact belongs only in Apple's private review fields.

References: Apple documents that uploaded builds are associated using bundle ID, version, and a unique build string, and must finish processing before appearing in TestFlight. GitHub environments should gate access to signing and upload secrets.
