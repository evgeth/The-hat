import UIKit

final class AddWordTextField: UITextField, UITextFieldDelegate {
    override init(frame: CGRect) { super.init(frame: frame); setUp() }
    required init?(coder: NSCoder) { super.init(coder: coder); setUp() }

    private func setUp() {
        font = .systemFont(ofSize: 18)
        textColor = AppColors.textPrimary
        tintColor = AppColors.primary
        clearButtonMode = .whileEditing
        placeholder = LS.localizedString(forKey: "write_word")
        returnKeyType = .done
        backgroundColor = AppColors.surface
        layer.cornerRadius = 14
        layer.borderColor = AppColors.separator.cgColor
        layer.borderWidth = 1
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        leftViewMode = .always
        accessibilityIdentifier = "words.field"
        delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
