import Foundation
import SwiftUI
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return true
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    [.banner, .sound]
  }
}

struct Category: Codable, Identifiable, Hashable {
  let id: String
  let name: String
  let color: String
  let softColor: String
  let description: String
}

struct Quote: Codable, Identifiable, Hashable {
  let id: String
  let category: String
  let text: String
}

struct ContentBundle: Codable {
  let categories: [Category]
  let quotes: [Quote]
}

enum AppBrand {
  static let name = "Warm Words"
}

@main
@MainActor
struct InspiracionDiaApp: App {
  @StateObject private var store = AppStore()
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(store)
        .environment(\.locale, Locale(identifier: store.language.localeIdentifier))
    }
  }
}

@MainActor
final class AppStore: ObservableObject {
  @Published private(set) var language: AppLanguage
  @Published var content = ContentBundle(categories: [], quotes: [])
  @Published var selectedCategory = "all"
  @Published var favoriteIds: Set<String> = []
  @Published var customQuotes: [Quote] = []
  @Published var customCategories: [Category] = []
  @Published var deliveryCategoryIds: Set<String> = []
  @Published var deliveryUsesAllCategories = true
  @Published var reminderWeekdays = ReminderWeekdays.all
  @Published var reminderEnabled = false
  @Published private(set) var reminderOnboardingVersion = 0
  @Published private(set) var reminderMinutes = ReminderTimeCodec.defaultMinutes
  @Published var notificationStatus = ""
  @Published var notificationPermissionAlertPending = false
  @Published private(set) var currentDate = Date()

  private static let languageKey = "language"
  private let favoritesKey = "favoriteIds"
  private let selectedCategoryKey = "selectedCategory"
  private let customQuotesKey = "customQuotes"
  private let customCategoriesKey = "customCategories"
  private let deliveryCategoriesKey = "deliveryCategoryIds"
  private let deliveryUsesAllCategoriesKey = "deliveryUsesAllCategories"
  private let reminderWeekdaysKey = "reminderWeekdays"
  private let reminderEnabledKey = "reminderEnabled"
  private let reminderOnboardingVersionKey = "reminderOnboardingVersion"
  private let reminderMinutesKey = "reminderMinutes"
  private let legacyReminderTimeKey = "reminderTime"
  private let legacyNotificationId = "daily-inspiration"
  private let notificationIdPrefix = "daily-inspiration-"
  private let scheduledReminderCount = 60
  private let currentReminderOnboardingVersion = 1
  private var reminderSchedulingTask: Task<Void, Never>?

  init() {
    language = AppLanguage.resolved(
      savedValue: UserDefaults.standard.string(forKey: Self.languageKey),
      preferredLanguages: Locale.preferredLanguages
    )
    loadContent()
    loadSettings()
    refreshReminderIfEnabled()
  }

  var allQuotes: [Quote] {
    content.quotes + customQuotes
  }

  var allCategories: [Category] {
    content.categories + customCategories
  }

  var reminderDate: Date {
    ReminderTimeCodec.date(for: reminderMinutes)
  }

  var needsReminderOnboarding: Bool {
    reminderOnboardingVersion < currentReminderOnboardingVersion
  }

  var todayQuote: Quote {
    quote(for: currentDate, candidates: allQuotes)
  }

  var reminderPreviewQuote: Quote {
    let previewDate = ReminderDatePlanner.dates(
      count: 1,
      minutes: reminderMinutes,
      after: currentDate,
      weekdays: reminderWeekdays
    ).first ?? currentDate
    return quote(for: previewDate, candidates: quotesForDelivery())
  }

  var visibleQuotes: [Quote] {
    if selectedCategory == "all" {
      return allQuotes
    }
    if selectedCategory == "favorites" {
      return allQuotes.filter { favoriteIds.contains($0.id) }
    }
    if selectedCategory == "custom" {
      return customQuotes
    }
    return allQuotes.filter { $0.category == selectedCategory }
  }

  private func quote(for date: Date, candidates: [Quote]) -> Quote {
    guard !candidates.isEmpty else {
      return Quote(id: "empty", category: "animo", text: t("fallbackQuote"))
    }
    let index = DailyQuoteSelector.index(for: date, count: candidates.count) ?? 0
    return candidates[index]
  }

  func t(_ key: String) -> String {
    Strings.value(key, language: language)
  }

  func category(for id: String) -> Category {
    allCategories.first(where: { $0.id == id }) ??
      Category(
        id: "animo",
        name: Strings.categoryName(for: "animo", language: language) ?? t("motivation"),
        color: "#7A5A24",
        softColor: "#F7F1E8",
        description: t("fallbackCategoryDescription")
      )
  }

  func localizedCategoryName(_ category: Category) -> String {
    category.name
  }

  func setLanguage(_ newLanguage: AppLanguage) {
    guard language != newLanguage else { return }
    language = newLanguage
    UserDefaults.standard.set(newLanguage.rawValue, forKey: Self.languageKey)
    notificationStatus = ""
    loadContent()
    customCategories = customCategories.map { category in
      Category(
        id: category.id,
        name: category.name,
        color: category.color,
        softColor: category.softColor,
        description: t("personalCategoryDescription")
      )
    }
    persistCustomCategories()
    refreshReminderIfEnabled()
  }

  func toggleFavorite(_ quote: Quote) {
    if favoriteIds.contains(quote.id) {
      favoriteIds.remove(quote.id)
    } else {
      favoriteIds.insert(quote.id)
    }
    persistFavorites()
  }

  func selectCategory(_ id: String) {
    selectedCategory = id
    UserDefaults.standard.set(id, forKey: selectedCategoryKey)
  }

  @discardableResult
  func addCustomQuote(
    text: String,
    category: String,
    newCategoryName: String? = nil
  ) -> Bool {
    let pendingCategory: Category?
    let targetCategoryId: String
    if let newCategoryName {
      guard let category = makeCustomCategory(name: newCategoryName) else { return false }
      pendingCategory = category
      targetCategoryId = category.id
    } else {
      pendingCategory = nil
      targetCategoryId = category
    }

    var validCategoryIds = Set(allCategories.map(\.id))
    if let pendingCategory {
      validCategoryIds.insert(pendingCategory.id)
    }
    guard let normalizedText = CustomQuoteValidator.normalizedText(
      text,
      category: targetCategoryId,
      validCategoryIds: validCategoryIds
    ) else {
      return false
    }

    if let pendingCategory {
      customCategories.append(pendingCategory)
      persistCustomCategories()
    }
    let quote = Quote(
      id: "custom-\(UUID().uuidString)",
      category: targetCategoryId,
      text: normalizedText
    )
    customQuotes.insert(quote, at: 0)
    selectCategory("custom")
    persistCustomQuotes()
    refreshReminderIfEnabled()
    return true
  }

  private func makeCustomCategory(name: String) -> Category? {
    guard customCategories.count < CustomCategoryValidator.maximumCategoryCount else { return nil }
    let reservedNames = customCategories.map(\.name) + Strings.reservedCategoryNames
    guard let normalizedName = CustomCategoryValidator.normalizedName(
      name,
      existingNames: reservedNames
    ) else {
      return nil
    }

    return Category(
      id: "user-category-\(UUID().uuidString)",
      name: normalizedName,
      color: Self.customCategoryStyle.color,
      softColor: Self.customCategoryStyle.softColor,
      description: t("personalCategoryDescription")
    )
  }

