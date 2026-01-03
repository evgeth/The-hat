import UIKit

final class AddWordViewController: UIViewController {
    private var game = GameSingleton.gameInstance

    var initinalY: CGFloat = 0
    var words: [String] = []
    var wordsCount: Int = 0
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = LS.localizedString(forKey: "own_words")
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Excalifont", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let wordsInTheHatLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Excalifont", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addWordButton: UIButton = {
        let button = UIButton()
        button.setTitle("\(LS.localizedString(forKey: "add_word"))", for: .normal)
        button.setTitleColor(AppColors.textPrimary, for: .normal)
        button.titleLabel?.textColor = AppColors.textPrimary
        button.titleLabel?.font = UIFont(name: "Excalifont", size: 36)
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
        setupNotifications()
        addKeyboardHideHandler()
    }

    private func addKeyboardHideHandler() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
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
        addWordButton.frame.origin.y = initinalY
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        initinalY = addWordButton.frame.origin.y
        addWordButton.frame.origin.y -= keyboardFrame.cgRectValue.height
    }


    private func addSubviews() {
        view.addSubview(descriptionLabel)
        view.addSubview(wordsInTheHatLabel)
        view.addSubview(searchTextField)
        view.addSubview(addWordButton)
    }

    private func makeConstraints() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate(
                [
                    descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                    addWordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
                ])
        }
        else {
            NSLayoutConstraint.activate(
                [
                    descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
                    addWordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
                ]
            )
        }

        NSLayoutConstraint.activate(
            [
                descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

                wordsInTheHatLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
                wordsInTheHatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                wordsInTheHatLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                
                addWordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                addWordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                addWordButton.heightAnchor.constraint(equalToConstant: 65),
                addWordButton.widthAnchor.constraint(equalTo: view.widthAnchor),

            ]
        )

        NSLayoutConstraint.activate(
            [
                searchTextField.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 32
                ),

                searchTextField.leadingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -32
                ),
                searchTextField.topAnchor.constraint(
                    equalTo: wordsInTheHatLabel.bottomAnchor,
                    constant: 16
                ),
                searchTextField.heightAnchor.constraint(equalToConstant: 44),
                searchTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64)
            ]
        )
    }

}
