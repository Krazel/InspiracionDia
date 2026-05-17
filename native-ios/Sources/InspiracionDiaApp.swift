import SwiftUI
import UIKit
import UserNotifications

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

@main
struct InspiracionDiaApp: App {
  @StateObject private var store = AppStore()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(store)
    }
  }
}

final class AppStore: ObservableObject {
  @Published var content = ContentBundle(categories: [], quotes: [])
  @Published var selectedCategory = "all"
  @Published var favoriteIds: Set<String> = []
  @Published var customQuotes: [Quote] = []
  @Published var deliveryCategoryIds: Set<String> = []
  @Published var reminderEnabled = false
  @Published var reminderTime = "07:30"
  @Published var language = "es"
  @Published var notificationStatus = ""

  private let favoritesKey = "favoriteIds"
  private let selectedCategoryKey = "selectedCategory"
  private let customQuotesKey = "customQuotes"
  private let deliveryCategoriesKey = "deliveryCategoryIds"
  private let reminderEnabledKey = "reminderEnabled"
  private let reminderTimeKey = "reminderTime"
  private let languageKey = "language"
  private let notificationId = "daily-inspiration"

  init() {
    loadContent()
    loadSettings()
  }

  var allQuotes: [Quote] {
    content.quotes + customQuotes
  }

  var todayQuote: Quote {
    let candidates = quotesForDelivery()
    guard !candidates.isEmpty else {
      return Quote(id: "empty", category: "animo", text: t("fallbackQuote"))
    }
    let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    return candidates[day % candidates.count]
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

  func t(_ key: String) -> String {
    Strings.value(key, language: language)
  }

  func category(for id: String) -> Category {
    content.categories.first(where: { $0.id == id }) ??
      Category(id: "animo", name: "Animo", color: "#A67C2D", softColor: "#F7F1E8", description: "Para levantar el paso.")
  }

  func localizedCategoryName(_ category: Category) -> String {
    if language == "en" {
      return Strings.categoryNamesEN[category.id] ?? category.name
    }
    return category.name
  }

  func toggleFavorite(_ quote: Quote) {
    if favoriteIds.contains(quote.id) {
      favoriteIds.remove(quote.id)
    } else {
      favoriteIds.insert(quote.id)
    }
    UserDefaults.standard.set(Array(favoriteIds), forKey: favoritesKey)
  }

  func selectCategory(_ id: String) {
    selectedCategory = id
    UserDefaults.standard.set(id, forKey: selectedCategoryKey)
  }

  func toggleDeliveryCategory(_ id: String) {
    if deliveryCategoryIds.contains(id) {
      deliveryCategoryIds.remove(id)
    } else {
      deliveryCategoryIds.insert(id)
    }
    UserDefaults.standard.set(Array(deliveryCategoryIds), forKey: deliveryCategoriesKey)
    if reminderEnabled {
      scheduleReminder()
    }
  }

  func addCustomQuote(text: String, category: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    let quote = Quote(id: "custom-\(UUID().uuidString)", category: category, text: trimmed)
    customQuotes.insert(quote, at: 0)
    selectedCategory = "custom"
    persistCustomQuotes()
  }

  func setLanguage(_ value: String) {
    language = value
    UserDefaults.standard.set(value, forKey: languageKey)
  }

  func setReminder(enabled: Bool) {
    reminderEnabled = enabled
    UserDefaults.standard.set(enabled, forKey: reminderEnabledKey)
    if enabled {
      scheduleReminder()
    } else {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
      notificationStatus = t("notificationsOff")
    }
  }

  func setReminderTime(_ value: String) {
    reminderTime = normalizedTime(value)
    UserDefaults.standard.set(reminderTime, forKey: reminderTimeKey)
    if reminderEnabled {
      scheduleReminder()
    }
  }

  func sendTestNotification() {
    requestNotificationPermission { granted in
      guard granted else { return }
      let notification = UNMutableNotificationContent()
      notification.title = self.t("notificationTitle")
      notification.body = self.todayQuote.text
      notification.sound = .default
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
      let request = UNNotificationRequest(identifier: "test-inspiration-\(UUID().uuidString)", content: notification, trigger: trigger)
      UNUserNotificationCenter.current().add(request) { error in
        DispatchQueue.main.async {
          self.notificationStatus = error == nil ? self.t("testSent") : self.t("testFailed")
        }
      }
    }
  }

  private func scheduleReminder() {
    requestNotificationPermission { granted in
      guard granted else { return }

      let parts = self.normalizedTime(self.reminderTime).split(separator: ":").compactMap { Int($0) }
      var date = DateComponents()
      date.hour = parts.first ?? 7
      date.minute = parts.dropFirst().first ?? 30

      let notification = UNMutableNotificationContent()
      notification.title = self.t("notificationTitle")
      notification.body = self.todayQuote.text
      notification.sound = .default

      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
      let request = UNNotificationRequest(identifier: self.notificationId, content: notification, trigger: trigger)
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.notificationId])
      UNUserNotificationCenter.current().add(request) { error in
        DispatchQueue.main.async {
          self.notificationStatus = error == nil ? self.t("reminderSaved") : self.t("reminderFailed")
        }
      }
    }
  }

  private func requestNotificationPermission(_ completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      DispatchQueue.main.async {
        if !granted {
          self.reminderEnabled = false
          UserDefaults.standard.set(false, forKey: self.reminderEnabledKey)
          self.notificationStatus = self.t("permissionDenied")
        }
        completion(granted)
      }
    }
  }

  private func quotesForDelivery() -> [Quote] {
    if deliveryCategoryIds.isEmpty {
      return allQuotes
    }
    return allQuotes.filter { deliveryCategoryIds.contains($0.category) }
  }

  private func persistCustomQuotes() {
    if let data = try? JSONEncoder().encode(customQuotes) {
      UserDefaults.standard.set(data, forKey: customQuotesKey)
    }
  }

  private func loadContent() {
    guard
      let url = Bundle.main.url(forResource: "content", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let decoded = try? JSONDecoder().decode(ContentBundle.self, from: data)
    else {
      content = ContentBundle(categories: [], quotes: [])
      return
    }
    content = decoded
  }

  private func loadSettings() {
    selectedCategory = UserDefaults.standard.string(forKey: selectedCategoryKey) ?? "all"
    favoriteIds = Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
    deliveryCategoryIds = Set(UserDefaults.standard.stringArray(forKey: deliveryCategoriesKey) ?? [])
    reminderEnabled = UserDefaults.standard.bool(forKey: reminderEnabledKey)
    reminderTime = UserDefaults.standard.string(forKey: reminderTimeKey) ?? "07:30"
    language = UserDefaults.standard.string(forKey: languageKey) ?? "es"
    if let data = UserDefaults.standard.data(forKey: customQuotesKey),
       let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
      customQuotes = decoded
    }
  }

  private func normalizedTime(_ value: String) -> String {
    let parts = value.split(separator: ":").compactMap { Int($0) }
    let hour = min(23, max(0, parts.first ?? 7))
    let minute = min(59, max(0, parts.dropFirst().first ?? 30))
    return String(format: "%02d:%02d", hour, minute)
  }
}