  func canCreateCustomCategory(named name: String) -> Bool {
    guard customCategories.count < CustomCategoryValidator.maximumCategoryCount else { return false }
    let reservedNames = customCategories.map(\.name) + Strings.reservedCategoryNames
    return CustomCategoryValidator.normalizedName(name, existingNames: reservedNames) != nil
  }

  func isCustomCategory(_ category: Category) -> Bool {
    category.id.hasPrefix("user-category-")
  }

  func isCustomQuote(_ quote: Quote) -> Bool {
    quote.id.hasPrefix("custom-")
  }

  func deleteCustomQuote(_ quote: Quote) {
    guard isCustomQuote(quote) else { return }
    customQuotes.removeAll { $0.id == quote.id }
    favoriteIds.remove(quote.id)
    if let category = customCategories.first(where: { $0.id == quote.category }),
       !customQuotes.contains(where: { $0.category == category.id }) {
      customCategories.removeAll { $0.id == category.id }
      deliveryCategoryIds.remove(category.id)
      if !deliveryUsesAllCategories, deliveryCategoryIds.isEmpty {
        deliveryUsesAllCategories = true
      }
      if selectedCategory == category.id {
        selectCategory("custom")
      }
      persistCustomCategories()
      UserDefaults.standard.set(Array(deliveryCategoryIds), forKey: deliveryCategoriesKey)
      UserDefaults.standard.set(deliveryUsesAllCategories, forKey: deliveryUsesAllCategoriesKey)
    }
    persistCustomQuotes()
    persistFavorites()
    refreshReminderIfEnabled()
  }

  func deletingQuoteRemovesCategory(_ quote: Quote) -> Bool {
    guard isCustomQuote(quote), customCategories.contains(where: { $0.id == quote.category }) else {
      return false
    }
    return customQuotes.filter { $0.category == quote.category }.count == 1
  }

  private func setReminder(enabled: Bool) {
    reminderEnabled = enabled
    UserDefaults.standard.set(enabled, forKey: reminderEnabledKey)
    if enabled {
      scheduleReminderRequestingPermission()
    } else {
      removeOwnedPendingReminders()
      notificationStatus = t("notificationsOff")
    }
  }

  @discardableResult
  func saveReminderSettings(
    enabled: Bool,
    time: Date,
    weekdays: Set<ReminderWeekday>,
    deliveryCategories: Set<String>,
    useAllCategories: Bool
  ) -> Bool {
    guard !enabled || !weekdays.isEmpty else { return false }
    let validCategoryIds = Set(allCategories.map(\.id))
    let resolvedDeliveryCategories = deliveryCategories.intersection(validCategoryIds)
    guard !enabled || useAllCategories || !resolvedDeliveryCategories.isEmpty else { return false }
    reminderMinutes = ReminderTimeCodec.minutes(from: time)
    reminderWeekdays = weekdays.isEmpty ? ReminderWeekdays.all : weekdays
    deliveryUsesAllCategories = useAllCategories
    deliveryCategoryIds = useAllCategories ? [] : resolvedDeliveryCategories
    reminderEnabled = enabled

    let defaults = UserDefaults.standard
    defaults.set(reminderMinutes, forKey: reminderMinutesKey)
    defaults.set(ReminderWeekdays.persisted(reminderWeekdays), forKey: reminderWeekdaysKey)
    defaults.set(Array(deliveryCategoryIds), forKey: deliveryCategoriesKey)
    defaults.set(deliveryUsesAllCategories, forKey: deliveryUsesAllCategoriesKey)
    defaults.set(reminderEnabled, forKey: reminderEnabledKey)

    if enabled {
      scheduleReminderRequestingPermission()
    } else {
      removeOwnedPendingReminders()
      notificationStatus = t("notificationsOff")
    }
    return true
  }

  func completeInitialReminderSetup(time: Date, weekdays: Set<ReminderWeekday>) {
    guard !weekdays.isEmpty else { return }
    reminderOnboardingVersion = currentReminderOnboardingVersion
    UserDefaults.standard.set(reminderOnboardingVersion, forKey: reminderOnboardingVersionKey)
    _ = saveReminderSettings(
      enabled: true,
      time: time,
      weekdays: weekdays,
      deliveryCategories: [],
      useAllCategories: true
    )
  }

  func skipInitialReminderSetup() {
    reminderOnboardingVersion = currentReminderOnboardingVersion
    UserDefaults.standard.set(reminderOnboardingVersion, forKey: reminderOnboardingVersionKey)
    setReminder(enabled: false)
  }

