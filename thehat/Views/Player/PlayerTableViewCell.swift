//
//  PlayerTableViewCell.swift
//  thehat
//
//  Created by Eugene Yurtaev on 25/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var playerLabel: UITextField!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    weak var delegate: PlayerTableViewCellDelegate?
    private let initialBadge = UILabel()
    private var usesWarmAppearance = false

    func applyWarmAppearance() {
        if !usesWarmAppearance {
            usesWarmAppearance = true
            // Own the name layout explicitly: UIKit can reapply storyboard
            // constraints when an editing cell is reused or moved.
            NSLayoutConstraint.deactivate(contentView.constraints.filter {
                $0.firstItem as? UIView === playerLabel || $0.secondItem as? UIView === playerLabel
            })
            playerLabel.translatesAutoresizingMaskIntoConstraints = true
            playerLabel.addTarget(self, action: #selector(updateInitial), for: .editingChanged)
            initialBadge.font = WarmUI.displayFont(17)
            initialBadge.textAlignment = .center
            initialBadge.textColor = AppColors.textPrimary
            initialBadge.backgroundColor = AppColors.secondary
            initialBadge.layer.cornerRadius = 16
            initialBadge.clipsToBounds = true
            initialBadge.isUserInteractionEnabled = false
            initialBadge.isAccessibilityElement = false
            contentView.addSubview(initialBadge)
        }
        playerLabel.font = .systemFont(ofSize: 18, weight: .medium)
        playerLabel.textColor = AppColors.textPrimary
        playerLabel.accessibilityIdentifier = "setup.playerName"
        playerLabel.placeholder = LS.localizedString(forKey: "warm_player_placeholder")
        deleteButton.setTitle(LS.localizedString(forKey: "warm_delete"), for: .normal)
        backgroundColor = .clear
        updateInitial()
        setNeedsLayout()
    }

    @objc private func updateInitial() {
        initialBadge.text = String((playerLabel.text ?? "").prefix(1)).uppercased()
        if initialBadge.text?.isEmpty != false { initialBadge.text = "·" }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard usesWarmAppearance else { return }
        let bounds = contentView.bounds
        initialBadge.frame = CGRect(x: 14, y: bounds.midY - 16, width: 32, height: 32)
        playerLabel.frame = CGRect(x: 58, y: 4, width: max(1, bounds.width - 70), height: bounds.height - 8)
        updateInitial()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let indexPath = delegate?.indexPathForCell(cell: self)
        delegate?.deleteButtonPressed(indexPath!)
    }
}
