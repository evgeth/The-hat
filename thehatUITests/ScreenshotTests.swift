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
