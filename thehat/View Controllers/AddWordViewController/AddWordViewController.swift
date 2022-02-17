import UIKit

final class AddWordViewController: UIViewController {
    private var game = GameSingleton.gameInstance

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = LS.localizedString(forKey: "own_words")
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir Next", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let wordsInTheHatLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir Next", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addWordButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setTitle("\(LS.localizedString(forKey: "add_word"))", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.textColor = .black
        button.addTarget(self, action: #selector(addWord), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var goToGameButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setTitle("\(LS.localizedString(forKey: "go_to_game"))", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.addTarget(self, action: #selector(goToGame), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    @objc
    private func addWord() {
        guard let word = searchTextField.text, !word.isEmpty else {
            return
        }
        searchTextField.text = ""
        game.newWords.insert(word)
        game.words.append(Word(word: word))
        game.wordsInTheHat += 1
        wordsInTheHatLabel.text = "\(LS.localizedString(forKey: "words_in_the_hat")): \(game.wordsInTheHat)"
    }

    @objc
    private func goToGame() {
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
        view.backgroundColor = .white
        addSubviews()
        makeConstraints()

        setNavigationBarTitleWithCustomFont(title: LS.localizedString(forKey: "add_words"))
        wordsInTheHatLabel.text = "\(LS.localizedString(forKey: "words_in_the_hat")): \(game.wordsInTheHat)"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func addSubviews() {
        view.addSubview(descriptionLabel)
        view.addSubview(wordsInTheHatLabel)
        view.addSubview(searchTextField)
        view.addSubview(addWordButton)
        view.addSubview(goToGameButton)
    }

    private func makeConstraints() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate(
                [
                    descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                    goToGameButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
                ])
        }
        else {
            NSLayoutConstraint.activate(
                [
                    descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
                    goToGameButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
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

                addWordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                addWordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                addWordButton.bottomAnchor.constraint(equalTo: goToGameButton.topAnchor, constant: -16),
                addWordButton.heightAnchor.constraint(equalToConstant: 44),
                addWordButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),


                goToGameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
                goToGameButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
                goToGameButton.heightAnchor.constraint(equalToConstant: 44),
                goToGameButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64)

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
