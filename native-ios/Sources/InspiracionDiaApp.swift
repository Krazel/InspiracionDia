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
        .environment(\.locale, Locale(identifier: "en_US"))
    }
  }
}

@MainActor
final class AppStore: ObservableObject {
  @Published var content = ContentBundle(categories: [], quotes: [])
  @Published var selectedCategory = "all"
  @Published var favoriteIds: Set<String> = []
  @Published var customQuotes: [Quote] = []
  @Published var deliveryCategoryIds: Set<String> = []
  @Published var reminderEnabled = false
  @Published private(set) var reminderMinutes = ReminderTimeCodec.defaultMinutes
  @Published var notificationStatus = ""
  @Published private(set) var currentDate = Date()

  private let favoritesKey = "favoriteIds"
  private let selectedCategoryKey = "selectedCategory"
  private let customQuotesKey = "customQuotes"
  private let deliveryCategoriesKey = "deliveryCategoryIds"
  private let reminderEnabledKey = "reminderEnabled"
  private let reminderMinutesKey = "reminderMinutes"
  private let legacyReminderTimeKey = "reminderTime"
  private let legacyNotificationId = "daily-inspiration"
  private let notificationIdPrefix = "daily-inspiration-"
  private let scheduledReminderCount = 60
  private var reminderSchedulingTask: Task<Void, Never>?

  init() {
    loadContent()
    loadSettings()
    refreshReminderIfEnabled()
  }

  var allQuotes: [Quote] {
    content.quotes + customQuotes
  }

  var reminderDate: Date {
    ReminderTimeCodec.date(for: reminderMinutes)
  }

  var todayQuote: Quote {
    quote(for: currentDate, candidates: allQuotes)
  }

  var reminderPreviewQuote: Quote {
    let previewDate = ReminderDatePlanner.dates(
      count: 1,
      minutes: reminderMinutes,
      after: currentDate
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
    Strings.value(key, language: "en")
  }

  func category(for id: String) -> Category {
    content.categories.first(where: { $0.id == id }) ??
      Category(
        id: "animo",
        name: "Motivation",
        color: "#7A5A24",
        softColor: "#F7F1E8",
        description: "To help you take the next step."
      )
  }

  func localizedCategoryName(_ category: Category) -> String {
    Strings.categoryNamesEN[category.id] ?? category.name
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

  func toggleDeliveryCategory(_ id: String) {
    guard content.categories.contains(where: { $0.id == id }) else { return }
    if deliveryCategoryIds.contains(id) {
      deliveryCategoryIds.remove(id)
    } else {
      deliveryCategoryIds.insert(id)
    }
    UserDefaults.standard.set(Array(deliveryCategoryIds), forKey: deliveryCategoriesKey)
    refreshReminderIfEnabled()
  }

  @discardableResult
  func addCustomQuote(text: String, category: String) -> Bool {
    let validCategoryIds = Set(content.categories.map(\.id))
    guard let normalizedText = CustomQuoteValidator.normalizedText(
      text,
      category: category,
      validCategoryIds: validCategoryIds
    ) else {
      return false
    }

    let quote = Quote(id: "custom-\(UUID().uuidString)", category: category, text: normalizedText)
    customQuotes.insert(quote, at: 0)
    selectCategory("custom")
    persistCustomQuotes()
    refreshReminderIfEnabled()
    return true
  }

  func isCustomQuote(_ quote: Quote) -> Bool {
    quote.id.hasPrefix("custom-")
  }

  func deleteCustomQuote(_ quote: Quote) {
    guard isCustomQuote(quote) else { return }
    customQuotes.removeAll { $0.id == quote.id }
    favoriteIds.remove(quote.id)
    persistCustomQuotes()
    persistFavorites()
    refreshReminderIfEnabled()
  }

  func setReminder(enabled: Bool) {
    reminderEnabled = enabled
    UserDefaults.standard.set(enabled, forKey: reminderEnabledKey)
    if enabled {
      scheduleReminderRequestingPermission()
    } else {
      removeOwnedPendingReminders()
      notificationStatus = t("notificationsOff")
    }
  }

  func setReminderTime(_ date: Date) {
    reminderMinutes = ReminderTimeCodec.minutes(from: date)
    UserDefaults.standard.set(reminderMinutes, forKey: reminderMinutesKey)
    refreshReminderIfEnabled()
  }

  func refreshReminderIfEnabled() {
    guard reminderEnabled else { return }
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
        identifier: "test-inspiration-\(UUID().uuidString)",
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
      }
      return granted
    } catch {
      reminderEnabled = false
      UserDefaults.standard.set(false, forKey: reminderEnabledKey)
      notificationStatus = t("permissionDenied")
      return false
    }
  }

