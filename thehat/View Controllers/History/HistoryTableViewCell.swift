import UIKit

final class HistoryTableViewCell: UITableViewCell, ViewReusable {
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = AppColors.background
        selectionStyle = .none
        addSubviews()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with viewModel: GameHistoryItem) {
        setupStackView(with: viewModel)
    }

    private func setupStackView(with model: GameHistoryItem) {
        model.playersData.forEach { item in
            switch item {
            case .player(let player):
                let view = PlayerView()
                view.setup(with: player)
                stackView.addArrangedSubview(view)
            case .pair(let pair):
                let view = HistoryHeaderTableView()
                view.set(title: pair)
                stackView.addArrangedSubview(view)
            }
        }
    }

    private func addSubviews() {
        [stackView].forEach { contentView.addSubview($0) }
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ]
        )
    }
}