  func refreshReminderIfEnabled() {
    guard !needsReminderOnboarding, reminderEnabled else { return }
    replaceReminderSchedulingTask {
      let settings = await UNUserNotificationCenter.current().notificationSettings()
      guard !Task.isCancelled else { return }
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        await self.scheduleAuthorizedReminders()
      case .denied:
        self.reminderEnabled = false
        UserDefaults.standard.set(false, forKey: self.reminderEnabledKey)
        self.notificationStatus = self.t("permissionDenied")
      case .notDetermined:
        break
      @unknown default:
        break
      }
    }
  }

  func refreshCurrentDate() {
    currentDate = Date()
  }

  func sendTestNotification() {
    Task {
      guard await requestNotificationPermission() else { return }
      let notification = UNMutableNotificationContent()
      notification.title = t("notificationTitle")
      notification.body = todayQuote.text
      notification.sound = .default
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
      let request = UNNotificationRequest(
        identifier: "test-inspiration",
        content: notification,
        trigger: trigger
      )
      do {
        try await UNUserNotificationCenter.current().add(request)
        notificationStatus = t("testSent")
      } catch {
        notificationStatus = t("testFailed")
      }
    }
  }

  private func scheduleReminderRequestingPermission() {
    replaceReminderSchedulingTask {
      guard await self.requestNotificationPermission(), !Task.isCancelled else { return }
      await self.scheduleAuthorizedReminders()
    }
  }

  private func scheduleAuthorizedReminders() async {
    let requests = makeReminderRequests()
    guard !requests.isEmpty else {
      notificationStatus = t("reminderFailed")
      return
    }

    let center = UNUserNotificationCenter.current()
    let desiredIdentifiers = Set(requests.map(\.identifier))
    let legacyNotificationId = self.legacyNotificationId
    let notificationIdPrefix = self.notificationIdPrefix

    let pending = await center.pendingNotificationRequests()
    guard !Task.isCancelled else { return }
    let staleIdentifiers = pending
      .map(\.identifier)
      .filter {
        ($0 == legacyNotificationId || $0.hasPrefix(notificationIdPrefix)) &&
          !desiredIdentifiers.contains($0)
      }
    center.removePendingNotificationRequests(withIdentifiers: staleIdentifiers)

    var failed = false
    for request in requests {
      guard !Task.isCancelled else { return }
      do {
        try await center.add(request)
      } catch {
        failed = true
      }
    }
    guard !Task.isCancelled else { return }
    notificationStatus = failed ? t("reminderFailed") : t("reminderSaved")
  }

  private func makeReminderRequests(now: Date = Date()) -> [UNNotificationRequest] {
    let calendar = Calendar.autoupdatingCurrent
    let deliveryQuotes = quotesForDelivery()
    return ReminderDatePlanner.dates(
      count: scheduledReminderCount,
      minutes: reminderMinutes,
      after: now,
      weekdays: reminderWeekdays,
      calendar: calendar
    ).map { deliveryDate in
      let notification = UNMutableNotificationContent()
      notification.title = t("notificationTitle")
      notification.body = quote(for: deliveryDate, candidates: deliveryQuotes).text
      notification.sound = .default

      let date = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: deliveryDate)
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      return UNNotificationRequest(
        identifier: reminderIdentifier(for: deliveryDate, calendar: calendar),
        content: notification,
        trigger: trigger
      )
    }
  }
  private func reminderIdentifier(for date: Date, calendar: Calendar) -> String {
    let parts = calendar.dateComponents([.year, .month, .day], from: date)
    let datePart = String(
      format: "%04d-%02d-%02d",
      parts.year ?? 0,
      parts.month ?? 0,
      parts.day ?? 0
    )
    return notificationIdPrefix + datePart
  }

  private func removeOwnedPendingReminders() {
    replaceReminderSchedulingTask {
      await self.removeOwnedPendingRemindersNow()
    }
  }

  private func removeOwnedPendingRemindersNow() async {
    let center = UNUserNotificationCenter.current()
    let legacyNotificationId = self.legacyNotificationId
    let notificationIdPrefix = self.notificationIdPrefix
    let pending = await center.pendingNotificationRequests()
    let identifiers = pending
      .map(\.identifier)
      .filter { $0 == legacyNotificationId || $0.hasPrefix(notificationIdPrefix) }
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
  }

  private func replaceReminderSchedulingTask(
    with operation: @escaping @MainActor () async -> Void
  ) {
    let previousTask = reminderSchedulingTask
    previousTask?.cancel()
    reminderSchedulingTask = Task {
      _ = await previousTask?.result
      guard !Task.isCancelled else { return }
      await operation()
    }
  }

  private func requestNotificationPermission() async -> Bool {
    do {
      let granted = try await UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound]
      )
      if !granted {
        reminderEnabled = false
        UserDefaults.standard.set(false, forKey: reminderEnabledKey)
        notificationStatus = t("permissionDenied")
        notificationPermissionAlertPending = true
      }
      return granted
    } catch {
      reminderEnabled = false
      UserDefaults.standard.set(false, forKey: reminderEnabledKey)
      notificationStatus = t("permissionDenied")
      notificationPermissionAlertPending = true
      return false
    }
  }

  private func quotesForDelivery() -> [Quote] {
    if deliveryUsesAllCategories {
      return allQuotes
    }
    let filtered = allQuotes.filter { deliveryCategoryIds.contains($0.category) }
    return filtered.isEmpty ? allQuotes : filtered
  }

  private func persistFavorites() {
    UserDefaults.standard.set(Array(favoriteIds), forKey: favoritesKey)
  }

  private func persistCustomQuotes() {
    if let data = try? JSONEncoder().encode(customQuotes) {
      UserDefaults.standard.set(data, forKey: customQuotesKey)
    }
  }

  private func persistCustomCategories() {
    if let data = try? JSONEncoder().encode(customCategories) {
      UserDefaults.standard.set(data, forKey: customCategoriesKey)
    }
  }

  private func loadContent() {
    let preferredResource = language == .es ? "content" : "content-en"
    let fallbackResource = language == .es ? "content-en" : "content"
    for resourceName in [preferredResource, fallbackResource] {
      guard
        let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let decoded = try? JSONDecoder().decode(ContentBundle.self, from: data)
      else {
        continue
      }
      content = decoded
      return
    }
  }

  private func loadSettings() {
    let defaults = UserDefaults.standard
    let legacyKeys = [
      Self.languageKey,
      favoritesKey,
      selectedCategoryKey,
      customQuotesKey,
      deliveryCategoriesKey,
      deliveryUsesAllCategoriesKey,
      reminderEnabledKey,
      reminderMinutesKey,
      legacyReminderTimeKey
    ]
    let wasExistingInstallation = legacyKeys.contains { defaults.object(forKey: $0) != nil }
    var existingCategoryNames: [String] = []
    if let data = defaults.data(forKey: customCategoriesKey),
       let decoded = try? JSONDecoder().decode([Category].self, from: data) {
      var seenIds = Set<String>()
      customCategories = decoded.prefix(CustomCategoryValidator.maximumCategoryCount).compactMap { category in
        guard
          category.id.hasPrefix("user-category-"),
          seenIds.insert(category.id).inserted,
          let normalizedName = CustomCategoryValidator.normalizedName(
            category.name,
            existingNames: existingCategoryNames
          )
        else {
          return nil
        }
        existingCategoryNames.append(normalizedName)
        return Category(
          id: category.id,
          name: normalizedName,
          color: category.color,
          softColor: category.softColor,
          description: t("personalCategoryDescription")
        )
      }
      persistCustomCategories()
    }

    reminderWeekdays = ReminderWeekdays.normalized(
      defaults.array(forKey: reminderWeekdaysKey) as? [Int] ?? []
    )
    defaults.set(ReminderWeekdays.persisted(reminderWeekdays), forKey: reminderWeekdaysKey)

    let hasStoredReminderPreference = defaults.object(forKey: reminderEnabledKey) != nil
    reminderEnabled = hasStoredReminderPreference ? defaults.bool(forKey: reminderEnabledKey) : true
    reminderOnboardingVersion = defaults.object(forKey: reminderOnboardingVersionKey) != nil
      ? defaults.integer(forKey: reminderOnboardingVersionKey)
      : (wasExistingInstallation ? currentReminderOnboardingVersion : 0)
    defaults.set(reminderOnboardingVersion, forKey: reminderOnboardingVersionKey)
    if defaults.object(forKey: reminderMinutesKey) != nil {
      reminderMinutes = ReminderTimeCodec.normalizedMinutes(defaults.integer(forKey: reminderMinutesKey))
    } else {
      reminderMinutes = ReminderTimeCodec.migrate(
        legacyValue: defaults.string(forKey: legacyReminderTimeKey)
      )
      defaults.set(reminderMinutes, forKey: reminderMinutesKey)
    }

    if let data = defaults.data(forKey: customQuotesKey),
       let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
      var seenIds = Set<String>()
      let loadedCategoryIds = Set(allCategories.map(\.id))
      customQuotes = decoded.compactMap { quote in
        let normalizedText = quote.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
          quote.id.hasPrefix("custom-"),
          !normalizedText.isEmpty,
          seenIds.insert(quote.id).inserted
        else {
          return nil
        }
        return Quote(
          id: quote.id,
          category: loadedCategoryIds.contains(quote.category) ? quote.category : "animo",
          text: normalizedText
        )
      }
      persistCustomQuotes()
    }

    let usedCustomCategoryIds = Set(customQuotes.map(\.category))
    customCategories.removeAll { !usedCustomCategoryIds.contains($0.id) }
    persistCustomCategories()

    let validCategoryIds = Set(allCategories.map(\.id))
    let storedDelivery = Set(defaults.stringArray(forKey: deliveryCategoriesKey) ?? [])
    deliveryCategoryIds = storedDelivery.intersection(validCategoryIds)
    deliveryUsesAllCategories = defaults.object(forKey: deliveryUsesAllCategoriesKey) != nil
      ? defaults.bool(forKey: deliveryUsesAllCategoriesKey)
      : deliveryCategoryIds.isEmpty
    if !deliveryUsesAllCategories, deliveryCategoryIds.isEmpty {
      deliveryUsesAllCategories = true
    }
    defaults.set(Array(deliveryCategoryIds), forKey: deliveryCategoriesKey)
    defaults.set(deliveryUsesAllCategories, forKey: deliveryUsesAllCategoriesKey)

    let allowedSelections = validCategoryIds.union(["all", "favorites", "custom"])
    let storedSelection = defaults.string(forKey: selectedCategoryKey) ?? "all"
    selectedCategory = allowedSelections.contains(storedSelection) ? storedSelection : "all"
    defaults.set(selectedCategory, forKey: selectedCategoryKey)

    let validQuoteIds = Set(allQuotes.map(\.id))
    favoriteIds = Set(defaults.stringArray(forKey: favoritesKey) ?? []).intersection(validQuoteIds)
    persistFavorites()
  }

  private static let customCategoryStyle = (color: "#76505D", softColor: "#F3E7EB")
}
struct RootView: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.scenePhase) private var scenePhase
  @State private var tab = 0
  @State private var showingSettings = false

  var body: some View {
    Group {
      if store.needsReminderOnboarding {
        ReminderOnboardingView()
      } else {
        TabView(selection: $tab) {
          TodayView(showingSettings: $showingSettings)
            .tabItem { Label(store.t("today"), systemImage: "sun.max") }
            .tag(0)

          CategoriesView()
            .tabItem { Label(store.t("categories"), systemImage: "square.grid.2x2") }
            .tag(1)

          FavoritesView()
            .tabItem { Label(store.t("favorites"), systemImage: "heart") }
            .tag(2)
        }
        .tint(Premium.gold)
        .sheet(isPresented: $showingSettings) {
          SettingsView()
            .environmentObject(store)
        }
      }
    }
    .onChange(of: scenePhase) { phase in
      if phase == .active {
        store.refreshCurrentDate()
        store.refreshReminderIfEnabled()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
      store.refreshCurrentDate()
      store.refreshReminderIfEnabled()
    }
    .alert(
      store.t("notificationsAreOffTitle"),
      isPresented: $store.notificationPermissionAlertPending
    ) {
      Button(store.t("continue"), role: .cancel) {}
    } message: {
      Text(store.t("notificationsAreOffBody"))
    }
  }
}

