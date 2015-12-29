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
    var delegate: PlayerTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func deleteButtonPressed(sender: UIButton) {
        let indexPath = delegate?.indexPathForCell(self)
        delegate?.deleteButtonPressed(indexPath!)
    }
}
