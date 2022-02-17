import UIKit

final class HistoryViewController: UIViewController {
    private enum HistroyState {
        case empty
        case data([GamesHistoryList])
    }

    private lazy var tableView = makeTableView()
    private lazy var emptyView = HistoryEmptyView()
    private var data: [GamesHistoryList] = []
    private let service: DefaultsServiceProtocol = DefaultsService()
    private var state: HistroyState = .empty {
        didSet {
            switch state {
            case .empty:
                tableView.isHidden = true
                emptyView.isHidden = false
            case .data(let items):
                tableView.isHidden = false
                emptyView.isHidden = true
                data = items
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        makeConstraints()
        setupData()
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        setNavigationBarTitleWithCustomFont(title: LS.localizedString(forKey: "HISTORY"))
    }

    private func addSubviews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(emptyView)
    }

    private func makeConstraints() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate(
                [
                    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                    emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                    emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                    emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ]
            )
        } else {
            NSLayoutConstraint.activate(
                [
                    tableView.topAnchor.constraint(equalTo: view.topAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                    emptyView.topAnchor.constraint(equalTo: view.topAnchor),
                    emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ]
            )
        }
    }

    func setupData() {
        let items = service.gamesHistroy
        if items.isEmpty {
            self.state = .empty
        } else {
            self.state = .data(GameHistoryItemsMapper.mapToTGameHostoryItems(form: items))
        }
    }

}

extension HistoryViewController {
    func set(data: [GamesHistoryList]) {
        self.data = data
        tableView.reloadData()
    }
}

extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.section].items[indexPath.row]
        let cell: HistoryTableViewCelll = tableView.dequeueReusableCell(for: indexPath)
        cell.setup(with: item)
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let item = data[section]
        let view = HistoryHeaderTableView()
        view.set(title: item.stringDate)
        return view
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 44
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return .leastNormalMagnitude
    }
}

private extension HistoryViewController {
    func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.register(cellClass: HistoryTableViewCelll.self)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        return tableView
    }
}
