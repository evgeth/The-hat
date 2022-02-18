import Foundation

enum PlayerCellData {
    case player(Player)
    case pair(String)
}

struct GameHistroyItem: Codable {
    let date: Date
    let players: [Player]
    let rounds: [Round]
    let wordsInTheHat: Int
    let gameType: GameType
    var playersPair: [PlayersPair] {
        guard gameType == .Pairs else {
            return []
        }
        var sortedPairs: [PlayersPair] = []
        for (index, _) in players.enumerated() {
            if index % 2 == 0 {
                let element = PlayersPair(first: players[index], second: players[index + 1])
                sortedPairs.append(element)
            }
        }
        return sortedPairs.sorted(by: { (a, b) -> Bool in
            return a.first.score + a.second.score > b.first.score + b.second.score
        })
    }

    var playersData: [PlayerCellData] {
        if playersPair.isEmpty {
            return players.sorted(by: { $0.score > $1.score }).map { .player($0) }
        } else {
            var data: [PlayerCellData] = []
            var section = 0
            playersPair.forEach { pair in
                section += 1
                data.append(.pair("Pair \(section)"))
                data.append(.player(pair.first))
                data.append(.player(pair.second))
            }
            return data
        }
    }

    var stringDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY HH:mm"
        return formatter.string(from: self.date)
    }

    var playersScore: [String] {
        if gameType == .EachToEach {
            return players.map { "\($0.name): \($0.score)"}
        } else {
            return playersPair.map { "\($0.first.name): \($0.first.score)\n\($0.second.name): \($0.second.score)"}
        }
    }

    init(game: Game) {
        self.players = game.players.sorted(by: { $0.score > $1.score })
        self.rounds = game.rounds
        self.wordsInTheHat = game.wordsInTheHat
        self.gameType = game.type
        self.date = Date()
    }

}
