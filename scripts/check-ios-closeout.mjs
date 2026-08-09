import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";

const read = (path) => readFileSync(path, "utf8");
const spanish = JSON.parse(read("native-ios/Resources/content.json"));
const english = JSON.parse(read("native-ios/Resources/content-en.json"));
const swift = read("native-ios/Sources/InspiracionDiaApp.swift");
const logic = read("native-ios/Sources/AppLogic.swift");
const info = read("native-ios/Resources/Info.plist");
const privacy = read("native-ios/Resources/PrivacyInfo.xcprivacy");
const project = read("native-ios/project.yml");
const workflow = read(".github/workflows/build-ios-unsigned.yml");
const appIconContents = JSON.parse(read("native-ios/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json"));
const appIconRootContents = JSON.parse(read("native-ios/Resources/Assets.xcassets/Contents.json"));
const appIconEntry = appIconContents.images.find(
  ({ idiom, platform, size }) => idiom === "universal" && platform === "ios" && size === "1024x1024",
);
assert.ok(appIconEntry?.filename, "AppIcon catalog must define a universal iOS 1024x1024 image");
const appIconPath = `native-ios/Resources/Assets.xcassets/AppIcon.appiconset/${appIconEntry.filename}`;
assert.ok(existsSync(appIconPath), `AppIcon image is missing: ${appIconPath}`);

const png = readFileSync(appIconPath);
const pngSignature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
assert.ok(png.subarray(0, 8).equals(pngSignature), "AppIcon must be a PNG image");
assert.equal(png.readUInt32BE(16), 1024, "AppIcon width must be 1024 pixels");
assert.equal(png.readUInt32BE(20), 1024, "AppIcon height must be 1024 pixels");
assert.equal(png[25], 2, "AppIcon must use opaque truecolor RGB without an alpha channel");
for (let offset = 8; offset + 12 <= png.length;) {
  const chunkLength = png.readUInt32BE(offset);
  const chunkType = png.toString("ascii", offset + 4, offset + 8);
  assert.notEqual(chunkType, "tRNS", "AppIcon must not define PNG transparency");
  offset += chunkLength + 12;
}
assert.equal(appIconRootContents.info?.author, "xcode");
assert.equal(appIconRootContents.info?.version, 1);

assert.equal(spanish.quotes.length, 180, "Spanish legacy catalog must remain complete");
assert.equal(english.quotes.length, 180, "English release catalog must contain 180 quotes");
assert.deepEqual(
  english.quotes.map(({ id }) => id),
  spanish.quotes.map(({ id }) => id),
  "English and Spanish quote IDs must match in order",
);
assert.deepEqual(
  english.categories.map(({ id }) => id),
  spanish.categories.map(({ id }) => id),
  "English and Spanish category IDs must match in order",
);

