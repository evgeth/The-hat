import UIKit

final class AddWordViewController: UIViewController, UIGestureRecognizerDelegate {
    private var game = GameSingleton.gameInstance

    private var legacyButtonBottom: NSLayoutConstraint?
    var words: [String] = []
    var wordsCount: Int = 0
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = LS.localizedString(forKey: "own_words")
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let wordsInTheHatLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addWordButton: UIButton = {
        let button = UIButton()
        button.setTitle("\(LS.localizedString(forKey: "add_word"))", for: .normal)
        button.setTitleColor(AppColors.surface, for: .normal)
        button.layer.cornerRadius = 18
        button.accessibilityIdentifier = "words.add"
        button.titleLabel?.font = WarmUI.displayFont(24)
        button.backgroundColor = AppColors.primary
        button.addTarget(self, action: #selector(addWord), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    @objc
    private func addWord() {
        guard let word = searchTextField.text, !word.isEmpty else {
            return
        }
        searchTextField.text = ""
        if !words.contains(where: { $0 == word }) {
            self.words.append(word)
            wordsCount += 1
            wordsInTheHatLabel.text = "\(LS.localizedString(forKey: "words_in_the_hat")): \(wordsCount)"

        }
    }

    @objc
    private func goToGame() {
        game.reinitialize()
        words.forEach { game.newWords.insert($0) }
        game.words += words.map { Word(word: $0)}
        game.wordsInTheHat = wordsCount
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        guard let nextViewController = storyBoard.instantiateViewController(withIdentifier: "preparation") as? PreparationViewController else {
            return
        }

        navigationController?.pushViewController(nextViewController, animated: true)
    }

    private lazy var searchTextField: AddWordTextField = {
        let textField = AddWordTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        addSubviews()
        makeConstraints()

        setNavigationBarTitleWithCustomFont(title: LS.localizedString(forKey: "add_words"))
        wordsInTheHatLabel.text = "\(LS.localizedString(forKey: "words_in_the_hat")): \(game.wordsInTheHat)"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        wordsCount = game.wordsInTheHat
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(self.goToGame)
        )
        if #available(iOS 15.0, *) {} else { setupNotifications() }
        addKeyboardHideHandler()
    }

    private func addKeyboardHideHandler() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Keep a tap on Add in the button's control path. Dismissing the
        // keyboard first moves the button away before touchUpInside fires.
        var view = touch.view
        while let current = view {
            if current is UIControl { return false }
            view = current.superview
        }
        return true
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        legacyButtonBottom?.constant = -16
        view.layoutIfNeeded()
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        let rect = view.convert(keyboardFrame.cgRectValue, from: nil)
        let overlap = view.bounds.intersection(rect).height
        legacyButtonBottom?.constant = -max(16, overlap - view.safeAreaInsets.bottom + 12)
        view.layoutIfNeeded()
    }


    private func addSubviews() {
        view.addSubview(descriptionLabel)
        view.addSubview(wordsInTheHatLabel)
        view.addSubview(searchTextField)
        view.addSubview(addWordButton)
    }

    private func makeConstraints() {
        let safe = view.safeAreaLayoutGuide
        let header = WarmUI.brandHeader(title: WarmUI.text("warm_words_heading"), image: "WarmHat", width: view.bounds.width)
        header.translatesAutoresizingMaskIntoConstraints = false
        let scroll = UIScrollView(); scroll.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(scroll, at: 0)
        let stack = UIStackView(arrangedSubviews: [descriptionLabel, searchTextField, wordsInTheHatLabel])
        stack.axis = .vertical; stack.spacing = 16; stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(header); scroll.addSubview(stack)
        let width = stack.widthAnchor.constraint(equalTo: safe.widthAnchor, constant: -48); width.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: safe.topAnchor), scroll.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: safe.trailingAnchor), scroll.bottomAnchor.constraint(equalTo: addWordButton.topAnchor, constant: -8),
            scroll.contentLayoutGuide.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            header.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), header.heightAnchor.constraint(equalToConstant: 142),
            header.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor), header.centerXAnchor.constraint(equalTo: scroll.frameLayoutGuide.centerXAnchor),
            stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20), stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.centerXAnchor.constraint(equalTo: safe.centerXAnchor), width, stack.widthAnchor.constraint(lessThanOrEqualToConstant: 520),
            searchTextField.heightAnchor.constraint(equalToConstant: 54),
            addWordButton.centerXAnchor.constraint(equalTo: safe.centerXAnchor), addWordButton.widthAnchor.constraint(equalTo: stack.widthAnchor),
            addWordButton.heightAnchor.constraint(equalToConstant: 62)
        ])
        if #available(iOS 15.0, *) {
            addWordButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12).isActive = true
        } else {
            legacyButtonBottom = addWordButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16)
            legacyButtonBottom?.isActive = true
        }
    }
}
