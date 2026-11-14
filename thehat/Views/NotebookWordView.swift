import UIKit

/// A single printed sheet. Both faces sample the same image, so even a letter
/// that straddles the crease stays attached to the paper as the flap turns.
final class NotebookWordView: UIView {
    static let heightToWidth: CGFloat = 819.0 / 1920.0
    private static let stock = UIImage(named: "NotebookSlip")
    private let left = CALayer()
    private let hinge = CATransformLayer()
    private let front = CALayer()
    private let back = CALayer()
    private let reverseStock = CALayer()
    private let restAngle = -CGFloat.pi / 60
    private var printedWord: String?
    private var printedSize = CGSize.zero
    private(set) var isChangingWord = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityIdentifier = "round.word"
        transform = CGAffineTransform(rotationAngle: -.pi / 180)

        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 650
        layer.sublayerTransform = perspective
        layer.addSublayer(left)
        layer.addSublayer(hinge)
        hinge.anchorPoint = CGPoint(x: 0, y: 0.5)
        hinge.transform = CATransform3DMakeRotation(restAngle, 0, 1, 0)

        left.contentsRect = CGRect(x: 0, y: 0, width: 0.5, height: 1)
        front.contentsRect = CGRect(x: 0.5, y: 0, width: 0.5, height: 1)
        front.isDoubleSided = false
        back.isDoubleSided = false
        back.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
        hinge.addSublayer(back)
        hinge.addSublayer(front)
        reverseStock.contents = Self.stock?.cgImage
        reverseStock.contentsRect = front.contentsRect
        reverseStock.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
        back.addSublayer(reverseStock)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != printedSize, !bounds.isEmpty else { return }
        printedSize = bounds.size
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let panel = CGRect(origin: .zero, size: CGSize(width: bounds.width / 2, height: bounds.height))
        left.frame = panel
        hinge.bounds = panel
        hinge.position = CGPoint(x: panel.width, y: panel.midY)
        front.frame = panel
        back.bounds = panel
        back.position = CGPoint(x: panel.midX, y: panel.midY)
        reverseStock.frame = panel
        updateInk()
        CATransaction.commit()
    }

    func show(_ word: String) {
        guard printedWord != nil, window != nil, !UIAccessibility.isReduceMotionEnabled, UIView.areAnimationsEnabled else {
            printWord(word)
            return
        }
        isChangingWord = true
        let closed = -CGFloat.pi
        rotate(from: restAngle, to: closed, duration: 0.14, timing: CAMediaTimingFunction(name: .easeIn)) { [weak self] in
            guard let self = self else { return }
            self.printWord(word)
            self.rotate(from: closed, to: self.restAngle, duration: 0.24,
                        timing: CAMediaTimingFunction(controlPoints: 0.2, 0.6, 0.35, 1)) { [weak self] in
                self?.isChangingWord = false
            }
        }
    }

    private func rotate(from start: CGFloat, to end: CGFloat, duration: CFTimeInterval,
                        timing: CAMediaTimingFunction, completion: @escaping () -> Void) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue = start
        animation.toValue = end
        animation.duration = duration
        animation.timingFunction = timing
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock(completion)
        hinge.transform = CATransform3DMakeRotation(end, 0, 1, 0)
        hinge.add(animation, forKey: "fold")
        CATransaction.commit()
    }

    private func printWord(_ word: String) {
        printedWord = word
        accessibilityLabel = word
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateInk()
        CATransaction.commit()
    }

    private func updateInk() {
        guard let word = printedWord, printedSize.width > 0, printedSize.height > 0 else { return }
        let sheet = CGRect(origin: .zero, size: printedSize)
        let ink = CGRect(x: sheet.width * 0.13, y: sheet.height * 0.08,
                         width: sheet.width * 0.80, height: sheet.height * 0.84)
        let font = WarmUI.displayFont(sheet.width * 0.117)
        let label = UILabel(frame: CGRect(origin: .zero, size: ink.size))
        label.attributedText = NSAttributedString(string: word, attributes: [
            .font: font, .kern: -0.045 * font.pointSize, .foregroundColor: AppColors.textPrimary
        ])
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.35
        if label.intrinsicContentSize.width > ink.width / 0.7 {
            label.numberOfLines = 3
            label.lineBreakMode = .byWordWrapping
        }

        let image = UIGraphicsImageRenderer(size: sheet.size).image { renderer in
            Self.stock?.draw(in: sheet)
            renderer.cgContext.setBlendMode(.multiply)
            label.drawText(in: ink)
        }
        left.contents = image.cgImage
        front.contents = image.cgImage
    }
}
