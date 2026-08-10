import Foundation

enum AppLanguage: String, CaseIterable, Hashable {
  case en
  case es

  var localeIdentifier: String {
    switch self {
    case .en: return "en_US"
    case .es: return "es_ES"
    }
  }

  static func resolved(savedValue: String?, preferredLanguages: [String]) -> AppLanguage {
    if let savedValue, let saved = AppLanguage(rawValue: savedValue) {
      return saved
    }
    return preferredLanguages.first?.lowercased().hasPrefix("es") == true ? .es : .en
  }
}

enum ShareLinkRoute {
  static let landingPageURL = URL(string: "https://krazel.github.io/warm-words/share/")!
  static let customScheme = "warmwords"
  static let isPublicLinkEnabled = false

  static func handles(_ url: URL) -> Bool {
    if url.scheme?.lowercased() == customScheme {
      return true
    }
    let isSharePath = url.path == "/warm-words/share" || url.path.hasPrefix("/warm-words/share/")
    return url.scheme?.lowercased() == "https" &&
      url.host?.lowercased() == landingPageURL.host &&
      isSharePath
  }
}

enum DailyQuoteSelector {
  private static let epochComponents = DateComponents(
    calendar: Calendar(identifier: .gregorian),
    timeZone: TimeZone(secondsFromGMT: 0),
    year: 2020,
    month: 1,
    day: 1
  )

  static func index(for date: Date, count: Int, calendar: Calendar = .autoupdatingCurrent) -> Int? {
    guard count > 0, let epoch = epochComponents.date else { return nil }
    let start = calendar.startOfDay(for: date)
    let epochStart = calendar.startOfDay(for: epoch)
    let days = calendar.dateComponents([.day], from: epochStart, to: start).day ?? 0
    return ((days % count) + count) % count
  }
}

enum ReminderTimeCodec {
  static let defaultMinutes = 7 * 60 + 30

  static func normalizedMinutes(_ value: Int) -> Int {
    min(23 * 60 + 59, max(0, value))
  }

  static func minutes(from date: Date, calendar: Calendar = .autoupdatingCurrent) -> Int {
    let components = calendar.dateComponents([.hour, .minute], from: date)
    return normalizedMinutes((components.hour ?? 7) * 60 + (components.minute ?? 30))
  }

  static func date(
    for minutes: Int,
    relativeTo reference: Date = Date(),
    calendar: Calendar = .autoupdatingCurrent
  ) -> Date {
    let normalized = normalizedMinutes(minutes)
    let start = calendar.startOfDay(for: reference)
    return calendar.date(byAdding: .minute, value: normalized, to: start) ?? reference
  }

  static func migrate(legacyValue: String?) -> Int {
    guard let legacyValue else { return defaultMinutes }
    let parts = legacyValue.split(separator: ":", omittingEmptySubsequences: false)
    guard
      parts.count == 2,
      let hour = Int(parts[0]),
      let minute = Int(parts[1]),
      (0...23).contains(hour),
      (0...59).contains(minute)
    else {
      return defaultMinutes
    }
    return hour * 60 + minute
  }
}
enum ReminderDatePlanner {
  static func dates(
    count: Int,
    minutes: Int,
    after now: Date,
    weekdays: Set<ReminderWeekday> = ReminderWeekdays.all,
    calendar: Calendar = .autoupdatingCurrent
  ) -> [Date] {
    guard count > 0 else { return [] }
    let allowedWeekdays = weekdays.intersection(ReminderWeekdays.all)
    guard !allowedWeekdays.isEmpty else { return [] }
    let normalized = ReminderTimeCodec.normalizedMinutes(minutes)
    var matching = DateComponents()
    matching.hour = normalized / 60
    matching.minute = normalized % 60

    var dates: [Date] = []
    var searchDate = now
    let attemptLimit = count * 8 + 8
    var attempts = 0

    while dates.count < count, attempts < attemptLimit {
      guard let candidate = calendar.nextDate(
        after: searchDate,
        matching: matching,
        matchingPolicy: .nextTime,
        repeatedTimePolicy: .first,
        direction: .forward
      ) else {
        break
      }

      if let weekday = ReminderWeekday(calendarWeekday: calendar.component(.weekday, from: candidate)),
         allowedWeekdays.contains(weekday) {
        dates.append(candidate)
      }
      searchDate = candidate.addingTimeInterval(1)
      attempts += 1
    }

    return dates
  }
}

