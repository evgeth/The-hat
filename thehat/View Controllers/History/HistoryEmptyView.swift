import UIKit

final class HistoryEmptyView: UIView, ViewReusable {
    private let titleLabel = WarmUI.label(WarmUI.text("empty_history_title"), size: 17, color: AppColors.textSecondary, centered: true)

    init() {
        super.init(frame: .zero)
        let art = UIImageView(image: UIImage(named: "WarmRulesResults")); art.contentMode = .scaleAspectFit
        let heading = WarmUI.label(WarmUI.text("warm_history_empty"), size: 30, serif: true, centered: true)
        let group = UIStackView(arrangedSubviews: [art, heading, titleLabel]); group.axis = .vertical; group.spacing = 12
        group.setCustomSpacing(24, after: art)
        group.translatesAutoresizingMaskIntoConstraints = false; addSubview(group)
        let width = group.widthAnchor.constraint(equalTo: widthAnchor, constant: -64); width.priority = .defaultHigh
        NSLayoutConstraint.activate([group.centerXAnchor.constraint(equalTo: centerXAnchor), group.centerYAnchor.constraint(equalTo: centerYAnchor), width,
            group.widthAnchor.constraint(lessThanOrEqualToConstant: 420), art.heightAnchor.constraint(equalToConstant: 176)])
    }
    required init?(coder: NSCoder) { fatalError("Use init()") }
    func set(title: String) { titleLabel.text = title }
}
