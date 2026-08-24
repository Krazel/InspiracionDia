import Foundation

enum AppLanguage: String, CaseIterable, Hashable, Codable {
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

enum SharedQuoteKind: String, Codable, Hashable {
  case builtIn = "b"
  case personal = "p"
}

struct SharedQuotePayload: Codable, Hashable, Identifiable {
  static let currentVersion = 1

  let version: Int
  let kind: SharedQuoteKind
  let quoteID: String?
  let text: String?
  let language: AppLanguage?

  private enum CodingKeys: String, CodingKey {
    case version = "v"
    case kind = "k"
    case quoteID = "i"
    case text = "t"
    case language = "l"
  }

  var id: String {
    switch kind {
    case .builtIn:
      return "built-in:\(quoteID ?? "")"
    case .personal:
      return "personal:\(text ?? "")"
    }
  }

  static func builtIn(id: String, language: AppLanguage? = nil) -> SharedQuotePayload {
    SharedQuotePayload(
      version: currentVersion,
      kind: .builtIn,
      quoteID: id,
      text: nil,
      language: language
    )
  }

  static func personal(text: String, language: AppLanguage? = nil) -> SharedQuotePayload {
    SharedQuotePayload(
      version: currentVersion,
      kind: .personal,
      quoteID: nil,
      text: text,
      language: language
    )
  }

  var validated: SharedQuotePayload? {
    guard version == Self.currentVersion else { return nil }
    switch kind {
    case .builtIn:
      guard
        let quoteID,
        !quoteID.isEmpty,
        quoteID.count <= 64,
        quoteID.unicodeScalars.allSatisfy({
          CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_")).contains($0)
        })
      else {
        return nil
      }
      return .builtIn(id: quoteID, language: language)
    case .personal:
      guard let text = CustomQuoteValidator.normalizedText(
        text ?? "",
        category: "custom",
        validCategoryIds: ["custom"]
      ) else {
        return nil
      }
      return .personal(
        text: text.precomposedStringWithCanonicalMapping,
        language: language
      )
    }
  }
}

enum SharedQuoteImporter {
  static func personalQuote(
    text: String,
    existing: [Quote],
    makeID: () -> String = { "custom-\(UUID().uuidString)" }
  ) -> (quote: Quote, isNew: Bool) {
    let normalized = text.precomposedStringWithCanonicalMapping
    if let quote = existing.first(where: {
      $0.text.precomposedStringWithCanonicalMapping == normalized
    }) {
      return (quote, false)
    }
    return (Quote(id: makeID(), category: "custom", text: normalized), true)
  }
}

enum ShareLinkRoute {
  static let landingPageURL = URL(string: "https://krazel.github.io/warm-words/share/")!
  static let customScheme = "warmwords"
  static let isPublicLinkEnabled = false
  private static let fragmentPrefix = "ww="
  private static let maximumEncodedPayloadLength = 2_048

  static func shareURL(for payload: SharedQuotePayload) -> URL? {
    guard let payload = payload.validated,
          let data = try? JSONEncoder().encode(payload) else {
      return nil
    }
    let encoded = data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
    guard encoded.count <= maximumEncodedPayloadLength else { return nil }
    return URL(string: landingPageURL.absoluteString + "#" + fragmentPrefix + encoded)
  }

  static func payload(from url: URL) -> SharedQuotePayload? {
    guard handles(url),
          let fragment = url.fragment,
          fragment.hasPrefix(fragmentPrefix) else {
      return nil
    }
    let encoded = String(fragment.dropFirst(fragmentPrefix.count))
    guard !encoded.isEmpty, encoded.count <= maximumEncodedPayloadLength else { return nil }
    var base64 = encoded
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let padding = (4 - base64.count % 4) % 4
    base64.append(String(repeating: "=", count: padding))
    guard
      let data = Data(base64Encoded: base64),
      data.count <= 1_536,
      let decoded = try? JSONDecoder().decode(SharedQuotePayload.self, from: data)
    else {
      return nil
    }
    return decoded.validated
  }