struct ReminderOnboardingView: View {
  @EnvironmentObject private var store: AppStore
  @State private var draftTime = ReminderTimeCodec.date(for: ReminderTimeCodec.defaultMinutes)
  @State private var draftWeekdays = ReminderWeekdays.all

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(spacing: 5) {
          Text(store.t("welcomeToWarmWords"))
            .font(.caption.weight(.semibold))
            .tracking(3)
            .foregroundStyle(Premium.gold)
          Text(AppBrand.name)
            .font(Premium.titleFont)
            .foregroundStyle(Premium.ink)
        }
        .accessibilityElement(children: .combine)

        VStack(spacing: 22) {
          VStack(spacing: 10) {
            Text(store.t("onboardingTitle"))
              .font(.system(.largeTitle, design: .serif, weight: .regular))
              .multilineTextAlignment(.center)
              .foregroundStyle(Premium.ink)
              .accessibilityAddTraits(.isHeader)
            Text(store.t("onboardingBody"))
              .font(.body)
              .multilineTextAlignment(.center)
              .foregroundStyle(.secondary)
          }

          Divider()

          VStack(alignment: .leading, spacing: 8) {
            Text(store.t("hour"))
              .font(.headline)
            DatePicker(
              store.t("hour"),
              selection: $draftTime,
              displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            .frame(maxHeight: 150)
            .clipped()
            .accessibilityLabel(store.t("hour"))
          }

          Divider()

          WeekdayPicker(
            selection: $draftWeekdays,
            helper: store.t("everyDayRecommended")
          )

          Button(store.t("setReminder")) {
            store.completeInitialReminderSetup(time: draftTime, weekdays: draftWeekdays)
          }
          .buttonStyle(PrimaryGoldButtonStyle())
          .disabled(draftWeekdays.isEmpty)
        }
        .padding(22)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.8), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 12)

        Button(store.t("notNow")) {
          store.skipInitialReminderSetup()
        }
        .font(.headline)
        .foregroundStyle(Premium.ink)
        .frame(minHeight: 44)
      }
      .padding(.horizontal, 22)
      .padding(.top, 28)
      .padding(.bottom, 24)
    }
    .background(PremiumBackground())
    .onAppear {
      draftTime = store.reminderDate
      draftWeekdays = store.reminderWeekdays
    }
  }
}

struct TodayView: View {
  @EnvironmentObject private var store: AppStore
  @Binding var showingSettings: Bool

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 14) {
          HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
              Text(AppBrand.name)
                .font(Premium.titleFont)
                .foregroundStyle(Premium.ink)
              Text(store.t("premiumConcept").uppercased())
                .font(.system(size: 13, weight: .semibold))
                .tracking(3)
                .foregroundStyle(Premium.gold)
            }
            Spacer()
            Button {
              showingSettings = true
            } label: {
              Image(systemName: "gearshape")
                .font(.title3)
                .foregroundStyle(Premium.gold)
                .frame(width: 46, height: 46)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
            }
            .accessibilityLabel(store.t("settings"))
          }

          Text(store.currentDate.formatted(AppFormatters.day(language: store.language)))
            .font(.system(size: 15))
            .foregroundStyle(Premium.gold)

          QuoteHero(quote: store.todayQuote)

          HStack(spacing: 18) {
            Button {
              store.toggleFavorite(store.todayQuote)
            } label: {
              Image(systemName: store.favoriteIds.contains(store.todayQuote.id) ? "heart.fill" : "heart")
                .font(.title3)
                .frame(width: 54, height: 54)
            }
            .buttonStyle(CircleGoldButtonStyle())
            .accessibilityLabel(
              store.favoriteIds.contains(store.todayQuote.id) ? store.t("saved") : store.t("save")
            )
            .accessibilityAddTraits(
              store.favoriteIds.contains(store.todayQuote.id) ? .isSelected : []
            )

            ShareLink(item: "\(store.todayQuote.text)\n\n\(AppBrand.name)") {
              Image(systemName: "square.and.arrow.up")
                .font(.title3)
                .frame(width: 54, height: 54)
            }
            .buttonStyle(CircleGoldButtonStyle())
            .accessibilityLabel(store.t("share"))
          }

        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 12)
      }
      .background(PremiumBackground())
    }
  }
}

struct CategoriesView: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @State private var showingAddCard = false

  private var columns: [GridItem] {
    Array(
      repeating: GridItem(.flexible(), spacing: 12),
      count: dynamicTypeSize.isAccessibilitySize ? 1 : 3
    )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          Header(
            title: store.t("categories"),
            subtitle: store.t("categoriesSubtitle"),
            actionLabel: store.t("newManualCard")
          ) {
            showingAddCard = true
          }

          LazyVGrid(columns: columns, spacing: 12) {
            CategoryTile(id: "all", title: store.t("all"), icon: "sparkles")
            CategoryTile(id: "custom", title: store.t("manualCards"), icon: "plus.square")
            CategoryTile(id: "favorites", title: store.t("favorites"), icon: "heart")
            ForEach(store.customCategories) { category in
              CategoryTile(id: category.id, title: category.name, icon: "folder")
            }
            ForEach(store.content.categories) { category in
              CategoryTile(id: category.id, title: store.localizedCategoryName(category), icon: icon(for: category.id))
            }
          }

          VStack(spacing: 12) {
            ForEach(store.visibleQuotes) { quote in
              QuoteCard(quote: quote)
            }
          }
        }
        .padding(22)
        .padding(.bottom, 28)
      }
      .background(PremiumBackground())
      .sheet(isPresented: $showingAddCard) {
        AddCardView()
          .environmentObject(store)
      }
    }
  }
}

