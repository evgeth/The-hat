//
//  Extensions.swift
//  thehat
//
//  Created by Eugene Yurtaev on 24/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setNavigationBarTitleWithCustomFont(title: String) {
        let size = UIFont(name: "Avenir Next", size: 18)?.sizeOfString(title, constrainedToWidth: 200)
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size!))
        label.text = title
        label.font = UIFont(name: "Avenir Next", size: 18)
        self.navigationItem.titleView = label
    }
}


extension UIColor
{
    convenience init(r: Int, g: Int, b: Int, a: Int)
    {
        let newRed   = CGFloat(Double(r) / 255.0)
        let newGreen = CGFloat(Double(g) / 255.0)
        let newBlue  = CGFloat(Double(b) / 255.0)
        let newAlpha = CGFloat(Double(a) / 100.0)
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
}

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}