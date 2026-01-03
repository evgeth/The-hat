import UIKit

final class HistoryEmptyView: UIView, ViewReusable {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.textPrimary
        label.text = LS.localizedString(forKey: "empty_history_title")
        label.numberOfLines = 0
        label.font = UIFont(name: "Excalifont", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "empty-history")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(title: String) {
        titleLabel.text = title
    }

    private func setUp() {
        addSubview(titleLabel)
        addSubview(iconImageView)

        NSLayoutConstraint.activate(
            [
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                titleLabel.bottomAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -16),

                iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                iconImageView.heightAnchor.constraint(equalToConstant: 44),
                iconImageView.widthAnchor.constraint(equalToConstant: 44)
            ]
        )
    }
}
