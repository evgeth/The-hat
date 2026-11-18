import UIKit

enum AppColors {
    // Brand Greens
    static let primary = UIColor(named: "Primary")!
    static let primaryDark = UIColor(named: "PrimaryDark")!
    static let secondary = UIColor(named: "Secondary")!

    // Neutrals (Paper & Ink)
    static let background = UIColor(named: "Background")!
    static let surface = UIColor(named: "Surface")!
    static let textPrimary = UIColor(named: "TextPrimary")!
    static let textSecondary = UIColor(named: "TextSecondary")!
    static let separator = UIColor(named: "Separator")!

    // State Colors
    // Neutral ink for words returned to the hat; green is reserved for a correct guess.
    static let returnedWord = UIColor(red: 0.34, green: 0.32, blue: 0.30, alpha: 1)
    static let success = UIColor(named: "Success")!
    static let fail = UIColor(named: "Fail")!
}
