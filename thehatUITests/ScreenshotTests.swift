import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
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
        let app = XCUIApplication()
        var args = ["--snapshot"]
        if let screen = screen {
            args.append("--snapshot-screen=\(screen)")
        }
        app.launchArguments += args
        app.launch()
    }
}