struct RootView: View {
  @EnvironmentObject private var store: AppStore
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
              Text("Inspiracion Dia")
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
          }

          Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
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

            ShareLink(item: "\(store.todayQuote.text)\n\nInspiracion Dia") {
              Image(systemName: "square.and.arrow.up")
                .font(.title3)
                .frame(width: 58, height: 58)
            }
            .buttonStyle(CircleGoldButtonStyle())
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
  @State private var showingAddCard = false

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          Header(title: store.t("categories"), subtitle: store.t("categoriesSubtitle")) {
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
  @State private var draftTime = "07:30"

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
            Spacer()
          }

          Text(store.t("dailyNotification"))
            .font(Premium.sectionFont)
            .foregroundStyle(Premium.ink)

          Toggle(store.t("receiveDaily"), isOn: Binding(
            get: { store.reminderEnabled },
            set: { store.setReminder(enabled: $0) }
          ))
          .tint(Premium.gold)
          .font(Premium.bodyFont)

          VStack(alignment: .leading, spacing: 12) {
            Text(store.t("hour"))
              .font(.system(size: 14, weight: .medium))
            TextField("07:30", text: $draftTime)
              .keyboardType(.numbersAndPunctuation)
              .font(.system(size: 34, weight: .medium, design: .serif))
              .multilineTextAlignment(.center)
              .padding()
              .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
              .onSubmit { store.setReminderTime(draftTime) }
          }
          .padding(18)
          .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 24))

          DeliveryCategoryPicker()

          Picker(store.t("language"), selection: Binding(
            get: { store.language },
            set: { store.setLanguage($0) }
          )) {
            Text("Espanol").tag("es")
            Text("English").tag("en")
          }
          .pickerStyle(.segmented)

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
      .onAppear { draftTime = store.reminderTime }
    }
  }
}

