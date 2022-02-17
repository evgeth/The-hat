import UIKit

final class HistoryTableViewCelll: UITableViewCell, ViewReusable {
    private lazy var playersLabel = makeTitleLabel(with: LS.localizedString(forKey: "players"))
    private lazy var wrodsInTheHatLabel = makeTitleLabel()
    private lazy var gameType = makeTitleLabel()

    private lazy var separatorView: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .separator
        } else {
            view.backgroundColor = .gray
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .white
        selectionStyle = .none
        addSubviews()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with viewModel: GameHistroyItem) {
        viewModel.players.forEach { player in
            stackView.addArrangedSubview(makeTitleLabel(with: "\(player.name): \(player.score)"))
        }
        wrodsInTheHatLabel.text = "\(LS.localizedString(forKey: "words_in_the_hat")): \(viewModel.wordsInTheHat)"
        gameType.text = "\(LS.localizedString(forKey: "game_type")): \(viewModel.gameType.title)"
    }

    private func addSubviews() {
        [playersLabel, stackView, wrodsInTheHatLabel, gameType, separatorView].forEach {
            contentView.addSubview($0)
        }
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate(
            [
                playersLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                playersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),

                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                stackView.leadingAnchor.constraint(equalTo: playersLabel.trailingAnchor, constant: 8),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

                wrodsInTheHatLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4),
                wrodsInTheHatLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
                wrodsInTheHatLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

                gameType.topAnchor.constraint(equalTo: wrodsInTheHatLabel.bottomAnchor, constant: 4),
                gameType.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
                gameType.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
                gameType.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: -4),

                separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
                separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
                separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1),
            ]
        )
    }
}

private extension HistoryTableViewCelll {
    func makeTitleLabel(with text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = UIFont(name: "Avenir Next", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
