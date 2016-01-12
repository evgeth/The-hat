//
//  AboutTableViewCell.swift
//  thehat
//
//  Created by Eugene Yurtaev on 12/01/16.
//  Copyright © 2016 dpfbop. All rights reserved.
//

import UIKit

class AboutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var img: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