struct AddCardView: View {
  @EnvironmentObject private var store: AppStore
  @Environment(\.dismiss) private var dismiss
  @State private var text = ""
  @State private var category = "animo"

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 18) {
        Text(store.t("newManualCard"))
          .font(Premium.sectionFont)

        TextEditor(text: $text)
          .font(Premium.bodyFont)
          .frame(minHeight: 160)
          .padding(12)
          .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18))

        Picker(store.t("category"), selection: $category) {
          ForEach(store.content.categories) { item in
            Text(store.localizedCategoryName(item)).tag(item.id)
          }
        }

        Button(store.t("addCard")) {
          store.addCustomQuote(text: text, category: category)
          dismiss()
        }
        .buttonStyle(PrimaryGoldButtonStyle())

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
          .font(.system(size: 30, weight: .regular, design: .serif))
          .multilineTextAlignment(.center)
          .lineSpacing(5)
          .foregroundStyle(Premium.ink)
          .minimumScaleFactor(0.78)
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
      HStack {
        Button(store.favoriteIds.contains(quote.id) ? store.t("saved") : store.t("save")) {
          store.toggleFavorite(quote)
        }
        ShareLink(item: "\(quote.text)\n\nInspiracion Dia") {
          Text(store.t("share"))
        }
      }
      .font(.subheadline.weight(.semibold))
      .foregroundStyle(Premium.gold)
    }
    .padding(18)
    .background(Color(hex: category.softColor).opacity(0.72), in: RoundedRectangle(cornerRadius: 20))
    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.75), lineWidth: 1))
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
        Text(title)
          .font(.system(size: 14, weight: .regular, design: .serif))
          .foregroundStyle(Premium.ink)
          .lineLimit(1)
          .minimumScaleFactor(0.75)
      }
      .frame(maxWidth: .infinity, minHeight: 108)
      .background(.white.opacity(selected ? 0.92 : 0.62), in: RoundedRectangle(cornerRadius: 12))
      .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? Premium.gold : .white.opacity(0.7), lineWidth: selected ? 1.2 : 1))
      .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
  }
}

struct DeliveryCategoryPicker: View {
  @EnvironmentObject private var store: AppStore

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(store.t("deliveryTypes"))
        .font(.headline)
      Text(store.t("deliveryHelp"))
        .font(.footnote)
        .foregroundStyle(.secondary)
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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
          Text("Inspiracion Dia")
            .font(.headline)
          Text(store.todayQuote.text)
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
  var action: (() -> Void)? = nil

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(Premium.titleFont)
          .foregroundStyle(Premium.ink)
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
  static let gold = Color(hex: "#A67C2D")
  static let ink = Color(hex: "#191611")
  static let titleFont = Font.system(size: 34, weight: .regular, design: .serif)
  static let sectionFont = Font.system(size: 25, weight: .regular, design: .serif)
  static let bodyFont = Font.system(size: 17, weight: .regular, design: .serif)
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
    "premiumConcept": "Premium silence",
    "chooseCategories": "Choose card types",
    "categoriesSubtitle": "Select carefully what you want to receive.",
    "favoritesSubtitle": "Your personal inspiration collection.",
    "emptyFavorites": "Save quotes to see them here.",
    "all": "All",
    "manualCards": "Manual",
    "settings": "Settings",
    "dailyNotification": "Daily notification",
    "receiveDaily": "Receive your daily dose of inspiration with one notification.",
    "hour": "Time",
    "language": "Language",
    "saveReminder": "Save reminder",
    "testNotification": "Test notification",
    "notificationPreview": "Notification preview",
    "now": "now",
    "deliveryTypes": "Card types",
    "deliveryHelp": "If none are selected, every category can arrive.",
    "newManualCard": "New manual card",
    "category": "Category",
    "addCard": "Add card",
    "saved": "Saved",
    "save": "Save",
    "share": "Share",
    "featureQuotes": "Selected inspiration",
    "featureShare": "Share what moves you",
    "featureDaily": "Daily inspiration",
    "notificationTitle": "Your inspiration today",
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
