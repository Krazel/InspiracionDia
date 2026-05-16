import SwiftUI
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
  @Published var reminderEnabled = false
  @Published var reminderTime = "09:00"

  private let favoritesKey = "favoriteIds"
  private let selectedCategoryKey = "selectedCategory"
  private let reminderEnabledKey = "reminderEnabled"
  private let reminderTimeKey = "reminderTime"
  private let notificationId = "daily-inspiration"

  init() {
    loadContent()
    loadSettings()
  }

  var todayQuote: Quote {
    guard !content.quotes.isEmpty else {
      return Quote(id: "empty", category: "animo", text: "Hoy empieza con una frase sencilla y un paso posible.")
    }
    let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    return content.quotes[day % content.quotes.count]
  }

  var visibleQuotes: [Quote] {
    if selectedCategory == "all" {
      return content.quotes
    }
    if selectedCategory == "favorites" {
      return content.quotes.filter { favoriteIds.contains($0.id) }
    }
    return content.quotes.filter { $0.category == selectedCategory }
  }

  func category(for id: String) -> Category {
    content.categories.first(where: { $0.id == id }) ??
      Category(id: "animo", name: "Animo", color: "#F08A24", softColor: "#FFF0D9", description: "Para levantar el paso.")
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

  func setReminder(enabled: Bool) {
    reminderEnabled = enabled
    UserDefaults.standard.set(enabled, forKey: reminderEnabledKey)
    if enabled {
      scheduleReminder()
    } else {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
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
    let notification = UNMutableNotificationContent()
    notification.title = "Tu inspiracion de hoy"
    notification.body = todayQuote.text
    UNUserNotificationCenter.current().add(
      UNNotificationRequest(identifier: "test-inspiration", content: notification, trigger: nil)
    )
  }

  private func scheduleReminder() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      guard granted else {
        DispatchQueue.main.async {
          self.reminderEnabled = false
          UserDefaults.standard.set(false, forKey: self.reminderEnabledKey)
        }
        return
      }

      let parts = self.normalizedTime(self.reminderTime).split(separator: ":").compactMap { Int($0) }
      var date = DateComponents()
      date.hour = parts.first ?? 9
      date.minute = parts.dropFirst().first ?? 0

      let notification = UNMutableNotificationContent()
      notification.title = "Tu inspiracion de hoy"
      notification.body = self.todayQuote.text
      notification.sound = .default

      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
      let request = UNNotificationRequest(identifier: self.notificationId, content: notification, trigger: trigger)
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.notificationId])
      UNUserNotificationCenter.current().add(request)
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
    reminderEnabled = UserDefaults.standard.bool(forKey: reminderEnabledKey)
    reminderTime = UserDefaults.standard.string(forKey: reminderTimeKey) ?? "09:00"
  }

  private func normalizedTime(_ value: String) -> String {
    let parts = value.split(separator: ":").compactMap { Int($0) }
    let hour = min(23, max(0, parts.first ?? 9))
    let minute = min(59, max(0, parts.dropFirst().first ?? 0))
    return String(format: "%02d:%02d", hour, minute)
  }
}

struct RootView: View {
  @EnvironmentObject private var store: AppStore
  @State private var tab = 0

  var body: some View {
    TabView(selection: $tab) {
      TodayView(tab: $tab)
        .tabItem { Label("Hoy", systemImage: "sun.max.fill") }
        .tag(0)

      CardsView()
        .tabItem { Label("Tarjetas", systemImage: "square.grid.2x2.fill") }
        .tag(1)

      SettingsView()
        .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
        .tag(2)
    }
    .tint(Color(hex: "#FF6B57"))
  }
}

struct TodayView: View {
  @EnvironmentObject private var store: AppStore
  @Binding var tab: Int

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Inspiracion Dia")
              .font(.system(size: 34, weight: .heavy))
            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
              .foregroundStyle(.secondary)
          }

          QuoteHero(quote: store.todayQuote)

          HStack(spacing: 12) {
            Button {
              store.toggleFavorite(store.todayQuote)
            } label: {
              Text(store.favoriteIds.contains(store.todayQuote.id) ? "Guardada" : "Guardar")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            ShareLink(item: "\(store.todayQuote.text)\n\nInspiracion Dia") {
              Text("Compartir")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
          }

          ReminderRow()

          Text("Categorias")
            .font(.title2.bold())
          CategoryChips(onSelect: { tab = 1 })
        }
        .padding(20)
        .padding(.bottom, 32)
      }
      .background(AppBackground())
    }
  }
}

struct CardsView: View {
  @EnvironmentObject private var store: AppStore

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Tarjetitas")
            .font(.system(size: 34, weight: .heavy))
          Text("Frases cortas para guardar o compartir.")
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)

        CategoryChips()
          .padding(.horizontal, 20)

        List(store.visibleQuotes) { quote in
          QuoteCard(quote: quote)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
      }
      .background(AppBackground())
    }
  }
}

