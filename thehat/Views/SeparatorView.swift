import UIKit

extension SeparatorView {
    struct Appearance {
        let heightInPixels: CGFloat = 1
    }
}

final class SeparatorView: UIView {
    override var intrinsicContentSize: CGSize {
        .init(
            width: UIView.noIntrinsicMetric,
            height: 1 
        )
    }

    init() {
        super.init(frame: .zero)
        self.backgroundColor = AppColors.separator
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}
