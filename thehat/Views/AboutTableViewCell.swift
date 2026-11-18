import UIKit

final class AboutTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var img: UIImageView!
    private let plate = WarmUI.card()
    private let arrow = WarmUI.label("›", size: 24, color: AppColors.primaryDark, centered: true)

    override func awakeFromNib() {
        super.awakeFromNib()
        NSLayoutConstraint.deactivate(contentView.constraints)
        NSLayoutConstraint.deactivate(img.constraints)
        [label!, img!].forEach { $0.translatesAutoresizingMaskIntoConstraints = true }
        contentView.insertSubview(plate, at: 0)
        contentView.addSubview(arrow)
        contentView.backgroundColor = AppColors.background
        backgroundColor = AppColors.background
        img.tintColor = AppColors.primaryDark
        img.contentMode = .center
        img.backgroundColor = AppColors.secondary
        img.layer.cornerRadius = 12
        img.clipsToBounds = true
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = AppColors.textPrimary
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
    }

    func configure(title: String, symbol: String, fallback: String) {
        label.text = title
        if #available(iOS 13.0, *) {
            img.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        } else { img.image = UIImage(named: fallback) }
        accessibilityLabel = title
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = min(520, contentView.bounds.width - 40)
        let x = (contentView.bounds.width - w) / 2
        plate.frame = CGRect(x: x, y: 2, width: w, height: contentView.bounds.height - 4)
        plate.layer.cornerRadius = 15
        img.frame = CGRect(x: x + 12, y: contentView.bounds.midY - 17, width: 34, height: 34)
        label.frame = CGRect(x: img.frame.maxX + 12, y: 0, width: max(1, w - 98), height: contentView.bounds.height)
        arrow.frame = CGRect(x: plate.frame.maxX - 38, y: 0, width: 26, height: contentView.bounds.height)
    }
}
