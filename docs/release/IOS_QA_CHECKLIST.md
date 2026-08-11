# iOS 1.0 candidate verification

This checklist is for the first signed bilingual English/Spanish iPhone build. It does not authorize an upload, TestFlight distribution, App Review submission, or release.

## Build gate — macOS with Xcode 26+

- [ ] Record `xcodebuild -version` and `xcrun --sdk iphoneos --show-sdk-version`; iOS SDK must be 26 or later.
- [ ] Run `node scripts/check-quotes.mjs`.
- [ ] Regenerate both JSON resources with the two export scripts.
- [ ] Run `node scripts/check-ios-closeout.mjs`.
- [ ] Generate the project from `native-ios/project.yml` with XcodeGen.
- [ ] Run the `InspiracionDia` unit-test scheme on an iPhone simulator.
- [ ] Build Debug and Release with no warnings that indicate a runtime, concurrency, signing, asset, or privacy problem.
- [ ] Confirm the built `.app` contains the active English `content-en.json` and Spanish `content.json` catalogs, `PrivacyInfo.xcprivacy`, both premium backgrounds, and an `Assets.car` compiled from the approved C — Protected thought AppIcon.
- [ ] Confirm the built Info.plist declares both `en` and `es` in `CFBundleLocalizations`.
- [ ] Confirm the built Info.plist has `Warm Words` as both display and bundle name, `AppIcon` as the primary icon name, version 1.0, the intended bundle ID, iPhone-only device family, and the expected encryption declaration.
- [ ] Archive with the manual TestFlight workflow, Apple Distribution signing, the matching App Store profile, and Team `B2X6D3A9J9`.
- [ ] Run Analyze and Validate App; record every warning and resolution.

## Clean-install gate — physical iPhone

Use at least one device on the minimum supported iOS 16 release and one on the current iOS 26 release when those devices are available.

- [ ] Clean install on an iPhone whose preferred language is Spanish opens in Spanish; English and other preferred languages open in English.
- [ ] Clean install in either language opens without a crash, blank state, raw localization key, or mixed-language built-in copy.
- [ ] Clean install shows one-screen reminder setup with 07:30 and all seven days selected; no notification prompt appears before Set reminder.
- [ ] Not now completes onboarding, leaves reminders off, and does not ask for permission.
- [ ] `Warm Words` and the approved C — Protected thought icon are correct on the Home Screen, Spotlight/Search, notifications, share sheet, and system settings.
- [ ] The icon remains clear at small sizes and in default, dark, tinted, and clear system presentations on iOS 16 and iOS 26 where each presentation is available.
- [ ] Today shows a valid date, quote, and category in the selected language.
- [ ] Today shows the complete quote card, favorite/share actions, and tab bar without scrolling at the default text size on the smallest supported iPhone.
- [ ] Tomorrow/date override selects the next deterministic quote and the sequence crosses year end without resetting.
- [ ] All 12 categories open and together expose 360 unique quotes in English and 360 in Spanish.
- [ ] Settings offers `English / Español`; changing it updates the current screen immediately and the choice survives relaunch.
- [ ] Switching English → Spanish → English preserves the current category, bundled favorites, reminder preferences, and personal quotes.
- [ ] Personal quotes remain exactly as written instead of being machine-translated.
- [ ] Dates, day chips, VoiceOver weekday names, onboarding, Settings, Categories, Favorites, dialogs, and validation messages follow the selected language.
- [ ] Save and unsave work from Today, Categories, and Favorites and survive relaunch.
- [ ] Sharing from Today and a list opens the iOS share sheet with a complete visual quote card and `Warm Words` branding.
- [ ] A whitespace-only personal quote cannot be added.
- [ ] A personal quote over 240 characters is rejected with a visible counter/error and the sheet remains usable with the keyboard open.
- [ ] A valid personal quote is trimmed, saved, shown under Personal, and survives relaunch.
- [ ] New personal quotes go directly to Personal; the form does not expose category creation.
- [ ] A personal quote shares through the standard iOS share sheet as a visual quote card.
- [ ] Legacy personal categories and their quotes remain readable after an upgrade, without exposing new category creation.
- [ ] Deleting a personal quote requires confirmation, removes it from favorites, and survives relaunch.
- [ ] Existing valid legacy favorites and personal quotes survive an upgrade install.