  private func quotesForDelivery() -> [Quote] {
    if deliveryCategoryIds.isEmpty {
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

  private func loadContent() {
    guard
      let url = Bundle.main.url(forResource: "content-en", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let decoded = try? JSONDecoder().decode(ContentBundle.self, from: data)
    else {
      content = ContentBundle(categories: [], quotes: [])
      return
    }
    content = decoded
  }

  private func loadSettings() {
    let defaults = UserDefaults.standard
    let validCategoryIds = Set(content.categories.map(\.id))

    let storedDelivery = Set(defaults.stringArray(forKey: deliveryCategoriesKey) ?? [])
    deliveryCategoryIds = storedDelivery.intersection(validCategoryIds)
    defaults.set(Array(deliveryCategoryIds), forKey: deliveryCategoriesKey)

    reminderEnabled = defaults.bool(forKey: reminderEnabledKey)
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
      customQuotes = decoded.filter { quote in
        quote.id.hasPrefix("custom-") &&
          !quote.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
          validCategoryIds.contains(quote.category) &&
          seenIds.insert(quote.id).inserted
      }
      persistCustomQuotes()
    }

    let allowedSelections = validCategoryIds.union(["all", "favorites", "custom"])
    let storedSelection = defaults.string(forKey: selectedCategoryKey) ?? "all"
    selectedCategory = allowedSelections.contains(storedSelection) ? storedSelection : "all"
    defaults.set(selectedCategory, forKey: selectedCategoryKey)

    let validQuoteIds = Set(allQuotes.map(\.id))
    favoriteIds = Set(defaults.stringArray(forKey: favoritesKey) ?? []).intersection(validQuoteIds)
    persistFavorites()
  }
}
struct RootView: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.scenePhase) private var scenePhase
  @State private var tab = 0
  @State private var showingSettings = false

  var body: some View {
    TabView(selection: $tab) {
      TodayView(showingSettings: $showingSettings, tab: $tab)
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
  }
}

struct TodayView: View {
  @EnvironmentObject private var store: AppStore
  @Binding var showingSettings: Bool
  @Binding var tab: Int

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 22) {
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

          Text(Date.now.formatted(AppFormatters.day))
            .font(.system(size: 15))
            .foregroundStyle(Premium.gold)

          QuoteHero(quote: store.todayQuote)

          HStack(spacing: 18) {
            Button {
              store.toggleFavorite(store.todayQuote)
            } label: {
              Image(systemName: store.favoriteIds.contains(store.todayQuote.id) ? "heart.fill" : "heart")
                .font(.title3)
                .frame(width: 58, height: 58)
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
                .frame(width: 58, height: 58)
            }
            .buttonStyle(CircleGoldButtonStyle())
            .accessibilityLabel(store.t("share"))
          }

          FeatureStrip()

          Button {
            tab = 1
          } label: {
            Text(store.t("chooseCategories"))
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(GoldOutlineButtonStyle())
        }
        .padding(22)
        .padding(.bottom, 28)
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

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 22) {
          HStack {
            Button {
              dismiss()
            } label: {
              Label(store.t("settings"), systemImage: "chevron.left")
                .labelStyle(.titleAndIcon)
            }
            .foregroundStyle(Premium.gold)
            .frame(minHeight: 44)
            .accessibilityLabel(store.t("closeSettings"))
            Spacer()
          }

          Text(store.t("dailyNotification"))
            .font(Premium.sectionFont)
            .foregroundStyle(Premium.ink)
            .accessibilityAddTraits(.isHeader)

          Toggle(store.t("receiveDaily"), isOn: Binding(
            get: { store.reminderEnabled },
            set: { store.setReminder(enabled: $0) }
          ))
          .tint(Premium.gold)
          .font(Premium.bodyFont)

          VStack(alignment: .leading, spacing: 12) {
            Text(store.t("hour"))
              .font(.headline)
            DatePicker(
              store.t("hour"),
              selection: $draftTime,
              displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            .padding()
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
            .accessibilityLabel(store.t("hour"))
          }
          .padding(18)
          .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 24))

          DeliveryCategoryPicker()

          Button(store.t("saveReminder")) {
            store.setReminderTime(draftTime)
            store.setReminder(enabled: store.reminderEnabled)
          }
          .buttonStyle(PrimaryGoldButtonStyle())

