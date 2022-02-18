import UIKit

final class PlayerView: UIView, ViewReusable {
    private lazy var playerLabel = makeTitleLabel()
    private lazy var playerScoreLabel = makeTitleLabel()

    private lazy var separatorTopView: SeparatorView = {
        let view = SeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconImage: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Sum"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var separatorBotView: SeparatorView = {
        let view = SeparatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .white
        addSubviews()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with player: Player) {
        playerLabel.text = player.name
        playerScoreLabel.text = "\(player.score)"
    }

    private func addSubviews() {
        [playerLabel, playerScoreLabel, separatorBotView, iconImage].forEach { addSubview($0) }
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate(
            [
                playerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                playerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

                playerScoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                playerScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

                iconImage.centerYAnchor.constraint(equalTo: centerYAnchor),
                iconImage.trailingAnchor.constraint(equalTo: playerScoreLabel.trailingAnchor, constant: -40),
                iconImage.heightAnchor.constraint(equalToConstant: 32),
                iconImage.widthAnchor.constraint(equalToConstant: 32),


                separatorBotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                separatorBotView.trailingAnchor.constraint(equalTo: trailingAnchor),
                separatorBotView.bottomAnchor.constraint(equalTo: bottomAnchor),

                heightAnchor.constraint(equalToConstant: 60)
            ]
        )
    }
}

private extension PlayerView {
    func makeTitleLabel(with text: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = UIFont(name: "Avenir Next", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