struct FavoritesView: View {
  @EnvironmentObject private var store: AppStore

  var favoriteQuotes: [Quote] {
    store.allQuotes.filter { store.favoriteIds.contains($0.id) }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          Header(title: store.t("favorites"), subtitle: store.t("favoritesSubtitle"))
          if favoriteQuotes.isEmpty {
            Text(store.t("emptyFavorites"))
              .font(Premium.bodyFont)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, minHeight: 240)
              .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 24))
          } else {
            ForEach(favoriteQuotes) { quote in
              QuoteCard(quote: quote)
            }
          }
        }
        .padding(22)
      }
      .background(PremiumBackground())
    }
  }
}

struct SettingsView: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dismiss) private var dismiss
  @State private var draftTime = Date()
  @State private var draftEnabled = true
  @State private var draftWeekdays = ReminderWeekdays.all
  @State private var draftDeliveryCategories: Set<String> = []
  @State private var draftUseAllCategories = true
  @State private var hasLoadedDraft = false

  private var canSave: Bool {
    !draftEnabled || (
      !draftWeekdays.isEmpty &&
        (draftUseAllCategories || !draftDeliveryCategories.isEmpty)
    )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          HStack(spacing: 12) {
            Button {
              dismiss()
            } label: {
              Image(systemName: "chevron.left")
                .frame(width: 44, height: 44)
            }
            .foregroundStyle(Premium.gold)
            .accessibilityLabel(store.t("closeSettings"))
            Spacer()
            Text(store.t("settings"))
              .font(Premium.sectionFont)
              .foregroundStyle(Premium.ink)
              .accessibilityAddTraits(.isHeader)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
          }

          VStack(alignment: .leading, spacing: 12) {
            Text(store.t("language"))
              .font(Premium.sectionFont)
              .foregroundStyle(Premium.ink)
            Picker(
              store.t("language"),
              selection: Binding(
                get: { store.language },
                set: { store.setLanguage($0) }
              )
            ) {
              Text(store.t("english")).tag(AppLanguage.en)
              Text(store.t("spanish")).tag(AppLanguage.es)
            }
            .pickerStyle(.segmented)
          }
          .padding(18)
          .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24))

          VStack(alignment: .leading, spacing: 14) {
            HStack {
              Text(store.t("reminder"))
                .font(Premium.sectionFont)
                .foregroundStyle(Premium.ink)
              Spacer()
              Toggle(store.t("reminders"), isOn: $draftEnabled)
                .labelsHidden()
                .tint(Premium.gold)
                .accessibilityLabel(store.t("reminders"))
            }
            Text(store.t("receiveChosenDays"))
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }

          VStack(alignment: .leading, spacing: 18) {
            HStack {
              Text(store.t("hour"))
                .font(.headline)
              Spacer()
              DatePicker(
                store.t("hour"),
                selection: $draftTime,
                displayedComponents: .hourAndMinute
              )
              .labelsHidden()
              .datePickerStyle(.compact)
              .tint(Premium.gold)
              .accessibilityLabel(store.t("hour"))
            }
            Divider()
            WeekdayPicker(
              selection: $draftWeekdays,
              helper: store.t("everyDayRecommended")
            )
          }
          .padding(18)
          .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24))
          .opacity(draftEnabled ? 1 : 0.58)
          .disabled(!draftEnabled)

          DeliveryCategoryPicker(
            selection: $draftDeliveryCategories,
            useAllCategories: $draftUseAllCategories,
            enabled: draftEnabled
          )

          Button(store.t("saveReminder")) {
            _ = store.saveReminderSettings(
              enabled: draftEnabled,
              time: draftTime,
              weekdays: draftWeekdays,
              deliveryCategories: draftDeliveryCategories,
              useAllCategories: draftUseAllCategories
            )
          }
          .buttonStyle(PrimaryGoldButtonStyle())
          .disabled(!canSave)

          Button(store.t("testNotification")) {
            store.sendTestNotification()
          }
          .buttonStyle(GoldOutlineButtonStyle())

          if !store.notificationStatus.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              Text(store.notificationStatus)
                .font(.footnote)
                .foregroundStyle(.secondary)
              if store.notificationStatus == store.t("permissionDenied") {
                Button(store.t("openIOSSettings")) {
                  guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                  UIApplication.shared.open(url)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Premium.gold)
                .frame(minHeight: 44)
              }
            }
          }

          NotificationPreview()
        }
        .padding(22)
        .padding(.bottom, 36)
      }
      .background(SettingsBackground())
      .onAppear {
        guard !hasLoadedDraft else { return }
        draftTime = store.reminderDate
        draftEnabled = store.reminderEnabled
        draftWeekdays = store.reminderWeekdays
        draftDeliveryCategories = store.deliveryCategoryIds
        draftUseAllCategories = store.deliveryUsesAllCategories
        hasLoadedDraft = true
      }
    }
  }
}
struct AddCardView: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dismiss) private var dismiss
  @State private var text = ""
  @State private var category = "animo"
  @State private var newCategoryName = ""
  private let newCategoryId = "create-new-category"

  private var canAdd: Bool {
    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedText.isEmpty, trimmedText.count <= CustomQuoteValidator.maximumLength else {
      return false
    }
    if category == newCategoryId {
      return store.canCreateCustomCategory(named: newCategoryName)
    }
    return store.allCategories.contains(where: { $0.id == category })
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          HStack {
            Text(store.t("newManualCard"))
              .font(Premium.sectionFont)
              .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(store.t("close")) {
              dismiss()
            }
            .foregroundStyle(Premium.gold)
            .frame(minHeight: 44)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text(store.t("cardText"))
              .font(.headline)
            TextEditor(text: $text)
              .font(Premium.bodyFont)
              .frame(minHeight: 150)
              .padding(12)
              .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18))
              .accessibilityLabel(store.t("cardText"))
            HStack {
              if text.trimmingCharacters(in: .whitespacesAndNewlines).count > CustomQuoteValidator.maximumLength {
                Text(store.t("quoteTooLong"))
                  .foregroundStyle(.red)
              }
              Spacer()
              Text("\(text.trimmingCharacters(in: .whitespacesAndNewlines).count)/\(CustomQuoteValidator.maximumLength)")
                .monospacedDigit()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text(store.t("category"))
              .font(.headline)
            Picker(store.t("category"), selection: $category) {
              ForEach(store.allCategories) { item in
                Text(store.localizedCategoryName(item)).tag(item.id)
              }
              Text(store.t("createNewCategory")).tag(newCategoryId)
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 14)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
          }

          if category == newCategoryId {
            VStack(alignment: .leading, spacing: 8) {
              Text(store.t("categoryName"))
                .font(.headline)
              TextField(store.t("categoryNameExample"), text: $newCategoryName)
                .textInputAutocapitalization(.words)
                .padding(14)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
              Text(store.t("categoryNameHelp"))
                .font(.footnote)
                .foregroundStyle(.secondary)
              if !newCategoryName.isEmpty && !store.canCreateCustomCategory(named: newCategoryName) {
                Text(store.t("categoryNameInvalid"))
                  .font(.footnote)
                  .foregroundStyle(.red)
              }
            }
          }

          Button(store.t("addCard")) {
            if store.addCustomQuote(
              text: text,
              category: category,
              newCategoryName: category == newCategoryId ? newCategoryName : nil
            ) {
              dismiss()
            }
          }
          .buttonStyle(PrimaryGoldButtonStyle())
          .disabled(!canAdd)
        }
        .padding(22)
      }
      .background(PremiumBackground())
      .scrollDismissesKeyboard(.interactively)
    }
  }
}
struct QuoteHero: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  let quote: Quote

  var body: some View {
    let category = store.category(for: quote.category)
    let minimumHeight: CGFloat = dynamicTypeSize.isAccessibilitySize ? 430 : 330
    VStack(spacing: 14) {
      Text("\"")
        .font(.system(size: 38, weight: .semibold, design: .serif))
        .foregroundStyle(Premium.gold)
      Text(quote.text)
        .font(.system(.title2, design: .serif, weight: .regular))
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .foregroundStyle(Premium.ink)
        .minimumScaleFactor(0.82)
      Divider()
        .frame(width: 46)
        .overlay(Premium.gold)
      Text(store.localizedCategoryName(category))
        .font(.system(size: 14, weight: .medium))
        .padding(.horizontal, 18)
        .padding(.vertical, 7)
        .background(Premium.gold.opacity(0.14), in: Capsule())
        .foregroundStyle(Premium.gold)
    }
    .padding(.horizontal, 26)
    .padding(.vertical, 24)
    .frame(maxWidth: .infinity, minHeight: minimumHeight)
    .background {
      BundledImage(name: "premium-mountains", fallback: PremiumBackground())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityHidden(true)
        .clipped()
        .overlay(
          LinearGradient(
            colors: [.white.opacity(0.92), .white.opacity(0.56), .white.opacity(0.18)],
            startPoint: .top,
            endPoint: .bottom
          )
        )
    }
    .clipShape(RoundedRectangle(cornerRadius: 26))
    .overlay(RoundedRectangle(cornerRadius: 26).stroke(.white.opacity(0.8), lineWidth: 1))
    .shadow(color: Color.black.opacity(0.13), radius: 24, x: 0, y: 16)
  }
}