          Button(store.t("testNotification")) {
            store.sendTestNotification()
          }
          .buttonStyle(GoldOutlineButtonStyle())

          if !store.notificationStatus.isEmpty {
            Text(store.notificationStatus)
              .font(.footnote)
              .foregroundStyle(.secondary)
          }

          NotificationPreview()
        }
        .padding(22)
        .padding(.bottom, 36)
      }
      .background(SettingsBackground())
      .onAppear { draftTime = store.reminderDate }
    }
  }
}
struct AddCardView: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dismiss) private var dismiss
  @State private var text = ""
  @State private var category = "animo"

  private var canAdd: Bool {
    !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
      store.content.categories.contains(where: { $0.id == category })
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 18) {
        Text(store.t("newManualCard"))
          .font(Premium.sectionFont)
          .accessibilityAddTraits(.isHeader)

        TextEditor(text: $text)
          .font(Premium.bodyFont)
          .frame(minHeight: 160)
          .padding(12)
          .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18))
          .accessibilityLabel(store.t("cardText"))

        Picker(store.t("category"), selection: $category) {
          ForEach(store.content.categories) { item in
            Text(store.localizedCategoryName(item)).tag(item.id)
          }
        }

        Button(store.t("addCard")) {
          if store.addCustomQuote(text: text, category: category) {
            dismiss()
          }
        }
        .buttonStyle(PrimaryGoldButtonStyle())
        .disabled(!canAdd)

        Spacer()
      }
      .padding(22)
      .background(PremiumBackground())
    }
  }
}
struct QuoteHero: View {
  @EnvironmentObject private var store: AppStore
  let quote: Quote

  var body: some View {
    let category = store.category(for: quote.category)
    ZStack(alignment: .bottom) {
      BundledImage(name: "premium-mountains", fallback: PremiumBackground())
        .frame(maxWidth: .infinity, minHeight: 430)
        .accessibilityHidden(true)
        .clipped()
        .overlay(
          LinearGradient(
            colors: [.white.opacity(0.92), .white.opacity(0.56), .white.opacity(0.18)],
            startPoint: .top,
            endPoint: .bottom
          )
        )

      VStack(spacing: 18) {
        Text("\"")
          .font(.system(size: 48, weight: .semibold, design: .serif))
          .foregroundStyle(Premium.gold)
        Text(quote.text)
          .font(.system(.title, design: .serif, weight: .regular))
          .multilineTextAlignment(.center)
          .lineSpacing(5)
          .foregroundStyle(Premium.ink)
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
      .padding(.horizontal, 30)
      .padding(.top, 36)
      .padding(.bottom, 118)
    }
    .frame(maxWidth: .infinity, minHeight: 430)
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
      Text(store.t("deleteCardMessage"))
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

struct DeliveryCategoryPicker: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private var columns: [GridItem] {
    dynamicTypeSize.isAccessibilitySize
      ? [GridItem(.flexible())]
      : [GridItem(.flexible()), GridItem(.flexible())]
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(store.t("deliveryTypes"))
        .font(.headline)
      Text(store.t("deliveryHelp"))
        .font(.footnote)
        .foregroundStyle(.secondary)
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(store.content.categories) { category in
          Button {
            store.toggleDeliveryCategory(category.id)
          } label: {
            HStack {
              Text(store.localizedCategoryName(category))
              Spacer()
              Image(systemName: store.deliveryCategoryIds.contains(category.id) ? "checkmark.circle.fill" : "circle")
            }
            .font(.subheadline.weight(.medium))
            .padding(12)
            .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(store.deliveryCategoryIds.contains(category.id) ? Premium.gold : Premium.ink)
          }
          .accessibilityValue(
            store.t(store.deliveryCategoryIds.contains(category.id) ? "selected" : "notSelected")
          )
          .accessibilityAddTraits(
            store.deliveryCategoryIds.contains(category.id) ? .isSelected : []
          )
        }
      }
    }
    .padding(16)
    .background(.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 22))
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
        Text(store.t("now"))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding(14)
      .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 18))
    }
  }
}

struct FeatureStrip: View {
  @EnvironmentObject private var store: AppStore

