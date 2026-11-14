import UIKit

final class PlayerView: UIView, ViewReusable {
    private let playerLabel = WarmUI.label(size: 18)
    private let playerScoreLabel = WarmUI.label(size: 20, serif: true, color: AppColors.primaryDark, centered: true)

    init() {
        super.init(frame: .zero)
        backgroundColor = AppColors.surface
        playerLabel.numberOfLines = 1
        playerLabel.lineBreakMode = .byTruncatingTail
        playerScoreLabel.backgroundColor = AppColors.secondary
        playerScoreLabel.layer.cornerRadius = 12; playerScoreLabel.clipsToBounds = true
        let line = WarmUI.divider()
        [playerLabel, playerScoreLabel, line].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }
        NSLayoutConstraint.activate([heightAnchor.constraint(equalToConstant: 54),
            playerLabel.centerYAnchor.constraint(equalTo: centerYAnchor), playerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            playerLabel.trailingAnchor.constraint(lessThanOrEqualTo: playerScoreLabel.leadingAnchor, constant: -12),
            playerScoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor), playerScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            playerScoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 48), playerScoreLabel.heightAnchor.constraint(equalToConstant: 32),
            line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16), line.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            line.bottomAnchor.constraint(equalTo: bottomAnchor), line.heightAnchor.constraint(equalToConstant: 0.5)])
    }
    required init?(coder: NSCoder) { fatalError("Use init()") }
    func setup(with player: Player) {
        playerLabel.text = player.name; playerScoreLabel.text = "\(player.score)"
        playerScoreLabel.accessibilityLabel = "\(WarmUI.text("warm_total")): \(player.score)"
    }
}