  static func handles(_ url: URL) -> Bool {
    if url.scheme?.lowercased() == customScheme {
      return url.host?.lowercased() == "share" || url.host?.lowercased() == "open"
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

struct QuoteCycleStep: Equatable {
  let quoteID: String
  let history: [String]
}

struct ScheduledQuoteAssignment: Codable, Equatable {
  let quoteID: String
  let deliveryDate: Date
}

enum QuoteCyclePlanner {
  static func next(candidateIDs: [String], history: [String]) -> QuoteCycleStep? {
    let orderedIDs = orderedUniqueIDs(candidateIDs)
    guard !orderedIDs.isEmpty else { return nil }

    let eligibleIDs = Set(orderedIDs)
    var uniqueHistory: [String] = []
    var knownHistoryIDs = Set<String>()
    for id in history where knownHistoryIDs.insert(id).inserted {
      uniqueHistory.append(id)
    }
    let nextID = orderedIDs.first(where: { !knownHistoryIDs.contains($0) }) ??
      uniqueHistory.first(where: { eligibleIDs.contains($0) }) ??
      orderedIDs[0]
    uniqueHistory.removeAll { $0 == nextID }
    uniqueHistory.append(nextID)
    return QuoteCycleStep(quoteID: nextID, history: uniqueHistory)
  }

  static func sequence(
    candidateIDs: [String],
    history: [String],
    count: Int
  ) -> [String] {
    guard count > 0 else { return [] }
    var sequence: [String] = []
    var nextHistory = history
    for _ in 0..<count {
      guard let step = next(candidateIDs: candidateIDs, history: nextHistory) else { break }
      sequence.append(step.quoteID)
      nextHistory = step.history
    }
    return sequence
  }

  private static func orderedUniqueIDs(_ candidateIDs: [String]) -> [String] {
    Array(Set(candidateIDs)).sorted { lhs, rhs in
      let leftRank = stableRank(lhs)
      let rightRank = stableRank(rhs)
      return leftRank == rightRank ? lhs < rhs : leftRank < rightRank
    }
  }

  private static func stableRank(_ value: String) -> UInt64 {
    value.utf8.reduce(UInt64(14_695_981_039_346_656_037)) { hash, byte in
      (hash ^ UInt64(byte)) &* 1_099_511_628_211
    }
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

enum ReminderOnboardingStep: Hashable {
  case categories
  case schedule
}

struct ReminderDeliverySelection: Equatable {
  let categoryIds: Set<String>
  let usesAllCategories: Bool

  static func toggling(
    categoryId: String,
    current: Set<String>,
    allCategoryIds: Set<String>,
    usesAllCategories: Bool
  ) -> ReminderDeliverySelection {
    guard !allCategoryIds.isEmpty, allCategoryIds.contains(categoryId) else {
      return ReminderDeliverySelection(
        categoryIds: usesAllCategories ? [] : current.intersection(allCategoryIds),
        usesAllCategories: usesAllCategories
      )
    }
    var next = usesAllCategories ? allCategoryIds : current.intersection(allCategoryIds)
    if next.contains(categoryId) {
      next.remove(categoryId)
    } else {
      next.insert(categoryId)
    }
    if next == allCategoryIds {
      return ReminderDeliverySelection(categoryIds: [], usesAllCategories: true)
    }
    return ReminderDeliverySelection(categoryIds: next, usesAllCategories: false)
  }
}

enum ReminderDeliveryValidator {
  static func resolvedCategories(
    requested: Set<String>,
    validCategoryIds: Set<String>,
    useAllCategories: Bool,
    reminderEnabled: Bool
  ) -> Set<String>? {
    if useAllCategories {
      return []
    }
    let resolved = requested.intersection(validCategoryIds)
    return reminderEnabled && resolved.isEmpty ? nil : resolved
  }
}

enum CustomQuoteValidator {
  static let maximumLength = 240
  private static let bidirectionalFormattingScalars: Set<UInt32> = [
    0x061C, 0x200E, 0x200F,
    0x202A, 0x202B, 0x202C, 0x202D, 0x202E,
    0x2066, 0x2067, 0x2068, 0x2069
  ]

  static func normalizedText(_ text: String, category: String, validCategoryIds: Set<String>) -> String? {
    let trimmed = text
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
      .replacingOccurrences(of: "\t", with: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .precomposedStringWithCanonicalMapping
    guard
      !trimmed.isEmpty,
      trimmed.count <= maximumLength,
      validCategoryIds.contains(category),
      !trimmed.unicodeScalars.contains(where: isUnsafeForSharing)
    else { return nil }
    return trimmed
  }

  private static func isUnsafeForSharing(_ scalar: Unicode.Scalar) -> Bool {
    if bidirectionalFormattingScalars.contains(scalar.value) {
      return true
    }
    return scalar.value != 0x0A && CharacterSet.controlCharacters.contains(scalar)
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
