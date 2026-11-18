import UIKit
import FirebaseAnalytics

struct RulePage {
    let titleKey: String
    let bodyKey: String
    let artwork: String

    static let all = [
        RulePage(titleKey: "rule_players_title", bodyKey: "edit_players", artwork: "WarmRulesPlayers"),
        RulePage(titleKey: "rule_settings_title", bodyKey: "edit_settings", artwork: "WarmRulesSettings"),
        RulePage(titleKey: "rule_explain_title", bodyKey: "preparation", artwork: "WarmRulesExplain"),
        RulePage(titleKey: "rule_guess_title", bodyKey: "round", artwork: "WarmRulesGuess"),
        RulePage(titleKey: "rule_time_title", bodyKey: "extra_time", artwork: "WarmRulesTime"),
        RulePage(titleKey: "rule_results_title", bodyKey: "results", artwork: "WarmRulesResults"),
        RulePage(titleKey: "rule_ready_title", bodyKey: "rule_ready_body", artwork: "WarmHat")
    ]
}

final class TutorialViewController: UIViewController, UIPageViewControllerDataSource {
    private let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    weak var delegate: TutorialDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        let heading = WarmUI.label(WarmUI.text("RULES"), size: 23, serif: true, centered: true)
        heading.accessibilityIdentifier = "rules.heading"
        heading.accessibilityTraits.insert(.header)
        heading.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(heading)

        pager.dataSource = self
        addChild(pager)
        view.addSubview(pager.view)
        pager.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            heading.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            heading.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            heading.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            pager.view.topAnchor.constraint(equalTo: heading.bottomAnchor),
            pager.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        pager.setViewControllers([page(at: 0)!], direction: .forward, animated: false)
        pager.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.logEvent("open_screen", parameters: ["screen_name": "Tutorial"])
    }

    private func page(at index: Int) -> TutorialPageViewController? {
        guard RulePage.all.indices.contains(index) else { return nil }
        let page = TutorialPageViewController()
        page.pageIndex = index
        page.delegate = delegate
        return page
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let visible = viewController as? TutorialPageViewController else { return nil }
        return page(at: visible.pageIndex + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let visible = viewController as? TutorialPageViewController else { return nil }
        return page(at: visible.pageIndex - 1)
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        RulePage.all.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        (pageViewController.viewControllers?.first as? TutorialPageViewController)?.pageIndex ?? 0
    }
}
