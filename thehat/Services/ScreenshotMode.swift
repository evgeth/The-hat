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

    private static func primeGameForScreenshots() {
        let game = GameSingleton.gameInstance
        game.players = [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Carol"),
            Player(name: "David")
        ]
        game.roundDuration = 30
        game.difficulty = 50
        game.wordsInTheHat = 60
        game.type = .EachToEach
        game.previousPair = (0, 0)
        game.playingPair = (0, 1)
        game.roundNumber = 0
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
        let game = GameSingleton.gameInstance
        game.loadWords()
        game.isPoolShouldBeUpdated = true
        game.updatePool()
        game.initFirstRound()
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
        let sample = ["river", "thunder", "garden", "library", "mountain", "harbor", "candle"]
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
