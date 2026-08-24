# Warm Words 1.0 — Data and permission inventory

Audit date: **2026-08-24**

Release baseline: **iOS 1.0 build 25**, source commit `bdec7a0`, signed and inspected in run `32751996787`, accepted by Apple, processed as `VALID`, and assigned to the internal TestFlight group by run `32753132327`. The smart-link receiver exists in source, but its public-link feature gate is off, Associated Domains is not signed into the target, and this build shares an image only.

Scope: the iPhone target in `native-ios/`; no Android statement is made here.

## Result

The target uses Apple frameworks only: Foundation, SwiftUI, UIKit, and UserNotifications. It has no package dependencies or third-party SDKs, makes no direct network request, and has no account, backend, analytics, crash-reporting SDK, advertising, tracking, StoreKit purchase, cloud synchronization, or remote push service.

The app does not collect data for the developer. It handles a small set of app preferences and user-created content locally on the iPhone. The only protected permission it requests is notifications, and it requests that permission only after an explicit reminder or test-notification action.

## Local information

| Information | Why it exists | Storage | Transmission | Retention and control |
|---|---|---|---|---|
| Language choice | Show English or Spanish | `UserDefaults` | None | Persists until changed, reset, or the app is removed |
| Selected category and delivery categories | Filter visible quotes and reminder content | `UserDefaults` | None | Persists until changed, reset, or the app is removed |
| Favorite quote IDs | Restore favorites | `UserDefaults` | None | Removed when unfavorited, cleaned if orphaned, or removed with the app |
| Reminder enabled state, time, weekdays, and onboarding completion | Create the schedule chosen by the user | `UserDefaults` | None | Persists until changed, disabled, reset, or the app is removed |
| Personal quotes and legacy personal-category records | Provide user-authored local content without data loss | JSON encoded in `UserDefaults` | Only as pixels inside the quote-card image when the user explicitly chooses a share destination | Individual quotes can be deleted; remaining records persist until deletion or app removal |
| Quote-cycle history, today's assignment, and future local-notification assignments | Avoid repeating eligible quotes until the selected pool is exhausted and keep Today aligned with local reminders | IDs and dates encoded in `UserDefaults` | None | Cleaned when quotes disappear; otherwise persists until app removal and is updated as the cycle advances |
| iPhone preferred language | Choose the initial interface language on a clean install | Read from iOS in memory | None | Not copied to a server or separate profile |

The privacy manifest declares `NSPrivacyAccessedAPICategoryUserDefaults` with required reason `CA92.1`, tracking false, and no collected data types.

## Permissions and system surfaces

| Capability | Requested or used | Minimum behavior |
|---|---|---|
| Notifications | Yes, local notifications only | Authorization is requested only after the user chooses Set reminder, Save reminder, or a test notification. Denial leaves reminders off and the user can manage access in iOS Settings. |
| Share sheet | Yes, after tapping Share | Warm Words renders a quote-card image and hands that image to the iOS share sheet. The chosen destination receives it under its own privacy terms; Warm Words receives no destination or recipient information. |
| Universal Link and custom URL scheme | Not active in this candidate | Receiver and payload-validation code exist, but the public-link flag is off, the public landing is 404, and Associated Domains is not linked into the signed target. No URL is added to the share sheet in build 25. |
| Location, camera, microphone, photos, contacts, calendars, health, Bluetooth, local network, motion, speech, Face ID | No | No purpose strings, entitlements, or prompts should be added for 1.0. |
| Remote notifications/background push | No | No APNs token, server, or push entitlement. |

## App Store privacy answers for this build

- **Data used to track the user:** No.
- **Data collected by the developer:** No. A third-party destination selected by the user receives the image the user deliberately shares; that user-directed transfer is not developer collection and is described in the public policy.
- **Third-party SDK disclosure:** None present.
- **Privacy choices URL:** Leave blank; there is no developer-held data or account privacy-control flow.
- **Account deletion:** Not applicable; the app has no account.
- **Advertising identifier / tracking authorization:** Not used or requested.
- **Purchases:** None; the build contains no StoreKit products or supporter subscription.
- **Encryption:** `ITSAppUsesNonExemptEncryption=false`; recheck if networking or cryptographic code is added.
- **Terms / EULA:** Use Apple's standard Licensed Application End User License Agreement. No custom terms URL or agreement is needed for this build.

TestFlight itself is an Apple distribution service. Apple may handle tester installation, crash, and voluntarily submitted feedback data under Apple's TestFlight terms; Warm Words does not embed a separate telemetry SDK for this.

## Public and private information boundary

Public 1.0 material should contain only:

- the Warm Words product identity and accurate feature description;
- a dedicated privacy page;
- a dedicated support page with a dedicated support alias; and
- the legally required copyright and, only if applicable, DSA trader disclosures.

Do not publish the repository, public issue tracker, owner's personal accounts, full name, home address, personal phone, or personal email as product support information. App Review contact details belong only in Apple's private review fields and must contain the minimum real values Apple requires. Optional marketing and privacy-choices URLs remain empty.

## Verified discrepancies and release gates

1. `https://krazel.github.io/warm-words/privacy/`, `/support/`, and `/share/` still returned HTTP 404 on 2026-08-24. They cannot be used as final App Store URLs or as a smart-link fallback.
2. Read-only inspection of App Store Connect on 2026-08-24 confirmed that the English and Spanish versions still use GitHub Issues as Support URL and the privacy field uses a repository-file URL. Marketing URL, copyright, build selection, and all four private App Review contact fields are empty. Replace the public URLs only after the dedicated pages and alias are live and tested; fill the required private review fields only when preparing an authorized submission.
3. A dedicated support email alias does not yet exist in the repository record. Create and test it without exposing a personal address.
4. App Store Privacy currently shows “No data collected,” no privacy-choices URL, and an available Publish action, confirming it remains unpublished. The answer is substantively correct for this candidate but must be rechecked against the signed archive before publication.
5. App Store Connect currently records the developer as a **trader for this app**. If the app is distributed in the EU, Apple requires the verified trader contact information to appear on the product page; confirm that the already supplied facts remain correct rather than changing or omitting the classification.
6. Re-run this inventory against the exact build selected for App Review whenever code, SDKs, permissions, sharing, monetization, or network behavior changes.

## Evidence reviewed

- `native-ios/project.yml`
- `native-ios/Resources/Info.plist`
- `native-ios/Resources/PrivacyInfo.xcprivacy`
- `native-ios/InspiracionDia.entitlements`
- all Swift sources and tests under `native-ios/Sources/` and `native-ios/Tests/`
- signed build 20 inspection and Apple validation recorded in `docs/release/TESTFLIGHT_PREP.md`
- current privacy, support, metadata, QA, status, and decision documents
- live HTTP status of the planned public privacy and support routes on 2026-08-11
