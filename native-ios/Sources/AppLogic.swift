import Foundation

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
    calendar: Calendar = .autoupdatingCurrent
  ) -> [Date] {
    guard count > 0 else { return [] }
    let normalized = ReminderTimeCodec.normalizedMinutes(minutes)
    var matching = DateComponents()
    matching.hour = normalized / 60
    matching.minute = normalized % 60

    guard let firstDate = calendar.nextDate(
      after: now,
      matching: matching,
      matchingPolicy: .nextTime,
      repeatedTimePolicy: .first,
      direction: .forward
    ) else {
      return []
    }

    return (0..<count).compactMap { offset in
      guard let day = calendar.date(byAdding: .day, value: offset, to: firstDate) else { return nil }
      let startOfDay = calendar.startOfDay(for: day).addingTimeInterval(-1)
      return calendar.nextDate(
        after: startOfDay,
        matching: matching,
        matchingPolicy: .nextTime,
        repeatedTimePolicy: .first,
        direction: .forward
      )
    }
  }
}

enum CustomQuoteValidator {
  static func normalizedText(_ text: String, category: String, validCategoryIds: Set<String>) -> String? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, validCategoryIds.contains(category) else { return nil }
    return trimmed
  }
}