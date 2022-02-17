import Foundation

struct GamesHistoryList {
    let date: Date
    var items: [GameHistroyItem]

    var stringDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        return formatter.string(from: self.date)
    }
}

enum GameHistoryItemsMapper {
    static func mapToTGameHostoryItems(
        form items: [GameHistroyItem]
    ) -> [GamesHistoryList] {
        let sortedItems = items.sorted(by: { $0.date > $1.date })
        var lastGame: GamesHistoryList?
        var games: [GamesHistoryList] = []

        for item in sortedItems {
            let currentDate = item.date
            if lastGame == nil {
                lastGame = GamesHistoryList(date: currentDate, items: [item])
                continue
            }
            if currentDate.startOfDay != lastGame?.date.startOfDay {
                guard let transaction = lastGame else {
                    return games
                }
                games.append(transaction)
                lastGame = GamesHistoryList(date: currentDate, items: [item])
                continue
            }
            lastGame?.items.append(item)
        }
        guard let transaction = lastGame else {
            return games
        }
        games.append(transaction)
        return games
    }
}
