import XCTest
@testable import InspiracionDia

final class AppLogicTests: XCTestCase {
  private var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }

  func testDailyQuoteAdvancesAcrossYearBoundary() throws {
    let first = try XCTUnwrap(calendar.date(from: DateComponents(year: 2025, month: 12, day: 31)))
    let second = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
    let firstIndex = try XCTUnwrap(DailyQuoteSelector.index(for: first, count: 180, calendar: calendar))
    let secondIndex = try XCTUnwrap(DailyQuoteSelector.index(for: second, count: 180, calendar: calendar))
    XCTAssertEqual(secondIndex, (firstIndex + 1) % 180)
  }

  func testDailyQuoteRejectsEmptyCatalog() {
    XCTAssertNil(DailyQuoteSelector.index(for: Date(), count: 0, calendar: calendar))
  }

  func testReminderTimeMigratesStrictValidValue() {
    XCTAssertEqual(ReminderTimeCodec.migrate(legacyValue: "09:05"), 9 * 60 + 5)
  }

  func testReminderTimeRejectsInvalidLegacyValues() {
    XCTAssertEqual(ReminderTimeCodec.migrate(legacyValue: "9"), ReminderTimeCodec.defaultMinutes)
    XCTAssertEqual(ReminderTimeCodec.migrate(legacyValue: "99:99"), ReminderTimeCodec.defaultMinutes)
    XCTAssertEqual(ReminderTimeCodec.migrate(legacyValue: nil), ReminderTimeCodec.defaultMinutes)
  }

  func testReminderMinutesAreClamped() {
    XCTAssertEqual(ReminderTimeCodec.normalizedMinutes(-1), 0)
    XCTAssertEqual(ReminderTimeCodec.normalizedMinutes(10_000), 23 * 60 + 59)
  }

  func testReminderPlannerMakesSixtyUniqueFutureDates() throws {
    let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12)))
    let dates = ReminderDatePlanner.dates(count: 60, minutes: 7 * 60 + 30, after: now, calendar: calendar)
    XCTAssertEqual(dates.count, 60)
    XCTAssertEqual(Set(dates).count, 60)
    XCTAssertTrue(dates.allSatisfy { $0 > now })
    XCTAssertTrue(dates.allSatisfy {
      let components = calendar.dateComponents([.hour, .minute], from: $0)
      return components.hour == 7 && components.minute == 30
    })
  }

  func testReminderPlannerKeepsSixtyUniqueDatesAcrossSpringDST() throws {
    var localCalendar = Calendar(identifier: .gregorian)
    localCalendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
    let now = try XCTUnwrap(
      localCalendar.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 12))
    )
    let dates = ReminderDatePlanner.dates(
      count: 60,
      minutes: 2 * 60 + 30,
      after: now,
      calendar: localCalendar
    )
    XCTAssertEqual(dates.count, 60)
    XCTAssertEqual(Set(dates).count, 60)
    XCTAssertTrue(zip(dates, dates.dropFirst()).allSatisfy { $0.0 < $0.1 })
  }

  func testReminderPlannerUsesFirstOccurrenceAcrossFallDST() throws {
    var localCalendar = Calendar(identifier: .gregorian)
    localCalendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
    let now = try XCTUnwrap(
      localCalendar.date(from: DateComponents(year: 2026, month: 10, day: 31, hour: 12))
    )
    let dates = ReminderDatePlanner.dates(
      count: 3,
      minutes: 90,
      after: now,
      calendar: localCalendar
    )
    XCTAssertEqual(dates.count, 3)
    XCTAssertEqual(Set(dates).count, 3)
    XCTAssertTrue(zip(dates, dates.dropFirst()).allSatisfy { $0.0 < $0.1 })
    let first = try XCTUnwrap(dates.first)
    XCTAssertEqual(localCalendar.timeZone.secondsFromGMT(for: first), -7 * 60 * 60)
  }

  func testCustomQuoteValidation() {
    let categories: Set<String> = ["animo"]
    XCTAssertEqual(
      CustomQuoteValidator.normalizedText("  Keep going.\n", category: "animo", validCategoryIds: categories),
      "Keep going."
    )
    XCTAssertNil(CustomQuoteValidator.normalizedText(" \n", category: "animo", validCategoryIds: categories))
    XCTAssertNil(CustomQuoteValidator.normalizedText("Keep going.", category: "missing", validCategoryIds: categories))
  }
}
