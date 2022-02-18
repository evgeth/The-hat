import UIKit

fileprivate extension NSAttributedString {
    static let placeholder = NSAttributedString(
        string: NSLocalizedString("write_word", comment: "Search"),
        attributes: [
            .foregroundColor: UIColor.gray,
            .font : UIFont.systemFont(ofSize: 14)
        ]
    )
}

final class AddWordTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    private func setUp() {
        font = .systemFont(ofSize: 14)
        clearButtonMode = .whileEditing
        attributedPlaceholder = .placeholder
        textColor = .black
        returnKeyType = .done
        borderStyle = .roundedRect
        delegate = self
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

extension AddWordTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

