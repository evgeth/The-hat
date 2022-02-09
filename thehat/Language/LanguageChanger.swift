import UIKit

final class LanguageChanger {
    static let shared = LanguageChanger()
    private var currentLanguage: Language
    private var bundle: Bundle?

    init() {
        bundle = Bundle.main
        let deviceLocale = NSLocale.current.languageCode
        self.currentLanguage = deviceLocale == Language.russian.code ? .russian : .english
    }

    func changeLanguage() {
        if currentLanguage == Language.russian {
            currentLanguage = .english
        } else {
            currentLanguage = .russian
        }

        let path = Bundle.main.path(forResource: currentLanguage.code, ofType: "lproj")
        if let path = path {
            bundle = Bundle(path: path)
        } else {
            bundle = Bundle.main
        }

        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appDelegate.initRootView()
        }
    }

    func localizedString(forKey key: String, value comment: String? = nil) -> String {
        let localized = bundle!.localizedString(forKey: key, value: comment, table: nil)
        return localized
    }
}
