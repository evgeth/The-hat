//
//  PlayerTableViewCellDelegate.swift
//  thehat
//
//  Created by Eugene Yurtaev on 07/06/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Foundation

protocol PlayerTableViewCellDelegate {
    func deleteButtonPressed(_ indexPath: IndexPath)
    
    func indexPathForCell(cell: UITableViewCell) -> IndexPath
}
