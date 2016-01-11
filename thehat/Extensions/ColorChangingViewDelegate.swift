//
//  ColorChangingViewDelegate.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

@objc protocol ColorChangingViewDelegate {
    optional func touchEnded()
    optional func touchBegan()
    
    func requiredTouchDurationReached()
    
    optional func firedFunc(number: Int)
}