struct QuoteCard: View {
  @EnvironmentObject private var store: AppStore
  @State private var showingDeleteConfirmation = false
  let quote: Quote

  var body: some View {
    let category = store.category(for: quote.category)
    VStack(alignment: .leading, spacing: 12) {
      Text(store.localizedCategoryName(category).uppercased())
        .font(.caption.weight(.semibold))
        .tracking(1.5)
        .foregroundStyle(Premium.gold)
      Text(quote.text)
        .font(Premium.bodyFont)
        .foregroundStyle(Premium.ink)
        .lineSpacing(3)
      HStack(spacing: 18) {
        Button(store.favoriteIds.contains(quote.id) ? store.t("saved") : store.t("save")) {
          store.toggleFavorite(quote)
        }
        .frame(minHeight: 44)
        ShareLink(item: "\(quote.text)\n\n\(AppBrand.name)") {
          Text(store.t("share"))
        }
        .frame(minHeight: 44)
        if store.isCustomQuote(quote) {
          Spacer()
          Button(store.t("delete"), role: .destructive) {
            showingDeleteConfirmation = true
          }
          .frame(minHeight: 44)
        }
      }
      .font(.subheadline.weight(.semibold))
      .foregroundStyle(Premium.gold)
    }
    .padding(18)
    .background(Color(hex: category.softColor).opacity(0.72), in: RoundedRectangle(cornerRadius: 20))
    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.75), lineWidth: 1))
    .confirmationDialog(
      store.t("deleteCardTitle"),
      isPresented: $showingDeleteConfirmation,
      titleVisibility: .visible
    ) {
      Button(store.t("delete"), role: .destructive) {
        store.deleteCustomQuote(quote)
      }
      Button(store.t("cancel"), role: .cancel) {}
    } message: {
      Text(
        store.t(
          store.deletingQuoteRemovesCategory(quote)
            ? "deleteLastQuoteMessage"
            : "deleteCardMessage"
        )
      )
    }
  }
}
struct CategoryTile: View {
  @EnvironmentObject private var store: AppStore
  let id: String
  let title: String
  let icon: String

  var selected: Bool {
    store.selectedCategory == id
  }

  var body: some View {
    Button {
      store.selectCategory(id)
    } label: {
      VStack(spacing: 10) {
        Image(systemName: icon)
          .font(.system(size: 26, weight: .light))
          .foregroundStyle(Premium.gold)
          .accessibilityHidden(true)
        Text(title)
          .font(.system(size: 14, weight: .regular, design: .serif))
          .foregroundStyle(Premium.ink)
          .lineLimit(2)
          .minimumScaleFactor(0.9)
      }
      .frame(maxWidth: .infinity, minHeight: 108)
      .background(.white.opacity(selected ? 0.92 : 0.62), in: RoundedRectangle(cornerRadius: 12))
      .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Premium.gold : .white.opacity(0.7), lineWidth: selected ? 1.2 : 1))
      .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
    .accessibilityValue(store.t(selected ? "selected" : "notSelected"))
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}

struct WeekdayPicker: View {
  @EnvironmentObject private var store: AppStore
  @Binding var selection: Set<ReminderWeekday>
  let helper: String

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(store.t("days"))
        .font(.headline)
      Text(helper)
        .font(.footnote)
        .foregroundStyle(.secondary)
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 7) {
          ForEach(ReminderWeekday.allCases, id: \.self) { day in
            dayButton(day)
          }
        }
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
          ForEach(ReminderWeekday.allCases, id: \.self) { day in
            dayButton(day)
          }
        }
      }
    }
  }

  private func dayButton(_ day: ReminderWeekday) -> some View {
    let selected = selection.contains(day)
    return Button {
      if selected {
        selection.remove(day)
      } else {
        selection.insert(day)
      }
    } label: {
      Text(day.shortLabel(language: store.language))
        .font(.subheadline.weight(.semibold))
        .frame(width: 44, height: 44)
        .background(selected ? Premium.gold : .white.opacity(0.72), in: Circle())
        .foregroundStyle(selected ? .white : Premium.ink)
        .overlay(Circle().stroke(Premium.gold.opacity(0.55), lineWidth: 1))
    }
    .accessibilityLabel(day.fullLabel(language: store.language))
    .accessibilityValue(store.t(selected ? "selected" : "notSelected"))
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}

