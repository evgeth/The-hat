import XCTest

final class ScreenshotTests: XCTestCase {

    // Must be the *same* instance throughout: `setupSnapshot` appends
    // -AppleLanguages / -AppleLocale / -FASTLANE_SNAPSHOT to the instance it is
    // handed, and `launchArguments` is per-instance. Launching a freshly
    // constructed XCUIApplication silently discards them, and every locale ends
    // up rendering in the simulator's default language.
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
    }

    func test01Menu() {
        launch(screen: nil)
        snapshot("01-Menu")
    }

    func test02Settings() {
        launch(screen: "settings")
        snapshot("02-Settings")
    }

    func test03Preparation() {
        launch(screen: "preparation")
        snapshot("03-Preparation")
    }

    func test04Round() {
        launch(screen: "round")
        snapshot("04-Round")
    }

    func test05Results() {
        launch(screen: "results")
        snapshot("05-Results")
    }

    private func launch(screen: String?) {
        // Snapfile also supplies --snapshot via launch_arguments; ScreenshotMode
        // matches on `contains`, so a duplicate is harmless and keeps the test
        // working even if that Snapfile entry goes away.
        app.launchArguments.append("--snapshot")
        if let screen = screen {
            app.launchArguments.append("--snapshot-screen=\(screen)")
        }
        app.launch()
    }
}

/// Regression coverage for the original interaction model. Styling must not
/// introduce pause, tap-to-start, automatic review, or new setup controls.
final class OriginalUXTests: XCTestCase {
    private var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--snapshot", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    }

    func testHoldToStartAndManualReviewRemainUnchanged() {
        app.launchArguments.append("--snapshot-screen=preparation")
        app.launch()
        let start = app.staticTexts["handoff.start.label"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        start.tap()
        XCTAssertFalse(app.staticTexts["round.word"].exists)
        XCTAssertTrue(app.staticTexts["Hold to start"].exists)
        start.press(forDuration: 2.0)
        XCTAssertTrue(app.staticTexts["round.word"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["round.pause"].exists)
        XCTAssertFalse(app.buttons["Pause"].exists)
        app.buttons["round.guessed"].tap()
        app.staticTexts["Mistake"].tap()
        XCTAssertTrue(app.staticTexts["round.word"].exists)
        app.staticTexts["Mistake"].press(forDuration: 0.8)
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["review.save"].exists)
        app.buttons["handoff.review"].tap()
        XCTAssertTrue(app.buttons["review.save"].waitForExistence(timeout: 5))
        app.buttons["review.save"].tap()
        XCTAssertTrue(start.waitForExistence(timeout: 5))
    }

    func testSetupKeepsPickerAndOriginalConfirmation() {
        app.launchArguments.append("--snapshot-screen=settings")
        app.launch()
        XCTAssertTrue(app.buttons["setup.done"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.pickerWheels.count, 1)
        XCTAssertFalse(app.buttons["setup.continue"].exists)
        XCTAssertFalse(app.buttons["setup.editPlayers"].exists)
        XCTAssertTrue(app.buttons["setup.addPlayer"].exists)
        app.buttons["setup.done"].tap()
        XCTAssertTrue(app.staticTexts["You can add your words in the hat"].waitForExistence(timeout: 5))
    }

    func testNormalLaunchAndLanguageSwitchUseTheVisibleWindow() {
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.staticTexts["The Hat"].waitForExistence(timeout: 10))
        app.buttons["English"].tap()
        XCTAssertTrue(app.staticTexts["Шляпа"].waitForExistence(timeout: 5))
        app.buttons["Русский"].tap()
        XCTAssertTrue(app.staticTexts["The Hat"].waitForExistence(timeout: 5))
    }
}