## Notification gate

- [ ] Set reminder in onboarding or Save reminder in Settings is the first action that asks for permission; clean launch and draft edits do not ask.
- [ ] Allow: 60 future local occurrences are created without errors and only on the selected weekdays.
- [ ] Deny: the app stays usable, disables the setting, and shows clear feedback.
- [ ] Test notification appears while the app is foregrounded and in the background.
- [ ] Scheduled and test notifications use the selected language and the matching bundled catalog; switching language replaces the owned pending schedule without a new permission prompt.
- [ ] Changing time replaces the owned schedule without touching unrelated notifications.
- [ ] Selecting only Monday creates 60 Monday occurrences; selecting several days never schedules an unselected day.
- [ ] All seven days are the default and clearly recommended; an enabled reminder cannot be saved with zero days.
- [ ] Closing Settings without Save discards toggle, time, day, and category drafts without changing pending requests.
- [ ] Saving rapid time/day/category changes leaves only the final requested schedule.
- [ ] Selecting categories changes the scheduled quote pool; selecting none uses all categories.
- [ ] Changing time zone or returning from inactive refreshes the schedule.
- [ ] Spring-forward and fall-back behavior matches the unit-test policy.
- [ ] Disabling reminders removes only this app's daily reminder requests.

## Accessibility and layout gate

- [ ] VoiceOver reads the settings, save, share, add, category-selection, reminder-selection, and delete controls meaningfully.
- [ ] Selection is conveyed without relying on color alone.
- [ ] Dynamic Type works through the largest accessibility sizes without clipped controls or hidden actions.
- [ ] Bold Text, Button Shapes, Increase Contrast, Reduce Transparency, and Reduce Motion do not break the interface.
- [ ] Portrait layouts are checked on the smallest supported iPhone width and a 6.9-inch iPhone.
- [ ] Text contrast is checked over both bundled backgrounds and category cards.

## Store-material gate

- [ ] Rights to every quote and bundled background are confirmed in writing by the owner.
- [ ] Dedicated public privacy and support pages return 200, use the approved name, and expose only a tested support alias—not a repository, issue tracker, personal account, home address, personal phone, or personal email.
- [ ] The public share landing opens the App Store URL `https://apps.apple.com/app/id6800058458` when the app is not installed.
- [ ] The Universal Link opens Warm Words when installed; the AASA file declares `B2X6D3A9J9.com.dmkr.inspiraciondia.B2X6D3A9J9` and the signed app contains `applinks:krazel.github.io`.
- [ ] `docs/release/DATA_INVENTORY_1_0.md`, public policies, and App Privacy answers match the exact final archive and third-party component scan.
- [ ] Required-reason API report contains only declared uses or is reconciled.
- [ ] The final target requests only notification permission; any new permission, SDK, network request, StoreKit product, analytics, or advertising has been removed or disclosed exactly.
- [ ] Marketing URL, privacy-choices URL, and other optional public fields are blank unless the final build has a verified need for them.
- [ ] The private App Review contact is accurate and is not copied into public support or metadata.
- [ ] Updated age-rating questionnaire, category, copyright, territories, price, DSA status, and manual release mode are complete.
- [ ] Five English portrait screenshots are captured from the verified signed build at an accepted 6.9-inch size.
- [ ] If a Spanish App Store localization is enabled, its metadata and screenshots are prepared from the same verified bilingual build; they are not inferred from the English set.
- [ ] Accessibility Nutrition Label answers reflect the completed device checks.
- [ ] The owner reviews the final candidate.

## Result record

- Build commit: `[COMMIT]`
- Xcode / SDK: `[VERSIONS]`
- Archive version/build: `[VERSION] / [BUILD]`
- Devices / iOS versions: `[DEVICES]`
- Validator result: `[RESULT]`
- Open defects: `[NONE OR LINKS]`
- Owner review date: `[DATE]`