struct DeliveryCategoryPicker: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Binding var selection: Set<String>
  @Binding var useAllCategories: Bool
  let enabled: Bool

  private var columns: [GridItem] {
    dynamicTypeSize.isAccessibilitySize
      ? [GridItem(.flexible())]
      : [GridItem(.flexible()), GridItem(.flexible())]
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(store.t("deliveryTypes"))
        .font(Premium.sectionFont)
        .foregroundStyle(Premium.ink)

      Button {
        if useAllCategories {
          useAllCategories = false
          selection = Set(store.allCategories.map(\.id))
        } else {
          useAllCategories = true
          selection = []
        }
      } label: {
        HStack {
          Text(store.t("allCategories"))
          Spacer()
          Image(systemName: useAllCategories ? "checkmark.circle.fill" : "circle")
        }
        .font(.body.weight(.medium))
        .foregroundStyle(useAllCategories ? Premium.gold : Premium.ink)
        .frame(minHeight: 44)
      }
      .accessibilityValue(store.t(useAllCategories ? "selected" : "notSelected"))
      .accessibilityAddTraits(useAllCategories ? .isSelected : [])

      Text(store.t("allCategoriesRecommended"))
        .font(.footnote)
        .foregroundStyle(.secondary)

      if !useAllCategories {
        Divider()
        LazyVGrid(columns: columns, spacing: 8) {
          ForEach(store.allCategories) { category in
            Button {
              if selection.contains(category.id) {
                selection.remove(category.id)
              } else {
                selection.insert(category.id)
              }
            } label: {
              HStack {
                Text(store.localizedCategoryName(category))
                  .lineLimit(2)
                Spacer()
                Image(systemName: selection.contains(category.id) ? "checkmark.circle.fill" : "circle")
              }
              .font(.subheadline.weight(.medium))
              .padding(12)
              .frame(minHeight: 48)
              .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14))
              .foregroundStyle(selection.contains(category.id) ? Premium.gold : Premium.ink)
            }
            .accessibilityValue(
              store.t(selection.contains(category.id) ? "selected" : "notSelected")
            )
            .accessibilityAddTraits(selection.contains(category.id) ? .isSelected : [])
          }
        }
        if selection.isEmpty {
          Text(store.t("chooseOneCategory"))
            .font(.footnote)
            .foregroundStyle(.red)
        }
      }
    }
    .padding(18)
    .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 22))
    .opacity(enabled ? 1 : 0.58)
    .disabled(!enabled)
  }
}

struct NotificationPreview: View {
  @EnvironmentObject private var store: AppStore

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(store.t("notificationPreview"))
        .font(Premium.bodyFont)
      HStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 12)
          .fill(.white.opacity(0.8))
          .frame(width: 46, height: 46)
          .overlay(Image(systemName: "sun.max").foregroundStyle(Premium.gold))
        VStack(alignment: .leading, spacing: 4) {
          Text(AppBrand.name)
            .font(.headline)
          Text(store.reminderPreviewQuote.text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }
        Spacer()
        Text(store.reminderDate.formatted(AppFormatters.time(language: store.language)))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding(14)
      .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 18))
    }
  }
}

struct Header: View {
  let title: String
  let subtitle: String
  var actionLabel: String? = nil
  var action: (() -> Void)? = nil

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(Premium.titleFont)
          .foregroundStyle(Premium.ink)
          .accessibilityAddTraits(.isHeader)
        Text(subtitle)
          .font(.system(size: 15))
          .foregroundStyle(.secondary)
      }
      Spacer()
      if let action {
        Button(action: action) {
          Image(systemName: "plus")
            .font(.title3)
            .foregroundStyle(Premium.gold)
            .frame(width: 46, height: 46)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel(actionLabel ?? title)
      }
    }
  }
}

struct PremiumBackground: View {
  var body: some View {
    LinearGradient(
      colors: [Color(hex: "#F7F1E8"), Color(hex: "#FBF8F1"), Color(hex: "#EFE7DA")],
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()
  }
}

struct SettingsBackground: View {
  var body: some View {
    ZStack(alignment: .bottom) {
      PremiumBackground()
      BundledImage(name: "premium-stones", fallback: Color.clear)
        .frame(height: 300)
        .clipped()
        .opacity(0.62)
        .ignoresSafeArea(edges: .bottom)
        .accessibilityHidden(true)
    }
  }
}

struct BundledImage<Fallback: View>: View {
  let name: String
  let fallback: Fallback

  var body: some View {
    if let image = uiImage {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
    } else {
      fallback
    }
  }

  private var uiImage: UIImage? {
    if let image = UIImage(named: name) {
      return image
    }
    if let url = Bundle.main.url(forResource: name, withExtension: "png"),
       let image = UIImage(contentsOfFile: url.path) {
      return image
    }
    if let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
       let image = UIImage(contentsOfFile: url.path) {
      return image
    }
    return nil
  }
}

struct CircleGoldButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(Premium.gold)
      .background(.white.opacity(0.86), in: Circle())
      .shadow(color: Color.black.opacity(configuration.isPressed ? 0.04 : 0.12), radius: 14, x: 0, y: 8)
  }
}

struct PrimaryGoldButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity, minHeight: 52)
      .background(Premium.gold, in: Capsule())
      .opacity(configuration.isPressed ? 0.82 : 1)
  }
}

struct GoldOutlineButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .foregroundStyle(Premium.gold)
      .frame(maxWidth: .infinity, minHeight: 52)
      .background(.white.opacity(0.55), in: Capsule())
      .overlay(Capsule().stroke(Premium.gold.opacity(0.65), lineWidth: 1))
      .opacity(configuration.isPressed ? 0.82 : 1)
  }
}

enum Premium {
  static let gold = Color(hex: "#7A5A24")
  static let ink = Color(hex: "#191611")
  static let titleFont = Font.system(.largeTitle, design: .serif, weight: .regular)
  static let sectionFont = Font.system(.title2, design: .serif, weight: .regular)
  static let bodyFont = Font.system(.body, design: .serif, weight: .regular)
}

enum AppFormatters {
  static func day(language: AppLanguage) -> Date.FormatStyle {
    Date.FormatStyle()
      .weekday(.wide)
      .day()
      .month(.wide)
      .locale(Locale(identifier: language.localeIdentifier))
  }

  static func time(language: AppLanguage) -> Date.FormatStyle {
    Date.FormatStyle()
      .hour()
      .minute()
      .locale(Locale(identifier: language.localeIdentifier))
  }
}

enum Strings {
  static func value(_ key: String, language: AppLanguage) -> String {
    switch language {
    case .en:
      return en[key] ?? es[key] ?? key
    case .es:
      return es[key] ?? en[key] ?? key
    }
  }

  static let categoryNamesEN = [
    "animo": "Motivation",
    "foco": "Focus",
    "calma": "Calm",
    "disciplina": "Discipline",
    "autoestima": "Self-worth",
    "gratitud": "Gratitude",
    "valentia": "Courage",
    "habitos": "Habits",
    "creatividad": "Creativity",
    "resiliencia": "Resilience",
    "relaciones": "Relationships",
    "energia": "Energy"
  ]

  static let categoryNamesES = [
    "animo": "Ánimo",
    "foco": "Enfoque",
    "calma": "Calma",
    "disciplina": "Disciplina",
    "autoestima": "Autoestima",
    "gratitud": "Gratitud",
    "valentia": "Valentía",
    "habitos": "Hábitos",
    "creatividad": "Creatividad",
    "resiliencia": "Resiliencia",
    "relaciones": "Relaciones",
    "energia": "Energía"
  ]

  static func categoryName(for id: String, language: AppLanguage) -> String? {
    switch language {
    case .en: return categoryNamesEN[id]
    case .es: return categoryNamesES[id]
    }
  }

  static var reservedCategoryNames: [String] {
    Array(categoryNamesEN.values) + Array(categoryNamesES.values) + [
      "All", "Todas", "Favorites", "Favoritos", "Personal", "Personales"
    ]
  }