struct SettingsView: View {
  @EnvironmentObject private var store: AppStore
  @State private var draftTime = "09:00"

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Ajustes")
              .font(.system(size: 34, weight: .heavy))
            Text("Una notificacion bonita al dia.")
              .foregroundStyle(.secondary)
          }

          VStack(spacing: 18) {
            Toggle("Notificacion diaria", isOn: Binding(
              get: { store.reminderEnabled },
              set: { store.setReminder(enabled: $0) }
            ))
            .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
              Text("Hora")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
              TextField("09:00", text: $draftTime)
                .keyboardType(.numbersAndPunctuation)
                .font(.system(size: 28, weight: .bold))
                .padding()
                .background(Color(hex: "#F3F7FB"), in: RoundedRectangle(cornerRadius: 18))
                .onSubmit { store.setReminderTime(draftTime) }
            }

            Button("Guardar recordatorio") {
              store.setReminderTime(draftTime)
              store.setReminder(enabled: store.reminderEnabled)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Probar notificacion") {
              store.sendTestNotification()
            }
            .buttonStyle(SecondaryButtonStyle())
          }
          .padding(20)
          .background(.white, in: RoundedRectangle(cornerRadius: 28))
        }
        .padding(20)
      }
      .background(AppBackground())
      .onAppear { draftTime = store.reminderTime }
    }
  }
}

struct QuoteHero: View {
  @EnvironmentObject private var store: AppStore
  let quote: Quote

  var body: some View {
    let category = store.category(for: quote.category)
    VStack(spacing: 22) {
      Text(category.name.uppercased())
        .font(.caption.bold())
        .foregroundStyle(Color(hex: category.color))
      Text(quote.text)
        .font(.system(size: 31, weight: .heavy))
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .foregroundStyle(Color(hex: "#172033"))
    }
    .frame(maxWidth: .infinity, minHeight: 390)
    .padding(28)
    .background(Color(hex: category.softColor), in: RoundedRectangle(cornerRadius: 34))
    .shadow(color: Color.black.opacity(0.10), radius: 26, x: 0, y: 16)
  }
}

struct QuoteCard: View {
  @EnvironmentObject private var store: AppStore
  let quote: Quote

  var body: some View {
    let category = store.category(for: quote.category)
    VStack(alignment: .leading, spacing: 12) {
      Text(category.name.uppercased())
        .font(.caption.bold())
        .foregroundStyle(Color(hex: category.color))
      Text(quote.text)
        .font(.system(size: 21, weight: .bold))
        .lineSpacing(3)
      HStack {
        Button(store.favoriteIds.contains(quote.id) ? "Guardada" : "Guardar") {
          store.toggleFavorite(quote)
        }
        .foregroundStyle(store.favoriteIds.contains(quote.id) ? Color(hex: "#FF6B57") : Color(hex: "#172033"))
        ShareLink(item: "\(quote.text)\n\nInspiracion Dia") {
          Text("Compartir")
        }
        .foregroundStyle(Color(hex: "#172033"))
      }
      .font(.subheadline.bold())
    }
    .padding(20)
    .background(Color(hex: category.softColor), in: RoundedRectangle(cornerRadius: 24))
  }
}

struct ReminderRow: View {
  @EnvironmentObject private var store: AppStore

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Una frase al dia")
          .font(.headline)
        Text(store.reminderEnabled ? "Activa a las \(store.reminderTime)" : "Recordatorio desactivado")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Toggle("", isOn: Binding(
        get: { store.reminderEnabled },
        set: { store.setReminder(enabled: $0) }
      ))
      .labelsHidden()
    }
    .padding(18)
    .background(.white, in: RoundedRectangle(cornerRadius: 24))
  }
}

struct CategoryChips: View {
  @EnvironmentObject private var store: AppStore
  var onSelect: (() -> Void)? = nil

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 9) {
        chip(id: "all", name: "Todas", color: "#FF6B57", softColor: "#FFE6E1")
        chip(id: "favorites", name: "Favoritas", color: "#C85C8E", softColor: "#FBE5F0")
        ForEach(store.content.categories) { category in
          chip(id: category.id, name: category.name, color: category.color, softColor: category.softColor)
        }
      }
    }
  }

  private func chip(id: String, name: String, color: String, softColor: String) -> some View {
    let selected = store.selectedCategory == id
    return Button {
      store.selectCategory(id)
      onSelect?()
    } label: {
      Text(name)
        .font(.subheadline.bold())
        .padding(.horizontal, 16)
        .frame(height: 40)
        .foregroundStyle(selected ? .white : Color(hex: color))
        .background(selected ? Color(hex: color) : Color(hex: softColor), in: Capsule())
    }
  }
}

struct AppBackground: View {
  var body: some View {
    LinearGradient(
      colors: [Color(hex: "#FFFFFF"), Color(hex: "#F8FBFF"), Color(hex: "#EEF8F1")],
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()
  }
}

struct PrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .foregroundStyle(.white)
      .frame(minHeight: 52)
      .padding(.horizontal, 20)
      .background(Color(hex: "#FF6B57"), in: Capsule())
      .opacity(configuration.isPressed ? 0.82 : 1)
  }
}

struct SecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .foregroundStyle(Color(hex: "#172033"))
      .frame(minHeight: 52)
      .padding(.horizontal, 20)
      .background(.white, in: Capsule())
      .opacity(configuration.isPressed ? 0.82 : 1)
  }
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
