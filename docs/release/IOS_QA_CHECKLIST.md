# iOS 1.0 candidate verification

This checklist is for the first signed English iPhone build. It does not authorize an upload, TestFlight distribution, App Review submission, or release.

## Build gate — macOS with Xcode 26+

- [ ] Record `xcodebuild -version` and `xcrun --sdk iphoneos --show-sdk-version`; iOS SDK must be 26 or later.
- [ ] Run `node scripts/check-quotes.mjs`.
- [ ] Regenerate both JSON resources with the two export scripts.
- [ ] Run `node scripts/check-ios-closeout.mjs`.
- [ ] Generate the project from `native-ios/project.yml` with XcodeGen.
- [ ] Run the `InspiracionDia` unit-test scheme on an iPhone simulator.
- [ ] Build Debug and Release with no warnings that indicate a runtime, concurrency, signing, asset, or privacy problem.
- [ ] Confirm the built `.app` contains `content-en.json`, legacy `content.json`, `PrivacyInfo.xcprivacy`, both premium backgrounds, and an `Assets.car` compiled from the approved C — Protected thought AppIcon.
- [ ] Confirm the built Info.plist has `Warm Words` as both display and bundle name, `AppIcon` as the primary icon name, version 1.0, the intended bundle ID, iPhone-only device family, and the expected encryption declaration.
- [ ] Archive with automatic signing and the owner's selected team.
- [ ] Run Analyze and Validate App; record every warning and resolution.

## Clean-install gate — physical iPhone

Use at least one device on the minimum supported iOS 16 release and one on the current iOS 26 release when those devices are available.

- [ ] Clean install opens without a crash, blank state, or Spanish public copy.
- [ ] Clean install shows one-screen reminder setup with 07:30 and all seven days selected; no notification prompt appears before Set reminder.
- [ ] Not now completes onboarding, leaves reminders off, and does not ask for permission.
- [ ] `Warm Words` and the approved C — Protected thought icon are correct on the Home Screen, Spotlight/Search, notifications, share sheet, and system settings.
- [ ] The icon remains clear at small sizes and in default, dark, tinted, and clear system presentations on iOS 16 and iOS 26 where each presentation is available.
- [ ] Today shows a valid English date, quote, and category.
- [ ] Today shows the complete quote card, favorite/share actions, and tab bar without scrolling at the default text size on the smallest supported iPhone.
- [ ] Tomorrow/date override selects the next deterministic quote and the sequence crosses year end without resetting.
- [ ] All 12 categories open and together expose 180 unique English quotes.
- [ ] Save and unsave work from Today, Categories, and Favorites and survive relaunch.
- [ ] Sharing from Today and a list opens the iOS share sheet with the correct quote and `Warm Words`.
- [ ] A whitespace-only personal quote cannot be added.
- [ ] A personal quote over 240 characters is rejected with a visible counter/error and the sheet remains usable with the keyboard open.
- [ ] A valid personal quote is trimmed, saved, shown under Personal, and survives relaunch.
- [ ] A personal category can be created with its first quote, appears in Categories, and survives relaunch.
- [ ] Empty, duplicate, reserved, over-24-character, and thirteenth personal-category names are rejected without leaving an empty category.
- [ ] A personal quote shares through the standard iOS share sheet as its text followed by `Warm Words`.
- [ ] Deleting the last quote in a personal category warns that the category will also be removed, then removes the empty category and any reminder-category reference.
- [ ] Deleting a personal quote requires confirmation, removes it from favorites, and survives relaunch.
- [ ] Existing valid legacy favorites and personal quotes survive an upgrade install.

## Notification gate

- [ ] Set reminder in onboarding or Save reminder in Settings is the first action that asks for permission; clean launch and draft edits do not ask.
- [ ] Allow: 60 future local occurrences are created without errors and only on the selected weekdays.
- [ ] Deny: the app stays usable, disables the setting, and shows clear feedback.
- [ ] Test notification appears while the app is foregrounded and in the background.
- [ ] Scheduled notification has an English title and the expected quote.
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
- [ ] Public privacy and support pages use the approved name and real contact information.
- [ ] App Privacy answers match the final archive and third-party component scan.
- [ ] Required-reason API report contains only declared uses or is reconciled.
- [ ] Updated age-rating questionnaire, category, copyright, territories, price, DSA status, and manual release mode are complete.
- [ ] Five English portrait screenshots are captured from the verified signed build at an accepted 6.9-inch size.
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