  var body: some View {
    HStack(spacing: 0) {
      feature("quote.opening", store.t("featureQuotes"))
      Divider().padding(.vertical, 8)
      feature("square.and.arrow.up", store.t("featureShare"))
      Divider().padding(.vertical, 8)
      feature("bell", store.t("featureDaily"))
    }
    .padding(12)
    .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 18))
  }

  private func feature(_ icon: String, _ text: String) -> some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .foregroundStyle(Premium.gold)
        .accessibilityHidden(true)
      Text(text)
        .font(.caption)
        .multilineTextAlignment(.center)
        .foregroundStyle(Premium.ink)
    }
    .frame(maxWidth: .infinity)
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
  static let day = Date.FormatStyle()
    .weekday(.wide)
    .day()
    .month(.wide)
    .locale(Locale(identifier: "en_US"))
}

enum Strings {
  static func value(_ key: String, language: String) -> String {
    if language == "en" {
      return en[key] ?? es[key] ?? key
    }
    return es[key] ?? key
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

  private static let es = [
    "today": "Hoy",
    "categories": "Categorias",
    "favorites": "Favoritos",
    "premiumConcept": "Silencio premium",
    "chooseCategories": "Elegir tipos de tarjetas",
    "categoriesSubtitle": "Selecciona cuidadosamente lo que quieres recibir.",
    "favoritesSubtitle": "Tu coleccion personal de inspiracion.",
    "emptyFavorites": "Guarda frases para verlas aqui.",
    "all": "Todas",
    "manualCards": "Manuales",
    "settings": "Ajustes",
    "closeSettings": "Cerrar ajustes",
    "dailyNotification": "Notificacion diaria",
    "receiveDaily": "Recibe tu dosis diaria de inspiracion con una notificacion.",
    "hour": "Hora",
    "language": "Idioma",
    "saveReminder": "Guardar recordatorio",
    "testNotification": "Probar notificacion",
    "notificationPreview": "Vista previa de la notificacion",
    "now": "ahora",
    "deliveryTypes": "Tipos de tarjetas",
    "deliveryHelp": "Si no eliges ninguna, pueden llegar todas las categorias.",
    "newManualCard": "Nueva tarjeta manual",
    "category": "Categoria",
    "addCard": "Anadir tarjeta",
    "saved": "Guardada",
    "save": "Guardar",
    "share": "Compartir",
    "featureQuotes": "Frases que inspiran",
    "featureShare": "Comparte lo que te mueve",
    "featureDaily": "Inspiracion diaria",
    "notificationTitle": "Tu inspiracion de hoy",
    "fallbackQuote": "Hoy empieza con una frase sencilla y un paso posible.",
    "notificationsOff": "Notificaciones desactivadas.",
    "testSent": "Notificacion de prueba enviada.",
    "testFailed": "No se pudo enviar la prueba.",
    "reminderSaved": "Recordatorio guardado.",
    "reminderFailed": "No se pudo guardar el recordatorio.",
    "permissionDenied": "Permiso de notificaciones denegado."
  ]

  private static let en = [
    "today": "Today",
    "categories": "Categories",
    "favorites": "Favorites",
    "premiumConcept": "A quiet moment",
    "chooseCategories": "Explore categories",
    "categoriesSubtitle": "Choose what you want to read.",
    "favoritesSubtitle": "The words you want to keep.",
    "emptyFavorites": "Save quotes to see them here.",
    "all": "All",
    "manualCards": "Personal",
    "settings": "Settings",
    "closeSettings": "Close settings",
    "dailyNotification": "Daily notification",
    "receiveDaily": "Receive one inspiring quote each day.",
    "hour": "Time",
    "language": "Language",
    "saveReminder": "Save reminder",
    "testNotification": "Test notification",
    "notificationPreview": "Notification preview",
    "now": "now",
    "deliveryTypes": "Reminder categories",
    "deliveryHelp": "Leave all unselected to receive quotes from every category.",
    "newManualCard": "New personal quote",
    "category": "Category",
    "addCard": "Add quote",
    "cardText": "Quote text",
    "delete": "Delete",
    "deleteCardTitle": "Delete this quote?",
    "deleteCardMessage": "This removes the quote and its saved status from this device.",
    "cancel": "Cancel",
    "selected": "Selected",
    "notSelected": "Not selected",
    "saved": "Saved",
    "save": "Save",
    "share": "Share",
    "featureQuotes": "Thoughtful quotes",
    "featureShare": "Easy to share",
    "featureDaily": "One each day",
    "notificationTitle": "Your daily quote",
    "fallbackQuote": "Today begins with one simple phrase and one possible step.",
    "notificationsOff": "Notifications disabled.",
    "testSent": "Test notification sent.",
    "testFailed": "Could not send the test.",
    "reminderSaved": "Reminder saved.",
    "reminderFailed": "Could not save the reminder.",
    "permissionDenied": "Notification permission denied."
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
