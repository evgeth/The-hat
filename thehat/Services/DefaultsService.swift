import Foundation

protocol DefaultsServiceProtocol {
    var gamesHistory: [GameHistoryItem] { get set }
}

final class DefaultsService: DefaultsServiceProtocol {
    private let defaults = UserDefaults.standard
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    var gamesHistory: [GameHistoryItem] {
        get {
            guard
                let data = self.defaults.data(forKey: DefaultsKeys.history.rawValue),
                let games = try? self.jsonDecoder.decode([GameHistoryItem].self, from: data)
            else  {
                return []
            }
            return games
        }
        set {
            do {
                let data = try self.jsonEncoder.encode(newValue)
                self.defaults.set(data, forKey: DefaultsKeys.history.rawValue)
            } catch {
                print("Failed to encode games history: \(error.localizedDescription)")
            }
        }
    }

    private enum DefaultsKeys: String {
        case history
    }
}
