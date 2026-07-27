import UIKit

enum ScreenshotMode {
    static func applyIfRequested() {
        let args = ProcessInfo.processInfo.arguments
        guard args.contains("--snapshot") else { return }

        UIView.setAnimationsEnabled(false)

        primeGameForScreenshots()

        guard let screen = screenName(from: args) else { return }

        DispatchQueue.main.async { presentScreen(screen) }
    }

    private static func screenName(from args: [String]) -> String? {
        for arg in args where arg.hasPrefix("--snapshot-screen=") {
            return String(arg.dropFirst("--snapshot-screen=".count))
        }
        return nil
    }

    /// Reads a comma-separated list from Localizable.strings. Screenshot sample
    /// data has to follow the locale under capture, otherwise the ru-RU App
    /// Store screenshots show English player names and words.
    private static func localizedList(_ key: String, fallback: [String]) -> [String] {
        let raw = LS.localizedString(forKey: key)
        // `localizedString(forKey:)` echoes the key back when it is missing.
        guard raw != key else { return fallback }
        let items = raw.split(separator: ",").map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter { !$0.isEmpty }
        return items.isEmpty ? fallback : items
    }

    private static func primeGameForScreenshots() {
        let game = GameSingleton.gameInstance
        // primeResults() and the pair indices below assume exactly four players,
        // so a mistranslated list must not shorten the roster.
        let defaultNames = ["Alice", "Bob", "Carol", "David"]
        let names = localizedList("SCREENSHOT_PLAYERS", fallback: defaultNames)
        game.players = defaultNames.indices.map {
            Player(name: $0 < names.count ? names[$0] : defaultNames[$0])
        }
        game.roundDuration = 30
        game.difficulty = 50
        game.wordsInTheHat = 60
        game.type = .EachToEach
        game.previousPair = (0, 0)
        game.playingPair = (0, 1)
        game.roundNumber = 0
        primeWordPool()
    }

    /// `Game.loadWords()` builds the pool on a background queue and only flips
    /// `didWordsLoad` afterwards, so a screenshot can outrun it: `updatePool()`
    /// bails early, the hat stays empty ("0 words left"), and the round screen
    /// has nothing to show and falls back to the menu. Screenshot runs are
    /// single-shot, so load synchronously and skip the race entirely.
    private static func primeWordPool() {
        let game = GameSingleton.gameInstance
        if game.wordsLoader == nil {
            game.wordsLoader = LocalWordsLoader()
        }
        game.areWordsLoading = false
        game.didWordsLoad = true
        game.isPoolShouldBeUpdated = true
        game.updatePool()
    }

    private static func presentScreen(_ name: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nav = storyboard.instantiateViewController(withIdentifier: "appNavigationController") as! UINavigationController
        let menu = storyboard.instantiateViewController(withIdentifier: "Menu Controller")
        nav.setViewControllers([menu], animated: false)

        switch name {
        case "menu":
            break
        case "settings":
            let settings = storyboard.instantiateViewController(withIdentifier: "settings")
            nav.pushViewController(settings, animated: false)
        case "preparation":
            let prep = storyboard.instantiateViewController(withIdentifier: "preparation")
            nav.pushViewController(prep, animated: false)
        case "round":
            primeRound()
            let round = storyboard.instantiateViewController(withIdentifier: "RoundViewController")
            nav.pushViewController(round, animated: false)
        case "results":
            primeResults()
            let edit = storyboard.instantiateViewController(withIdentifier: "EditGuessedWords")
            nav.pushViewController(edit, animated: false)
        default:
            break
        }

        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    private static func primeRound() {
        // The pool is already loaded synchronously by primeGameForScreenshots().
        let game = GameSingleton.gameInstance
        game.initFirstRound()

        // `getWord()` draws with randomElement(), so the word featured in the
        // App Store screenshot would otherwise be a fresh lottery over the whole
        // pool on every run. Pin a curated one so runs are reproducible and no
        // unfortunate entry can end up on the store listing. Safe to narrow the
        // pool here: the round screen shows the word, not a remaining count.
        let word = LS.localizedString(forKey: "SCREENSHOT_ROUND_WORD")
        if word != "SCREENSHOT_ROUND_WORD" && !word.isEmpty {
            game.newWords = [word]
        }
    }

    private static func primeResults() {
        let game = GameSingleton.gameInstance
        game.players[0].explained = 5
        game.players[0].guessed = 4
        game.players[1].explained = 4
        game.players[1].guessed = 6
        game.players[2].explained = 3
        game.players[2].guessed = 3
        game.players[3].explained = 5
        game.players[3].guessed = 4

        let previousRound = Round(number: 1, speaker: game.players[0], listener: game.players[1])
        let sample = localizedList(
            "SCREENSHOT_SAMPLE_WORDS",
            fallback: ["river", "thunder", "garden", "library", "mountain", "harbor", "candle"]
        )
        previousRound.guessedWords = sample.map { Word(word: $0) }
        for word in previousRound.guessedWords {
            word.state = State.guessed
        }
        if !previousRound.guessedWords.isEmpty {
            previousRound.guessedWords[previousRound.guessedWords.count - 1].state = State.fail
        }
        let currentRound = Round(number: 2, speaker: game.players[2], listener: game.players[3])
        game.rounds = [previousRound, currentRound]
        game.roundNumber = 2
        game.previousPair = (0, 1)
        game.playingPair = (2, 3)
        game.isGameInProgress = true
    }
}
