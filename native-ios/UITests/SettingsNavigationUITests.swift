import XCTest

final class SettingsNavigationUITests: XCTestCase {
  func testSettingsButtonOpensClosesAndReopensSettings() {
    let app = XCUIApplication()
    app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    app.launch()

    completeOnboardingIfNeeded(in: app)

    let settingsButton = app.buttons["settings-button"]
    XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
    settingsButton.tap()

    let settingsScreen = app.descendants(matching: .any)["settings-screen"]
    XCTAssertTrue(settingsScreen.waitForExistence(timeout: 5))

    let closeButton = app.buttons["settings-close-button"]
    XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
    closeButton.tap()

    XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
    settingsButton.tap()
    XCTAssertTrue(settingsScreen.waitForExistence(timeout: 5))
  }

  private func completeOnboardingIfNeeded(in app: XCUIApplication) {
    let categoriesStep = app.descendants(matching: .any)["onboarding-categories-step"]
    guard categoriesStep.waitForExistence(timeout: 3) else { return }

    let continueButton = app.buttons["Continue"]
    XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
    continueButton.tap()

    let scheduleStep = app.descendants(matching: .any)["onboarding-schedule-step"]
    XCTAssertTrue(scheduleStep.waitForExistence(timeout: 5))
    let notNowButton = app.buttons["Not now"]
    XCTAssertTrue(notNowButton.waitForExistence(timeout: 5))
    notNowButton.tap()
  }
}
