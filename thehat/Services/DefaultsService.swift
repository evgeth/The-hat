import Foundation

protocol DefaultsServiceProtocol {
    var gamesHistroy: [GameHistroyItem] { get set }
}

final class DefaultsService: DefaultsServiceProtocol {
    private let defaults = UserDefaults.standard
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    var gamesHistroy: [GameHistroyItem] {
        get {
            guard
                let data = self.defaults.data(forKey: DefaultsKeys.history.rawValue),
                let games = try? self.jsonDecoder.decode([GameHistroyItem].self, from: data)
            else  {
                return []
            }
            return games
        }
        set {
            let data = try? self.jsonEncoder.encode(newValue)
            self.defaults.set(data, forKey: DefaultsKeys.history.rawValue)
        }
    }

    private enum DefaultsKeys: String {
        case history
    }
}
