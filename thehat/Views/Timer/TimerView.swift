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
        return degrees * CGFloat(Double.pi) / 180.0
    }
    
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        let center = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
        bezierPath.addArc(withCenter: center, radius: CGFloat(47.0), startAngle: degreesToRadians(degrees: -90), endAngle: degreesToRadians(degrees: 270) - degreesToRadians(degrees: 360) * (1 - percent), clockwise: true)
        bezierPath.lineWidth = 6
        bezierPath.lineCapStyle = CGLineCap.round
        if percent < 0 {
            AppColors.fail.setStroke()
        } else {
            AppColors.primaryDark.setStroke()
        }
        bezierPath.stroke()
    }

}
