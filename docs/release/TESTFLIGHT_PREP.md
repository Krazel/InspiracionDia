# Warm Words 1.0 — TestFlight preparation

Status: the repository is prepared to build a signed candidate, but no signed archive has been produced and nothing has been uploaded to TestFlight. Upload remains an explicitly authorized action at the moment it is run.

## Verified release identity

- App Store Connect Apple ID: `6800058458`
- Bundle ID: `com.dmkr.inspiraciondia`
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
2. Accepts a positive, unique build number; use `18` or the next unused number in App Store Connect.
3. Runs content validation, XcodeGen, and XCTest before signing.
4. Validates the distribution profile's Team ID and bundle ID.
5. Archives and exports an `app-store-connect` IPA with Apple Distribution signing.
6. Verifies the signature, version, bundle, privacy manifest, catalogs, and compiled assets.
7. Stores the signed IPA for three days.
8. Uploads only when `upload_to_testflight` is explicitly set to `true` after authorization.

The workflow has not been run because the protected environment and credentials are not configured yet.

## Protected GitHub environment

Create an environment named `app-store-production`, restrict it to `main` and `agent/warm-words-ios-ipa`, and require approval before access. Store only these values there:

- `BUILD_CERTIFICATE_BASE64`: Apple Distribution `.p12`, base64 encoded.
- `P12_PASSWORD`: password for that `.p12`.
- `BUILD_PROVISION_PROFILE_BASE64`: App Store distribution profile for `com.dmkr.inspiraciondia`, base64 encoded.
- `KEYCHAIN_PASSWORD`: random temporary CI keychain password.
- `APP_STORE_CONNECT_API_KEY_ID`: required only for upload.
- `APP_STORE_CONNECT_ISSUER_ID`: required only for upload.
- `APP_STORE_CONNECT_API_KEY_BASE64`: private `.p8`, base64 encoded; required only for upload.

Do not put these values in repository secrets, source files, logs, artifacts, issue comments, or documentation. Creating credentials, adding secrets, or running the upload step requires explicit authorization at that moment.

## Candidate sequence

1. Finish the bilingual content and run all local validators.
2. Complete a new unsigned macOS CI build and physical regression pass, especially Settings, Today, categories, reminders, language switching, favorites, Personal, and visual sharing.
3. Confirm ownership or commercial license for `premium-mountains.png`, `premium-stones.png`, and the AppIcon; keep the editorial provenance note for all bundled quotes.
4. Configure the protected signing environment.
5. Run the manual workflow with upload set to `false`; inspect the archive/IPA and resolve every signing or export warning.
6. Complete device QA using the signed candidate and record the result in `IOS_QA_CHECKLIST.md`.
7. With a separate explicit authorization, run the same verified commit/build with upload set to `true`.
8. Wait for Apple processing, answer export-compliance prompts consistently, and assign the build to internal testers first.

## Remaining release gates

- Dedicated public privacy and support pages under `https://krazel.github.io/warm-words/` do not exist yet; the private store record currently uses provisional GitHub URLs.
- Smart sharing remains disabled until the public landing and AASA file exist, the app has the Associated Domains entitlement, and the signed profile supports it. The landing must fall back to `https://apps.apple.com/app/id6800058458`.
- English and Spanish App Store screenshots must come from the final signed build.
- Copyright, App Review contact, DSA confirmation, final privacy publication, build selection, and owner review remain incomplete.
- Optional supporter subscriptions remain outside 1.0 until real App Store products, localized prices, restore purchases, terms, privacy, and review configuration are explicitly authorized.

## Prepared TestFlight copy

English beta description:

> Warm Words is a bilingual daily quote app for iPhone. Browse 360 original quotes, save favorites, add personal quotes, share visual cards, and configure gentle local reminders for the days and time you choose.

English “What to Test”:

> Please test first-launch reminder setup; opening, closing, and reopening Settings; English/Spanish switching and persistence; Today without scrolling at standard text sizes; all category cards and the Habits icon; favorites; adding and deleting a Personal quote; notification allow/deny and scheduling; and visual quote sharing through WhatsApp or another share extension.

Spanish beta description:

> Warm Words es una app bilingüe de frases diarias para iPhone. Explora 360 frases originales, guarda favoritas, añade frases personales, comparte tarjetas visuales y configura recordatorios locales para los días y la hora que elijas.

Spanish “Qué probar”:

> Prueba la configuración inicial del recordatorio; abrir, cerrar y volver a abrir Ajustes; el cambio y la persistencia de inglés/español; Today sin desplazamiento con texto estándar; todas las tarjetas de categoría y el icono de Hábitos; favoritos; añadir y eliminar una frase Personal; permitir o denegar notificaciones y su programación; y compartir una tarjeta visual por WhatsApp u otra extensión.

The feedback email and Beta App Review contact fields remain empty because they require the owner's real contact details and must not be invented.

References: Apple documents that uploaded builds are associated using bundle ID, version, and a unique build string, and must finish processing before appearing in TestFlight. GitHub environments should gate access to signing and upload secrets.
