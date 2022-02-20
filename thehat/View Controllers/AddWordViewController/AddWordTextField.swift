import UIKit

fileprivate extension NSAttributedString {
    static let placeholder = NSAttributedString(
        string: LS.localizedString(forKey: "write_word"),
        attributes: [
            .foregroundColor: UIColor.gray,
            .font : UIFont(name: "Avenir Next", size: 20)!
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
        font = UIFont(name: "Avenir Next", size: 20)
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