enum ReminderWeekday: Int, Codable, CaseIterable, Hashable {
  case monday = 1
  case tuesday
  case wednesday
  case thursday
  case friday
  case saturday
  case sunday

  init?(calendarWeekday: Int) {
    self.init(rawValue: calendarWeekday == 1 ? 7 : calendarWeekday - 1)
  }

  func shortLabel(language: AppLanguage) -> String {
    switch (language, self) {
    case (.en, .monday): return "M"
    case (.en, .tuesday): return "T"
    case (.en, .wednesday): return "W"
    case (.en, .thursday): return "T"
    case (.en, .friday): return "F"
    case (.en, .saturday): return "S"
    case (.en, .sunday): return "S"
    case (.es, .monday): return "L"
    case (.es, .tuesday): return "M"
    case (.es, .wednesday): return "X"
    case (.es, .thursday): return "J"
    case (.es, .friday): return "V"
    case (.es, .saturday): return "S"
    case (.es, .sunday): return "D"
    }
  }

  func fullLabel(language: AppLanguage) -> String {
    switch (language, self) {
    case (.en, .monday): return "Monday"
    case (.en, .tuesday): return "Tuesday"
    case (.en, .wednesday): return "Wednesday"
    case (.en, .thursday): return "Thursday"
    case (.en, .friday): return "Friday"
    case (.en, .saturday): return "Saturday"
    case (.en, .sunday): return "Sunday"
    case (.es, .monday): return "Lunes"
    case (.es, .tuesday): return "Martes"
    case (.es, .wednesday): return "Miércoles"
    case (.es, .thursday): return "Jueves"
    case (.es, .friday): return "Viernes"
    case (.es, .saturday): return "Sábado"
    case (.es, .sunday): return "Domingo"
    }
  }
}

enum ReminderWeekdays {
  static let all = Set(ReminderWeekday.allCases)

  static func normalized(_ rawValues: [Int]) -> Set<ReminderWeekday> {
    let valid = Set(rawValues.compactMap(ReminderWeekday.init(rawValue:)))
    return valid.isEmpty ? all : valid
  }

  static func persisted(_ values: Set<ReminderWeekday>) -> [Int] {
    let normalized = values.isEmpty ? all : values
    return normalized.map(\.rawValue).sorted()
  }
}

enum CustomQuoteValidator {
  static let maximumLength = 240

  static func normalizedText(_ text: String, category: String, validCategoryIds: Set<String>) -> String? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      !trimmed.isEmpty,
      trimmed.count <= maximumLength,
      validCategoryIds.contains(category)
    else { return nil }
    return trimmed
  }
}

enum CustomCategoryValidator {
  static let maximumLength = 24
  static let maximumCategoryCount = 12

  static func normalizedName(_ name: String, existingNames: [String]) -> String? {
    let normalized = name
      .split(whereSeparator: \.isWhitespace)
      .joined(separator: " ")
    guard !normalized.isEmpty, normalized.count <= maximumLength else { return nil }

    let comparisonName = comparable(normalized)
    guard !existingNames.contains(where: { comparable($0) == comparisonName }) else { return nil }
    return normalized
  }

  private static func comparable(_ value: String) -> String {
    value.folding(
      options: [.caseInsensitive, .diacriticInsensitive],
      locale: Locale(identifier: "en_US")
    )
  }
}
