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
        XCTAssertEqual(start.label, "Hold to Start")
        start.tap()
        XCTAssertFalse(app.staticTexts["round.word"].exists)
        XCTAssertEqual(start.label, "Hold to Start")
        start.press(forDuration: 2.0)
        XCTAssertTrue(app.staticTexts["round.word"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["round.pause"].exists)
        XCTAssertFalse(app.buttons["Pause"].exists)
        app.buttons["round.guessed"].tap()
        XCTAssertEqual(app.staticTexts["round.actionHint"].label, "Hold to end turn")
        app.staticTexts["Mistake"].tap()
        XCTAssertEqual(app.staticTexts["round.actionHint"].label, "Keep holding to end turn")
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

/// Exercise the real Rules pager and the secondary screens which previously
/// retained the old design. Attachments are also the bilingual review gallery.
final class WholeAppVisualTests: XCTestCase {
    private func launch(_ language: String, screen: String, motion: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--snapshot", "--snapshot-screen=\(screen)", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "ru" ? "ru_RU" : "en_US"]
        if motion { app.launchArguments.append("--snapshot-motion") }
        app.launch()
        return app
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }

    func testRulesPagesAndFinalAction() {
        for language in ["en", "ru"] {
            let app = launch(language, screen: "menu")
            app.buttons["menu.rules"].tap()
            let heading = app.staticTexts["rules.heading"]
            XCTAssertTrue(heading.waitForExistence(timeout: 5))
            XCTAssertEqual(heading.label, language == "ru" ? "Правила" : "Rules")
            let headerFrame = heading.frame
            let dots = app.pageIndicators.firstMatch
            XCTAssertTrue(dots.exists)
            let firstPageValue = dots.value as? String
            for page in 1...7 {
                let title = app.staticTexts["rules.title.\(page)"]
                XCTAssertTrue(title.waitForExistence(timeout: 5))
                XCTAssertEqual(heading.frame, headerFrame)
                XCTAssertLessThan(headerFrame.maxY, title.frame.minY)
                XCTAssertGreaterThan(dots.frame.minY, title.frame.maxY)
                if page == 2 {
                    XCTAssertNotEqual(dots.value as? String, firstPageValue)
                    app.swipeRight()
                    XCTAssertTrue(app.staticTexts["rules.title.1"].waitForExistence(timeout: 5))
                    XCTAssertEqual(dots.value as? String, firstPageValue)
                    app.swipeLeft()
                    XCTAssertTrue(title.waitForExistence(timeout: 5))
                }
                XCTAssertGreaterThanOrEqual(title.frame.minX, 20, "Rule copy must stay inside the left margin")
                XCTAssertLessThanOrEqual(title.frame.maxX, app.frame.maxX - 20, "Rule copy must stay inside the right margin")
                capture(app, "warm-\(language)-rule-\(page)")
                if page < 7 { app.swipeLeft() }
            }
            app.buttons["rules.newGame"].tap()
            XCTAssertTrue(app.buttons["setup.done"].waitForExistence(timeout: 5))
        }
    }

    func testHistoryOpensAndReturnsToMenu() {
        let app = launch("en", screen: "menu", motion: true)
        let history = app.buttons["menu.history"]
        for useEdgeSwipe in [false, true] {
            history.tap()
            let bar = app.navigationBars.firstMatch
            let back = bar.buttons.firstMatch
            XCTAssertTrue(back.waitForExistence(timeout: 5))
            XCTAssertTrue(bar.staticTexts["History"].exists)
            if useEdgeSwipe {
                let edge = app.coordinate(withNormalizedOffset: CGVector(dx: 0.005, dy: 0.5))
                edge.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)))
            } else {
                capture(app, "history-navigation")
                back.tap()
            }
            XCTAssertTrue(history.waitForExistence(timeout: 5))
        }
    }

    func testPlayerNamesRemainAlignedAfterReorderAndModeChange() {
        let app = launch("en", screen: "settings")
        let table = app.tables["setup.players"]
        let first = table.cells.element(boundBy: 0)
        let third = table.cells.element(boundBy: 2)
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        let handle = first.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        handle.press(forDuration: 0.8, thenDragTo: third.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.8)))
        XCTAssertEqual(first.textFields.firstMatch.value as? String, "Bob")
        app.buttons["Pairs"].tap()
        let fields = table.textFields.matching(identifier: "setup.playerName")
        XCTAssertEqual(fields.count, 4)
        for cell in table.cells.allElementsBoundByIndex where cell.textFields.count > 0 {
            XCTAssertGreaterThanOrEqual(cell.textFields.firstMatch.frame.minX - cell.frame.minX, 55)
        }
    }

    func testNewGameOutsideTapAndHandoffNavigation() {
        let app = launch("en", screen: "settings")
        let names = app.tables["setup.players"].textFields.matching(identifier: "setup.playerName")
        names.element(boundBy: 0).tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        names.element(boundBy: 1).tap()
        names.element(boundBy: 1).typeText("son")
        XCTAssertTrue((names.element(boundBy: 1).value as? String)?.contains("son") == true)
        app.staticTexts["Players:"].tap()
        let hidden = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.keyboards.firstMatch)
        wait(for: [hidden], timeout: 5)
        names.element(boundBy: 0).tap()
        app.buttons["setup.done"].tap()
        XCTAssertTrue(app.textFields["words.field"].waitForExistence(timeout: 5))
        for language in ["en", "ru"] {
            let handoff = launch(language, screen: "preparation")
            let count = handoff.staticTexts["handoff.wordsLeft"], close = handoff.buttons["handoff.menu"]
            XCTAssertTrue(count.waitForExistence(timeout: 5)); XCTAssertTrue(close.exists)
            XCTAssertLessThan(count.frame.maxX + 8, close.frame.minX)
            capture(handoff, "warm-\(language)-preparation")
            close.tap()
            // Recent iOS presents the anchored options as a popover and
            // dismisses it on outside tap instead of displaying Cancel.
            XCTAssertTrue(handoff.buttons[language == "ru" ? "Завершить игру" : "Finish game"].waitForExistence(timeout: 5))
        }
    }

    func testDeletingPlayersInPairsAndStartingWithRemainingPair() {
        continueAfterFailure = false
        let app = launch("en", screen: "settings", motion: true)
        let table = app.tables["setup.players"]
        app.buttons["Pairs"].tap()

        func deletePlayer(at row: Int, named name: String) {
            let cell = table.cells.element(boundBy: row)
            let field = cell.textFields["setup.playerName"]
            XCTAssertTrue(field.waitForExistence(timeout: 5))
            XCTAssertEqual(field.value as? String, name)
            cell.swipeLeft()
            let button = cell.buttons["Delete"]
            XCTAssertTrue(button.waitForExistence(timeout: 3), table.debugDescription)
            button.tap()
        }

        deletePlayer(at: 2, named: "Carol")
        XCTAssertEqual(table.textFields.allElementsBoundByIndex.compactMap { $0.value as? String }, ["Alice", "Bob", "David"])
        app.buttons["setup.done"].tap()
        XCTAssertTrue(app.alerts.staticTexts["Each pair should have exactly 2 players"].exists)
        app.alerts.buttons.firstMatch.tap()
        deletePlayer(at: 2, named: "David")
        XCTAssertEqual(table.textFields.allElementsBoundByIndex.compactMap { $0.value as? String }, ["Alice", "Bob"])
        deletePlayer(at: 1, named: "Bob")
        XCTAssertTrue(app.alerts.staticTexts["You need at least two players."].exists)
        app.alerts.buttons.firstMatch.tap()
        app.buttons["setup.done"].tap()
        app.navigationBars.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts["handoff.start.label"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Alice"].exists)
        XCTAssertTrue(app.staticTexts["Bob"].exists)
        app.staticTexts["handoff.start.label"].press(forDuration: 2)
        app.buttons["round.guessed"].tap()
        app.staticTexts["Mistake"].press(forDuration: 0.8)
        app.buttons["handoff.review"].tap()
        XCTAssertTrue(app.tables.cells.firstMatch.waitForExistence(timeout: 5))
        app.buttons["review.save"].tap()
        app.buttons["handoff.menu"].tap()
        app.buttons["Finish game"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Results"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tables.staticTexts["Alice"].exists)
        XCTAssertTrue(app.tables.staticTexts["Bob"].exists)
        app.navigationBars.buttons["Done"].tap()
        app.buttons["menu.history"].tap()
        let latest = app.tables.cells.firstMatch
        XCTAssertTrue(latest.staticTexts["Alice"].waitForExistence(timeout: 5))
        XCTAssertTrue(latest.staticTexts["Bob"].exists)
    }

    func testAddingPairsAndSwitchingModesWithDeleteRevealed() {
        continueAfterFailure = false
        let app = launch("en", screen: "settings")
        let table = app.tables["setup.players"]
        let add = table.buttons["setup.addPlayer"]
        app.buttons["Pairs"].tap()
        add.tap()
        add.tap()
        let sixth = table.cells.element(boundBy: 5)
        sixth.textFields.firstMatch.tap()
        sixth.textFields.firstMatch.typeText("Eve")
        app.staticTexts["Players:"].tap()
        sixth.swipeLeft()
        XCTAssertTrue(sixth.buttons["Delete"].isHittable)
        app.buttons["Singles"].tap()
        XCTAssertFalse(table.buttons["Delete"].exists)
        XCTAssertEqual(sixth.textFields.firstMatch.value as? String, "Eve")
        sixth.swipeLeft()
        sixth.buttons["Delete"].tap()
        XCTAssertFalse(table.textFields.matching(NSPredicate(format: "value == 'Eve'")).firstMatch.exists)
        app.buttons["Pairs"].tap()
        let fifth = table.cells.element(boundBy: 4)
        fifth.swipeLeft()
        fifth.buttons["Delete"].tap()
        app.buttons["setup.done"].tap()
        XCTAssertTrue(app.textFields["words.field"].waitForExistence(timeout: 5))
    }

    func testAllowSkipsThroughSetup() {
        let app = launch("en", screen: "settings")
        let toggle = app.switches["setup.allowSkips"]
        XCTAssertEqual(toggle.value as? String, "0")
        toggle.tap()
        XCTAssertEqual(toggle.value as? String, "1")
        app.buttons["setup.done"].tap()
        app.navigationBars.buttons["Done"].tap()
        app.staticTexts["handoff.start.label"].press(forDuration: 2)
        XCTAssertTrue(app.buttons["round.skip"].waitForExistence(timeout: 5), app.debugDescription)
    }

    func testSkippedWordsReturnAfterTurnWithoutPenalty() {
        let app = launch("en", screen: "round-skip")
        let word = app.staticTexts["round.word"], skip = app.buttons["round.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 5))
        let first = word.label
        skip.tap()
        let second = word.label
        XCTAssertNotEqual(first, second)
        app.buttons["round.guessed"].tap()
        XCTAssertFalse([first, second].contains(word.label))
        skip.tap()
        let count = app.staticTexts["handoff.wordsLeft"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))
        XCTAssertEqual(count.label, "2 words left")
        app.buttons["handoff.review"].tap()
        let rows = app.tables.cells
        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(rows.element(boundBy: 0).value as? String, "Back in the hat")
        XCTAssertEqual(rows.element(boundBy: 1).value as? String, "Guessed")
        XCTAssertEqual(rows.element(boundBy: 2).value as? String, "Back in the hat")
    }

    func testDoubleTapDuringFoldSkipsOnlyOneWord() {
        let app = launch("en", screen: "round-skip", motion: true)
        let skip = app.buttons["round.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 5))
        skip.doubleTap()
        // End the turn at overtime so its review records exactly how many
        // words those taps consumed, independently of animation timing.
        let overtime = expectation(for: NSPredicate(format: "label == 'Not guessed'"), evaluatedWith: skip)
        wait(for: [overtime], timeout: 45)
        skip.tap()
        app.buttons["handoff.review"].tap()
        let rows = app.tables.cells
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows.element(boundBy: 0).value as? String, "Back in the hat")
        XCTAssertEqual(rows.element(boundBy: 1).value as? String, "Back in the hat")
    }

    func testSkipDuringOvertimeEndsTurnWithoutNewDraw() {
        let app = launch("en", screen: "round-skip-overtime")
        let skip = app.buttons["round.skip"]
        let changed = expectation(for: NSPredicate(format: "label == 'Not guessed'"), evaluatedWith: skip)
        wait(for: [changed], timeout: 10)
        capture(app, "warm-en-not-guessed")
        skip.tap()
        XCTAssertTrue(app.staticTexts["handoff.wordsLeft"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["handoff.wordsLeft"].label, "3 words left")
    }

    func testReviewSheetInsetsStatusChangesAndScroll() {
        let app = launch("en", screen: "review-long")
        app.buttons["handoff.review"].tap()
        let table = app.tables.firstMatch
        let first = table.cells.element(boundBy: 0)
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        let title = first.staticTexts.firstMatch
        XCTAssertGreaterThanOrEqual(title.frame.minX - table.frame.minX, 17)
        XCTAssertLessThanOrEqual(first.staticTexts.element(boundBy: 1).frame.maxX, table.frame.maxX - 17)
        XCTAssertEqual(first.value as? String, "Guessed")
        first.tap(); XCTAssertEqual(first.value as? String, "Back in the hat")
        first.tap(); XCTAssertEqual(first.value as? String, "Mistake")
        table.swipeUp()
        XCTAssertTrue(table.cells.containing(.staticText, identifier: "Long demonstration word 5").firstMatch.exists)
        let save = app.buttons["review.save"]
        XCTAssertGreaterThan(save.frame.minY, table.frame.maxY)
        save.tap()
        XCTAssertTrue(app.buttons["handoff.review"].waitForExistence(timeout: 5))
    }

    func testRosterSpacingAndCustomWordKeyboard() {
        let app = launch("en", screen: "settings")
        let cell = app.tables["setup.players"].cells.firstMatch
        let name = cell.textFields["setup.playerName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(name.frame.minX - cell.frame.minX, 55)
        name.tap(); name.typeText(" Long Player Name")
        XCTAssertGreaterThanOrEqual(name.frame.minX - cell.frame.minX, 55)
        app.buttons["setup.done"].tap()
        let field = app.textFields["words.field"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap(); field.typeText("testword")
        XCTAssertEqual(field.value as? String, "testword")
        let addButton = app.buttons["words.add"]
        XCTAssertLessThanOrEqual(addButton.frame.maxY, app.keyboards.firstMatch.frame.minY + 1)
        addButton.tap()
        XCTAssertTrue(app.staticTexts["Words in the hat: 61"].waitForExistence(timeout: 3), app.staticTexts.allElementsBoundByIndex.map { $0.label }.joined(separator: " | "))
    }

    func testAboutAndSecondaryScreens() {
        for language in ["en", "ru"] {
            let app = launch(language, screen: "menu")
            app.buttons["menu.about"].tap()
            XCTAssertTrue(app.tables["about.links"].waitForExistence(timeout: 5))
            XCTAssertEqual(app.tables["about.links"].cells.count, 5)
            capture(app, "warm-\(language)-about")
            for screen in ["custom-words", "history-empty", "history", "scoreboard", "scoreboard-pairs", "settings"] {
                let screenApp = launch(language, screen: screen)
                switch screen {
                case "custom-words":
                    let title = language == "ru" ? "Свои слова" : "Add words"
                    XCTAssertEqual(screenApp.staticTexts.matching(identifier: title).count, 1)
                    XCTAssertFalse(screenApp.staticTexts["Your own words"].exists)
                    let field = screenApp.textFields["words.field"]
                    XCTAssertTrue(field.exists)
                    XCTAssertGreaterThanOrEqual(field.frame.minX, 20)
                    XCTAssertLessThanOrEqual(field.frame.maxX, screenApp.frame.maxX - 20)
                case "history-empty": XCTAssertTrue(screenApp.staticTexts[language == "ru" ? "Пока нет игр" : "No games yet"].exists)
                case "history": XCTAssertTrue(screenApp.staticTexts[language == "ru" ? "Алиса" : "Alice"].exists)
                case "scoreboard", "scoreboard-pairs":
                    let bar = screenApp.navigationBars.firstMatch
                    XCTAssertTrue(bar.staticTexts[language == "ru" ? "Результаты" : "Results"].exists)
                    XCTAssertFalse(screenApp.staticTexts[language == "ru" ? "Итоги партии" : "Scorecard"].exists)
                    XCTAssertTrue(screenApp.staticTexts[language == "ru" ? "Всего" : "Total"].exists)
                default: XCTAssertTrue(screenApp.buttons["setup.done"].exists)
                }
                capture(screenApp, "warm-\(language)-\(screen)")
            }
        }
    }
}
