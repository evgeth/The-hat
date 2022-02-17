import Foundation

struct GameHistroyItem: Codable {
    let date: Date
    let players: [Player]
    let rounds: [Round]
    let wordsInTheHat: Int
    let gameType: GameType

    init(game: Game) {
        self.players = game.players.sorted(by: { $0.score > $1.score })
        self .rounds = game.rounds
        self.wordsInTheHat = game.wordsInTheHat
        self.gameType = game.type
        self.date = Date()
    }

}
