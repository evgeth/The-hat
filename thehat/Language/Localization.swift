import Foundation

final class LS {
    static let languageChanger = LanguageChanger.shared

    static func localizedString(forKey key: String, value comment: String? = nil) -> String {
        guard let bundle = languageChanger.bundle else {
            return NSLocalizedString(key, comment: comment ?? "")
        }
        let localized = bundle.localizedString(forKey: key, value: comment, table: nil)
        return localized
    }
}
