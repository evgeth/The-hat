//
//  TimerView.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class TimerView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var percent: CGFloat = 1.0
    
    func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI) / 180.0
    }
    
    override func drawRect(rect: CGRect) {
        var bezierPath = UIBezierPath()
        var center = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
        bezierPath.addArcWithCenter(center, radius: CGFloat(45.0), startAngle: degreesToRadians(-90), endAngle: degreesToRadians(270) - degreesToRadians(360) * (1 - percent), clockwise: true)
        bezierPath.lineWidth = 10
        bezierPath.lineCapStyle = kCGLineCapRound
        if percent < 0 {
            UIColor.redColor().setStroke()
        } else {
            UIColor(red: CGFloat(0), green: CGFloat(192.0 / 256.0), blue: CGFloat(50.0 / 256.0), alpha: 0.9).setStroke()
        }
        bezierPath.stroke()
    }

}