assert.match(swift, /url\(forResource: "content-en", withExtension: "json"\)/);
assert.match(swift, /static let name = "Warm Words"/);
assert.doesNotMatch(swift, /static let name = "Inspiracion Dia"/);
assert.match(swift, /Strings\.value\(key, language: "en"\)/);
assert.match(swift, /Locale\(identifier: "en_US"\)/);
assert.doesNotMatch(swift, /store\.language|setLanguage\(|Picker\(store\.t\("language"\)/);
assert.match(swift, /scheduledReminderCount = 60/);
assert.match(swift, /UNCalendarNotificationTrigger\(dateMatching: date, repeats: false\)/);
assert.doesNotMatch(swift, /UNCalendarNotificationTrigger\([^\n]*repeats: true/);
assert.match(swift, /@MainActor\s*\nfinal class AppStore/);
assert.match(swift, /pendingNotificationRequests\(\)/);
assert.doesNotMatch(swift, /DispatchGroup|NSLock|DispatchQueue\.main/);
assert.match(swift, /reminderSchedulingTask: Task<Void, Never>/);
assert.match(swift, /replaceReminderSchedulingTask/);
assert.match(swift, /func addCustomQuote\([\s\S]*newCategoryName: String\? = nil/);
assert.match(swift, /func deleteCustomQuote\(_ quote: Quote\)/);
assert.match(swift, /reminderWeekdays = ReminderWeekdays\.all/);
assert.match(swift, /reminderOnboardingVersion/);
assert.match(swift, /func completeInitialReminderSetup/);
assert.match(swift, /func saveReminderSettings/);
assert.match(swift, /struct ReminderOnboardingView/);
assert.match(swift, /if store\.needsReminderOnboarding/);
assert.match(swift, /struct WeekdayPicker/);
assert.match(swift, /deliveryUsesAllCategories/);
assert.match(swift, /customCategories: \[Category\]/);
assert.match(swift, /func isCustomCategory/);
assert.match(swift, /Create a new category…/);
assert.match(swift, /let minimumHeight: CGFloat = dynamicTypeSize\.isAccessibilitySize \? 430 : 330/);
assert.match(swift, /identifier: "test-inspiration"/);
assert.match(swift, /notificationPermissionAlertPending = true/);
assert.match(swift, /ScrollView \{\s*VStack\(alignment: \.leading, spacing: 18\)/);
assert.doesNotMatch(swift, /FeatureStrip|Thoughtful quotes|Easy to share|One each day|Explore categories/);
assert.match(swift, /DatePicker\(/);
assert.doesNotMatch(swift, /TextField\("07:30"/);
assert.match(logic, /enum DailyQuoteSelector/);
assert.match(logic, /enum ReminderTimeCodec/);
assert.match(logic, /enum ReminderWeekday/);
assert.match(logic, /weekdays: Set<ReminderWeekday>/);
assert.match(logic, /enum CustomCategoryValidator/);
assert.match(logic, /enum CustomQuoteValidator[\s\S]*maximumLength = 240/);

assert.match(privacy, /NSPrivacyAccessedAPICategoryUserDefaults/);
assert.match(privacy, /CA92\.1/);
assert.match(privacy, /<key>NSPrivacyTracking<\/key>\s*<false\s*\/>/);
assert.match(info, /<key>CFBundleDevelopmentRegion<\/key>\s*<string>en<\/string>/);
assert.match(info, /<key>CFBundleDisplayName<\/key>\s*<string>Warm Words<\/string>/);
assert.match(info, /<key>CFBundleName<\/key>\s*<string>Warm Words<\/string>/);
assert.match(info, /<key>ITSAppUsesNonExemptEncryption<\/key>\s*<false\s*\/>/);
assert.doesNotMatch(info, /NSUserNotificationsUsageDescription|UISupportedInterfaceOrientations~ipad/);

assert.match(project, /DEVELOPMENT_LANGUAGE: en/);
assert.match(project, /SWIFT_VERSION: "5\.0"/);
assert.doesNotMatch(project, /SWIFT_VERSION: "5\.9"/);
assert.match(project, /TARGETED_DEVICE_FAMILY: "1"/);
assert.match(project, /CODE_SIGN_STYLE: Automatic/);
assert.match(project, /ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon/);
assert.match(project, /InspiracionDiaTests:/);
assert.match(project, /PRODUCT_BUNDLE_IDENTIFIER: com\.dmkr\.inspiraciondia\.tests/);
assert.match(workflow, /permissions:\s*\n\s*contents: read/);
assert.match(workflow, /runs-on: macos-26/);
assert.match(workflow, /xcodebuild[\s\S]*test/);
assert.match(workflow, /content-en\.json PrivacyInfo\.xcprivacy/);
assert.match(workflow, /DISPLAY_NAME[\s\S]*Warm Words/);
assert.match(workflow, /CFBundleIconName[\s\S]*AppIcon/);
assert.match(workflow, /Assets\.car/);
assert.doesNotMatch(workflow, /contents: write|gh release|Publish latest IPA release/);

console.log("iOS closeout checks passed (signing, Apple QA and store delivery remain external gates).")
