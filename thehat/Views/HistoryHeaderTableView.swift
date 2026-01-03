import UIKit

final class HistoryHeaderTableView: UIView, ViewReusable {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.textSecondary
        label.font = UIFont(name: "Excalifont", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
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
        backgroundColor = AppColors.background
        addSubview(titleLabel)

        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }
}
