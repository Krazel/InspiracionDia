import XCTest
@testable import InspiracionDia

final class AppLogicTests: XCTestCase {
  private var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }

  func testLanguageUsesSavedChoiceBeforeDeviceLanguage() {
    XCTAssertEqual(
      AppLanguage.resolved(savedValue: "es", preferredLanguages: ["en-US"]),
      .es
    )
    XCTAssertEqual(
      AppLanguage.resolved(savedValue: "en", preferredLanguages: ["es-ES"]),
      .en
    )
  }

  func testLanguageDefaultsToSpanishForSpanishDeviceVariants() {
    XCTAssertEqual(AppLanguage.resolved(savedValue: nil, preferredLanguages: ["es-ES"]), .es)
    XCTAssertEqual(AppLanguage.resolved(savedValue: nil, preferredLanguages: ["es-MX"]), .es)
    XCTAssertEqual(AppLanguage.resolved(savedValue: nil, preferredLanguages: ["en-US"]), .en)
    XCTAssertEqual(AppLanguage.resolved(savedValue: nil, preferredLanguages: []), .en)
  }

  func testShareLinkRoutingAcceptsOnlyWarmWordsDestinations() {
    XCTAssertTrue(ShareLinkRoute.handles(ShareLinkRoute.landingPageURL))
    XCTAssertTrue(ShareLinkRoute.handles(URL(string: "warmwords://open")!))
    XCTAssertFalse(ShareLinkRoute.handles(URL(string: "https://example.com/warm-words/share/")!))
    XCTAssertFalse(ShareLinkRoute.handles(URL(string: "https://krazel.github.io/another-app/")!))
    XCTAssertFalse(ShareLinkRoute.handles(URL(string: "https://krazel.github.io/warm-words/share-elsewhere")!))
  }

  func testBuiltInShareLinkRoundTripsStableIDAndLanguage() throws {
    let payload = SharedQuotePayload.builtIn(id: "animo-001", language: .es)
    let url = try XCTUnwrap(ShareLinkRoute.shareURL(for: payload))
    XCTAssertEqual(ShareLinkRoute.payload(from: url), payload)
    XCTAssertEqual(url.host, "krazel.github.io")
    XCTAssertEqual(url.path, "/warm-words/share")
    XCTAssertTrue(url.fragment?.hasPrefix("ww=") == true)
  }

  func testPersonalShareLinkRoundTripsUnicodeWithoutServerQuery() throws {
    let payload = SharedQuotePayload.personal(
      text: "Respira: este paso también cuenta.",
      language: .es
    )
    let url = try XCTUnwrap(ShareLinkRoute.shareURL(for: payload))
    XCTAssertEqual(ShareLinkRoute.payload(from: url), payload)
    XCTAssertNil(url.query)
    XCTAssertNotNil(url.fragment)
  }

  func testPersonalShareLinkNormalizesAndRejectsUnsafeText() throws {
    let decomposed = "Cafe\u{301}"
    let normalizedURL = try XCTUnwrap(
      ShareLinkRoute.shareURL(for: .personal(text: decomposed, language: .en))
    )
    XCTAssertEqual(
      ShareLinkRoute.payload(from: normalizedURL)?.text,
      decomposed.precomposedStringWithCanonicalMapping
    )
    XCTAssertNil(ShareLinkRoute.shareURL(for: .personal(text: "Hello\u{0000}", language: .en)))
    XCTAssertNil(ShareLinkRoute.shareURL(for: .personal(text: "safe\u{202E}txt", language: .en)))
    XCTAssertNil(
      ShareLinkRoute.shareURL(
        for: .personal(
          text: String(repeating: "a", count: CustomQuoteValidator.maximumLength + 1),
          language: .en
        )
      )
    )
  }

  func testPersonalShareLinkPreservesMultipleLines() throws {
    let payload = SharedQuotePayload.personal(
      text: "Take one step.\r\nThen take another.",
      language: .en
    )
    let url = try XCTUnwrap(ShareLinkRoute.shareURL(for: payload))
    XCTAssertEqual(
      ShareLinkRoute.payload(from: url)?.text,
      "Take one step.\nThen take another."
    )
  }

  func testPersonalShareImportCreatesOnceAndDeduplicatesUnicode() {
    let created = SharedQuoteImporter.personalQuote(
      text: "Café",
      existing: [],
      makeID: { "custom-test" }
    )
    XCTAssertTrue(created.isNew)
    XCTAssertEqual(created.quote.id, "custom-test")
    XCTAssertEqual(created.quote.category, "custom")

    let duplicate = SharedQuoteImporter.personalQuote(
      text: "Cafe\u{301}",
      existing: [created.quote],
      makeID: { "custom-should-not-be-used" }
    )
    XCTAssertFalse(duplicate.isNew)
    XCTAssertEqual(duplicate.quote, created.quote)
  }

  func testShareLinkRejectsMalformedUnknownAndUnversionedPayloads() throws {
    XCTAssertNil(ShareLinkRoute.payload(from: ShareLinkRoute.landingPageURL))
    XCTAssertNil(
      ShareLinkRoute.payload(
        from: URL(string: "https://krazel.github.io/warm-words/share/#ww=not-base64")!
      )
    )
    let future = SharedQuotePayload(
      version: SharedQuotePayload.currentVersion + 1,
      kind: .builtIn,
      quoteID: "animo-001",
      text: nil,
      language: .en
    )
    XCTAssertNil(ShareLinkRoute.shareURL(for: future))
    let validURL = try XCTUnwrap(
      ShareLinkRoute.shareURL(for: .builtIn(id: "animo-001", language: .en))
    )
    let foreignURL = URL(string: validURL.absoluteString.replacingOccurrences(
      of: "krazel.github.io",
      with: "example.com"
    ))!
    XCTAssertNil(ShareLinkRoute.payload(from: foreignURL))
  }

  func testWeekdayLabelsAreLocalizedWithoutChangingScheduleValues() {
    XCTAssertEqual(ReminderWeekday.monday.shortLabel(language: .en), "M")
    XCTAssertEqual(ReminderWeekday.monday.shortLabel(language: .es), "L")
    XCTAssertEqual(ReminderWeekday.wednesday.shortLabel(language: .es), "X")
    XCTAssertEqual(ReminderWeekday.saturday.fullLabel(language: .es), "Sábado")
    XCTAssertEqual(ReminderWeekday.saturday.rawValue, 6)
  }

  func testDailyQuoteAdvancesAcrossYearBoundary() throws {
    let first = try XCTUnwrap(calendar.date(from: DateComponents(year: 2025, month: 12, day: 31)))
    let second = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)))
    let firstIndex = try XCTUnwrap(DailyQuoteSelector.index(for: first, count: 360, calendar: calendar))
    let secondIndex = try XCTUnwrap(DailyQuoteSelector.index(for: second, count: 360, calendar: calendar))
    XCTAssertEqual(secondIndex, (firstIndex + 1) % 360)
  }

  func testDailyQuoteRejectsEmptyCatalog() {
    XCTAssertNil(DailyQuoteSelector.index(for: Date(), count: 0, calendar: calendar))
  }

  func testQuoteCycleUsesEveryEligibleQuoteBeforeRepeating() {
    let sequence = QuoteCyclePlanner.sequence(
      candidateIDs: ["animo-001", "foco-001", "calma-001"],
      history: [],
      count: 4
    )
    XCTAssertEqual(Set(sequence.prefix(3)).count, 3)
    XCTAssertEqual(sequence[3], sequence[0])
  }

  func testQuoteCycleContinuesFromPersistedHistory() throws {
    let first = try XCTUnwrap(
      QuoteCyclePlanner.next(candidateIDs: ["a", "b", "c"], history: [])
    )
    let second = try XCTUnwrap(
      QuoteCyclePlanner.next(candidateIDs: ["a", "b", "c"], history: first.history)
    )
    XCTAssertNotEqual(first.quoteID, second.quoteID)
    XCTAssertEqual(Array(second.history.suffix(2)), [first.quoteID, second.quoteID])
  }

  func testQuoteCyclePreservesHistoryAcrossCategoryChanges() throws {
    let priorHistory = ["animo-001", "foco-001", "animo-002"]
    let focusOnly = try XCTUnwrap(
      QuoteCyclePlanner.next(
        candidateIDs: ["foco-001", "foco-002"],
        history: priorHistory
      )
    )
    XCTAssertEqual(focusOnly.quoteID, "foco-002")
    XCTAssertTrue(focusOnly.history.contains("animo-001"))
    XCTAssertTrue(focusOnly.history.contains("animo-002"))
  }

  func testQuoteCycleReminderSequenceDoesNotRepeatBeforeExhaustion() {
    let ids = (1...60).map { "foco-\(String(format: "%03d", $0))" }
    let sequence = QuoteCyclePlanner.sequence(candidateIDs: ids, history: [], count: 120)
    XCTAssertEqual(sequence.count, 120)
    XCTAssertEqual(Set(sequence.prefix(60)).count, 60)
    XCTAssertEqual(Array(sequence.prefix(60)), Array(sequence.suffix(60)))
  }

  func testQuoteCycleLargeCatalogPlansReminderWindowWithoutRepeating() {
    let ids = (1...720).map { "quote-\(String(format: "%03d", $0))" }
    let sequence = QuoteCyclePlanner.sequence(candidateIDs: ids, history: [], count: 60)
    XCTAssertEqual(sequence.count, 60)
    XCTAssertEqual(Set(sequence).count, 60)
  }

  func testQuoteCycleSequencePreservesLeastRecentlySeenOrder() {
    XCTAssertEqual(
      QuoteCyclePlanner.sequence(
        candidateIDs: ["a", "b", "c"],
        history: ["outside", "b", "a", "c", "b"],
        count: 4
      ),
      ["b", "a", "c", "b"]
    )
  }

  func testQuoteCycleRejectsEmptyCandidates() {
    XCTAssertNil(QuoteCyclePlanner.next(candidateIDs: [], history: ["old"]))
    XCTAssertTrue(QuoteCyclePlanner.sequence(candidateIDs: [], history: [], count: 60).isEmpty)
  }

  func testQuoteCycleChoosesLeastRecentlySeenAfterExhaustion() throws {
    let next = try XCTUnwrap(
      QuoteCyclePlanner.next(
        candidateIDs: ["calma-001", "calma-002", "calma-003"],
        history: ["calma-002", "calma-001", "calma-003"]
      )
    )
    XCTAssertEqual(next.quoteID, "calma-002")
    XCTAssertEqual(Array(next.history.suffix(3)), ["calma-001", "calma-003", "calma-002"])
  }

  func testQuoteCycleSanitizesDuplicateCandidatesAndHistory() throws {
    let next = try XCTUnwrap(
      QuoteCyclePlanner.next(
        candidateIDs: ["a", "a", "b"],
        history: ["outside", "a", "a"]
      )
    )
    XCTAssertEqual(next.quoteID, "b")
    XCTAssertEqual(next.history.filter { $0 == "a" }.count, 1)
    XCTAssertEqual(next.history.filter { $0 == "b" }.count, 1)
    XCTAssertTrue(next.history.contains("outside"))
  }

  func testScheduledQuoteAssignmentRoundTripsThroughPersistenceEncoding() throws {
    let assignment = ScheduledQuoteAssignment(
      quoteID: "foco-001",
      deliveryDate: try XCTUnwrap(
        calendar.date(from: DateComponents(year: 2026, month: 8, day: 24, hour: 7, minute: 30))
      )
    )
    let data = try JSONEncoder().encode([assignment])
    XCTAssertEqual(try JSONDecoder().decode([ScheduledQuoteAssignment].self, from: data), [assignment])
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

  func testReminderPlannerUsesOnlySelectedWeekdays() throws {
    let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12)))
    let mondayAndWednesday: Set<ReminderWeekday> = [.monday, .wednesday]
    let dates = ReminderDatePlanner.dates(
      count: 60,
      minutes: 7 * 60 + 30,
      after: now,
      weekdays: mondayAndWednesday,
      calendar: calendar
    )
    XCTAssertEqual(dates.count, 60)
    XCTAssertEqual(Set(dates).count, 60)
    XCTAssertTrue(dates.allSatisfy {
      guard let weekday = ReminderWeekday(calendarWeekday: calendar.component(.weekday, from: $0)) else {
        return false
      }
      return mondayAndWednesday.contains(weekday)
    })
  }

  func testReminderPlannerRejectsEmptyWeekdaySelection() {
    XCTAssertTrue(
      ReminderDatePlanner.dates(
        count: 60,
        minutes: ReminderTimeCodec.defaultMinutes,
        after: Date(),
        weekdays: [],
        calendar: calendar
      ).isEmpty
    )
  }

  func testReminderPlannerProducesSixtyMondays() throws {
    let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12)))
    let dates = ReminderDatePlanner.dates(
      count: 60,
      minutes: ReminderTimeCodec.defaultMinutes,
      after: now,
      weekdays: [.monday],
      calendar: calendar
    )
    XCTAssertEqual(dates.count, 60)
    XCTAssertTrue(dates.allSatisfy { calendar.component(.weekday, from: $0) == 2 })
    let first = try XCTUnwrap(dates.first)
    let last = try XCTUnwrap(dates.last)
    XCTAssertGreaterThan(last.timeIntervalSince(first), 400 * 86_400)
  }

  func testReminderWeekdaysNormalizeToEveryDay() {
    XCTAssertEqual(ReminderWeekdays.normalized([]), ReminderWeekdays.all)
    XCTAssertEqual(ReminderWeekdays.normalized([0, 1, 8]), [.monday])
    XCTAssertEqual(ReminderWeekdays.persisted([.sunday, .monday]), [1, 7])
    XCTAssertEqual(ReminderWeekday(calendarWeekday: 1), .sunday)
    XCTAssertEqual(ReminderWeekday(calendarWeekday: 2), .monday)
  }

  func testReminderDeliveryDefaultsToAllCategories() {
    XCTAssertEqual(
      ReminderDeliveryValidator.resolvedCategories(
        requested: [],
        validCategoryIds: ["animo", "foco"],
        useAllCategories: true,
        reminderEnabled: true
      ),
      []
    )
  }

  func testReminderDeliveryFiltersSpecificCategoriesAndRejectsEmptyEnabledSelection() {
    XCTAssertEqual(
      ReminderDeliveryValidator.resolvedCategories(
        requested: ["animo", "removed"],
        validCategoryIds: ["animo", "foco"],
        useAllCategories: false,
        reminderEnabled: true
      ),
      ["animo"]
    )
    XCTAssertNil(
      ReminderDeliveryValidator.resolvedCategories(
        requested: ["removed"],
        validCategoryIds: ["animo", "foco"],
        useAllCategories: false,
        reminderEnabled: true
      )
    )
  }

  func testReminderDeliveryAllowsEmptySpecificSelectionWhenReminderIsOff() {
    XCTAssertEqual(
      ReminderDeliveryValidator.resolvedCategories(
        requested: [],
        validCategoryIds: ["animo", "foco"],
        useAllCategories: false,
        reminderEnabled: false
      ),
      []
    )
  }

  func testReminderDeliveryRejectsPersonalWhenItHasNoQuotes() {
    XCTAssertNil(
      ReminderDeliveryValidator.resolvedCategories(
        requested: ["custom"],
        validCategoryIds: ["animo", "foco"],
        useAllCategories: false,
        reminderEnabled: true
      )
    )
  }

  func testReminderInterestSelectionStartsWithAllAndDeselectsOneCategory() {
    let result = ReminderDeliverySelection.toggling(
      categoryId: "foco",
      current: [],
      allCategoryIds: ["animo", "foco", "calma"],
      usesAllCategories: true
    )
    XCTAssertFalse(result.usesAllCategories)
    XCTAssertEqual(result.categoryIds, ["animo", "calma"])
  }

  func testReminderInterestSelectionCanonicalizesAllCategories() {
    let result = ReminderDeliverySelection.toggling(
      categoryId: "foco",
      current: ["animo", "calma"],
      allCategoryIds: ["animo", "foco", "calma"],
      usesAllCategories: false
    )
    XCTAssertTrue(result.usesAllCategories)
    XCTAssertEqual(result.categoryIds, [])
  }

  func testCustomQuoteValidation() {
    let categories: Set<String> = ["custom"]
    XCTAssertEqual(
      CustomQuoteValidator.normalizedText("  Keep going.\n", category: "custom", validCategoryIds: categories),
      "Keep going."
    )
    XCTAssertNil(CustomQuoteValidator.normalizedText(" \n", category: "custom", validCategoryIds: categories))
    XCTAssertNil(CustomQuoteValidator.normalizedText("Keep going.", category: "missing", validCategoryIds: categories))
    XCTAssertNil(
      CustomQuoteValidator.normalizedText(
        String(repeating: "a", count: CustomQuoteValidator.maximumLength + 1),
        category: "custom",
        validCategoryIds: categories
      )
    )
  }

  func testCustomCategoryValidation() {
    XCTAssertEqual(
      CustomCategoryValidator.normalizedName("  Morning   focus  ", existingNames: ["Calm"]),
      "Morning focus"
    )
    XCTAssertNil(CustomCategoryValidator.normalizedName(" ", existingNames: []))
    XCTAssertNil(CustomCategoryValidator.normalizedName("calm", existingNames: ["Calm"]))
    XCTAssertNil(CustomCategoryValidator.normalizedName("CAFÉ", existingNames: ["Cafe"]))
    XCTAssertNil(
      CustomCategoryValidator.normalizedName(
        String(repeating: "a", count: CustomCategoryValidator.maximumLength + 1),
        existingNames: []
      )
    )
  }

  func testNotificationPlanUsesUniqueOwnedIdentifiersAndVisibleDelay() {
    let first = TestNotificationPlan.identifier(
      uuid: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    )
    let second = TestNotificationPlan.identifier(
      uuid: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    )

    XCTAssertNotEqual(first, second)
    XCTAssertTrue(TestNotificationPlan.isTestIdentifier(first))
    XCTAssertFalse(TestNotificationPlan.isTestIdentifier("daily-inspiration-1"))
    XCTAssertEqual(TestNotificationPlan.delay, 5)
  }
}
