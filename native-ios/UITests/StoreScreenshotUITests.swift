import XCTest

final class StoreScreenshotUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testCaptureEnglishStoreScreenshots() {
    captureStoreScreenshots(
      language: "en",
      locale: "en_US",
      labels: Labels(
        today: "Today",
        categories: "Categories",
        favorites: "Favorites",
        motivation: "Motivation",
        save: "Save",
        newQuote: "New personal quote",
        personal: "Personal",
        addQuote: "Add quote"
      ),
      personalQuote: "Choose one kind thought and let it shape the next small step."
    )
  }

  func testCaptureSpanishStoreScreenshots() {
    captureStoreScreenshots(
      language: "es",
      locale: "es_ES",
      labels: Labels(
        today: "Hoy",
        categories: "Categorías",
        favorites: "Favoritos",
        motivation: "Motivación",
        save: "Guardar",
        newQuote: "Nueva frase personal",
        personal: "Personales",
        addQuote: "Añadir frase"
      ),
      personalQuote: "Elige un pensamiento amable y deja que guíe tu siguiente paso."
    )
  }

  private func captureStoreScreenshots(
    language: String,
    locale: String,
    labels: Labels,
    personalQuote: String
  ) {
    let app = XCUIApplication()
    app.launchArguments += [
      "-AppleLanguages", "(\(language))",
      "-AppleLocale", locale,
      "-language", language,
      "-reminderOnboardingVersion", "1"
    ]
    app.launch()

    XCTAssertTrue(app.tabBars.buttons[labels.today].waitForExistence(timeout: 10))
    capture("01-today-\(language)")

    app.tabBars.buttons[labels.categories].tap()
    XCTAssertTrue(app.buttons[labels.motivation].waitForExistence(timeout: 10))
    capture("02-categories-\(language)")

    app.buttons[labels.motivation].tap()
    app.swipeUp()
    let firstSaveButton = app.buttons[labels.save].firstMatch
    XCTAssertTrue(firstSaveButton.waitForExistence(timeout: 10))
    capture("03-motivation-\(language)")
    firstSaveButton.tap()
    let secondSaveButton = app.buttons[labels.save].firstMatch
    XCTAssertTrue(secondSaveButton.waitForExistence(timeout: 5))
    secondSaveButton.tap()

    app.tabBars.buttons[labels.favorites].tap()
    XCTAssertTrue(app.staticTexts[labels.favorites].firstMatch.waitForExistence(timeout: 10))
    capture("04-favorites-\(language)")

    app.tabBars.buttons[labels.categories].tap()
    let newQuoteButton = app.buttons[labels.newQuote]
    for _ in 0..<4 where !newQuoteButton.exists {
      app.swipeDown()
    }
    XCTAssertTrue(newQuoteButton.waitForExistence(timeout: 10))
    newQuoteButton.tap()

    let editor = app.textViews.firstMatch
    XCTAssertTrue(editor.waitForExistence(timeout: 10))
    editor.tap()
    editor.typeText(personalQuote)
    let addQuoteButton = app.buttons[labels.addQuote]
    XCTAssertTrue(addQuoteButton.isEnabled)
    addQuoteButton.tap()

    XCTAssertTrue(app.buttons[labels.personal].waitForExistence(timeout: 10))
    app.buttons[labels.personal].tap()
    app.swipeUp()
    XCTAssertTrue(app.staticTexts[personalQuote].waitForExistence(timeout: 10))
    capture("05-personal-\(language)")

    app.tabBars.buttons[labels.today].tap()
    let settingsButton = app.buttons["settings-button"]
    XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
    settingsButton.tap()
    XCTAssertTrue(
      app.descendants(matching: .any)["settings-screen"].waitForExistence(timeout: 10)
    )
    for _ in 0..<8 {
      app.swipeUp()
    }
    capture("06-settings-\(language)")
  }

  private func capture(_ name: String) {
    let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private struct Labels {
    let today: String
    let categories: String
    let favorites: String
    let motivation: String
    let save: String
    let newQuote: String
    let personal: String
    let addQuote: String
  }
}
