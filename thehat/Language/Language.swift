
import Foundation

struct Language: Equatable {
    let code: String
    let namge: String

    static let english = Language(code: "en", namge: "English")
    static let russian = Language(code: "ru", namge: "Русский")
}