  private static let es = [
    "today": "Hoy",
    "categories": "Categorías",
    "favorites": "Favoritos",
    "premiumConcept": "Un momento de calma",
    "categoriesSubtitle": "Explora frases por categoría.",
    "favoritesSubtitle": "Las palabras que quieres conservar.",
    "emptyFavorites": "Guarda frases para verlas aquí.",
    "all": "Todas",
    "manualCards": "Personales",
    "settings": "Ajustes",
    "closeSettings": "Cerrar ajustes",
    "welcomeToWarmWords": "BIENVENIDO A",
    "onboardingTitle": "¿Cuándo quieres recibir tu frase?",
    "onboardingBody": "Elige una hora y los días en los que quieres recibir un recordatorio.",
    "everyDayRecommended": "Recomendamos todos los días",
    "setReminder": "Activar recordatorio",
    "notNow": "Ahora no",
    "reminder": "Recordatorio",
    "reminders": "Recordatorios",
    "receiveChosenDays": "Recibe una frase los días que elijas.",
    "dailyNotification": "Notificación diaria",
    "receiveDaily": "Recibe una frase inspiradora cada día.",
    "hour": "Hora",
    "days": "Días",
    "language": "Idioma",
    "english": "Inglés",
    "spanish": "Español",
    "saveReminder": "Guardar recordatorio",
    "testNotification": "Probar notificación",
    "notificationPreview": "Vista previa",
    "now": "ahora",
    "deliveryTypes": "Categorías de frases",
    "deliveryHelp": "Si no eliges ninguna, recibirás frases de todas las categorías.",
    "allCategories": "Todas las categorías",
    "allCategoriesRecommended": "Recomendamos todas las categorías.",
    "chooseOneCategory": "Elige al menos una categoría.",
    "newManualCard": "Nueva frase personal",
    "personalCategoryDescription": "Una categoría para tus frases personales.",
    "category": "Categoría",
    "createNewCategory": "Crear una categoría…",
    "categoryName": "Nombre de la categoría",
    "categoryNameExample": "p. ej. Enfoque matinal",
    "categoryNameHelp": "Hasta 24 caracteres.",
    "categoryNameInvalid": "Elige otro nombre para la categoría.",
    "addCard": "Añadir frase",
    "cardText": "Texto de la frase",
    "quoteTooLong": "Limita tu frase a 240 caracteres.",
    "close": "Cerrar",
    "delete": "Eliminar",
    "deleteCardTitle": "¿Eliminar esta frase?",
    "deleteCardMessage": "Esto elimina la frase y su estado de guardada de este dispositivo.",
    "deleteLastQuoteMessage": "También elimina su categoría personal porque es la última frase que contiene.",
    "cancel": "Cancelar",
    "selected": "Seleccionado",
    "notSelected": "No seleccionado",
    "saved": "Guardada",
    "save": "Guardar",
    "share": "Compartir",
    "motivation": "Ánimo",
    "fallbackCategoryDescription": "Para ayudarte a dar el siguiente paso.",
    "notificationTitle": "Tu frase del día",
    "fallbackQuote": "Hoy empieza con una frase sencilla y un paso posible.",
    "notificationsOff": "Recordatorios desactivados.",
    "testSent": "Notificación de prueba enviada.",
    "testFailed": "No se pudo enviar la prueba.",
    "reminderSaved": "Recordatorio guardado.",
    "reminderFailed": "No se pudo guardar el recordatorio.",
    "permissionDenied": "El acceso a notificaciones está desactivado.",
    "notificationsAreOffTitle": "Las notificaciones están desactivadas",
    "notificationsAreOffBody": "Puedes activarlas más tarde en Ajustes.",
    "continue": "Continuar",
    "openIOSSettings": "Abrir Ajustes de iOS"
  ]

  private static let en = [
    "today": "Today",
    "categories": "Categories",
    "favorites": "Favorites",
    "premiumConcept": "A quiet moment",
    "categoriesSubtitle": "Browse quotes by category.",
    "favoritesSubtitle": "The words you want to keep.",
    "emptyFavorites": "Save quotes to see them here.",
    "all": "All",
    "manualCards": "Personal",
    "settings": "Settings",
    "closeSettings": "Close settings",
    "welcomeToWarmWords": "WELCOME TO",
    "onboardingTitle": "When should your quote arrive?",
    "onboardingBody": "Choose a time and the days you’d like a reminder.",
    "everyDayRecommended": "Every day is recommended",
    "setReminder": "Set reminder",
    "notNow": "Not now",
    "reminder": "Reminder",
    "reminders": "Reminders",
    "receiveChosenDays": "Receive a quote on the days you choose.",
    "dailyNotification": "Daily notification",
    "receiveDaily": "Receive one inspiring quote each day.",
    "hour": "Time",
    "days": "Days",
    "language": "Language",
    "english": "English",
    "spanish": "Spanish",
    "saveReminder": "Save reminder",
    "testNotification": "Test notification",
    "notificationPreview": "Preview",
    "now": "now",
    "deliveryTypes": "Quote categories",
    "deliveryHelp": "Leave all unselected to receive quotes from every category.",
    "allCategories": "All categories",
    "allCategoriesRecommended": "All categories are recommended.",
    "chooseOneCategory": "Choose at least one category.",
    "newManualCard": "New personal quote",
    "personalCategoryDescription": "A category for your personal quotes.",
    "category": "Category",
    "createNewCategory": "Create a new category…",
    "categoryName": "Category name",
    "categoryNameExample": "e.g. Morning focus",
    "categoryNameHelp": "Up to 24 characters.",
    "categoryNameInvalid": "Choose a different category name.",
    "addCard": "Add quote",
    "cardText": "Quote text",
    "quoteTooLong": "Keep your quote to 240 characters.",
    "close": "Close",
    "delete": "Delete",
    "deleteCardTitle": "Delete this quote?",
    "deleteCardMessage": "This removes the quote and its saved status from this device.",
    "deleteLastQuoteMessage": "This also removes its personal category because it is the last quote in it.",
    "cancel": "Cancel",
    "selected": "Selected",
    "notSelected": "Not selected",
    "saved": "Saved",
    "save": "Save",
    "share": "Share",
    "motivation": "Motivation",
    "fallbackCategoryDescription": "To help you take the next step.",
    "notificationTitle": "Your daily quote",
    "fallbackQuote": "Today begins with one simple phrase and one possible step.",
    "notificationsOff": "Reminders turned off.",
    "testSent": "Test notification sent.",
    "testFailed": "Could not send the test.",
    "reminderSaved": "Reminder saved.",
    "reminderFailed": "Could not save the reminder.",
    "permissionDenied": "Notification access is off.",
    "notificationsAreOffTitle": "Notifications are off",
    "notificationsAreOffBody": "You can enable them later in Settings.",
    "continue": "Continue",
    "openIOSSettings": "Open iOS Settings"
  ]
}

func icon(for id: String) -> String {
  [
    "animo": "leaf",
    "foco": "target",
    "calma": "leaf.circle",
    "disciplina": "mountain.2",
    "autoestima": "person",
    "gratitud": "heart",
    "valentia": "shield",
    "habitos": "calendar.badge.checkmark",
    "creatividad": "lightbulb",
    "resiliencia": "tree",
    "relaciones": "person.2",
    "energia": "bolt"
  ][id] ?? "sparkles"
}

extension Color {
  init(hex: String) {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var value: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&value)
    let red = Double((value >> 16) & 0xFF) / 255
    let green = Double((value >> 8) & 0xFF) / 255
    let blue = Double(value & 0xFF) / 255
    self.init(red: red, green: green, blue: blue)
  }
}
