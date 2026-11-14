import UIKit

protocol TutorialDelegate: AnyObject {
    func openNewGame()
}

/// A long translation may need vertical scrolling, while horizontal drags
/// always belong to the surrounding Rules pager.
private final class RuleScrollView: UIScrollView {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer {
            let direction = panGestureRecognizer.velocity(in: self)
            if abs(direction.x) >= abs(direction.y) { return false }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}

final class TutorialPageViewController: UIViewController {
    var pageIndex = 0
    weak var delegate: TutorialDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let page = RulePage.all[pageIndex]
        view.backgroundColor = AppColors.background
        let scroll = RuleScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let title = WarmUI.label(WarmUI.text(page.titleKey), size: 34, serif: true)
        title.accessibilityTraits = .header
        title.accessibilityIdentifier = "rules.title.\(pageIndex + 1)"
        let body = WarmUI.label(WarmUI.text(page.bodyKey), size: 18, color: AppColors.textPrimary)
        body.font = UIFont.preferredFont(forTextStyle: .body)
        body.adjustsFontForContentSizeCategory = true
        let kicker = WarmUI.label(WarmUI.text("RULES").uppercased(), size: 13, color: AppColors.primaryDark)
        kicker.font = .systemFont(ofSize: 13, weight: .bold)
        let number = WarmUI.label(String(format: "%02d / %02d", pageIndex + 1, RulePage.all.count), size: 14, color: AppColors.primaryDark)
        number.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        let folio = UIStackView(arrangedSubviews: [kicker, UIView(), number])
        let plate = WarmUI.card()
        let art = UIImageView(image: UIImage(named: page.artwork))
        art.contentMode = .scaleAspectFit
        art.isAccessibilityElement = false
        art.translatesAutoresizingMaskIntoConstraints = false
        plate.addSubview(art)

        let stack = UIStackView(arrangedSubviews: [folio, plate, title, body])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(24, after: plate)
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        let width = stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -48)
        width.priority = UILayoutPriority(999)
        art.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let artHeight = plate.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor, multiplier: 0.46)
        artHeight.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor), scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.contentLayoutGuide.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -28),
            stack.centerXAnchor.constraint(equalTo: scroll.frameLayoutGuide.centerXAnchor), width,
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 520), artHeight,
            plate.heightAnchor.constraint(lessThanOrEqualToConstant: 355),
            art.topAnchor.constraint(equalTo: plate.topAnchor, constant: 20), art.bottomAnchor.constraint(equalTo: plate.bottomAnchor, constant: -20),
            art.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: 18), art.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -18)
        ])
        if pageIndex == RulePage.all.count - 1 {
            let button = UIButton(type: .system)
            button.setTitle(WarmUI.text("NEW_GAME"), for: .normal)
            button.accessibilityIdentifier = "rules.newGame"
            button.titleLabel?.font = WarmUI.displayFont(24)
            button.setTitleColor(AppColors.surface, for: .normal)
            button.backgroundColor = AppColors.primary
            button.layer.cornerRadius = 18
            button.addTarget(self, action: #selector(openNewGame), for: .touchUpInside)
            stack.addArrangedSubview(button)
            stack.setCustomSpacing(24, after: body)
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
    }

    @objc private func openNewGame() {
        dismiss(animated: true) { [weak delegate] in delegate?.openNewGame() }
    }
}
