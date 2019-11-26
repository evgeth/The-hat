//
//  ColorChangingView.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class ColorChangingView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var startColor: UIColor!
    var finishColor: UIColor!
    var requiredTouchDuration: Double!
    var timerRate: Double = 0.01
    var startTouchTimer: Timer!
    var touchDuration: Double = 0
    var lastFired: Double = 0
    var numberOfCounts = 0
    var delegate: ColorChangingViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initializer(startColor: UIColor = UIColor.white, finishColor: UIColor = UIColor.black, requiredTouchDuration: Double = 1.0, delegate: ColorChangingViewDelegate) {
        self.startColor = startColor
        self.finishColor = finishColor
        self.requiredTouchDuration = requiredTouchDuration
        self.delegate = delegate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchBegan?()
        // TODO(FIX!!!) and enable next line
        startTouchTimer = Timer.scheduledTimer(timeInterval: timerRate, target: self, selector: Selector(("touchTimerFired")), userInfo: nil, repeats: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchEnded?()
        clearTouchTimer()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        clearTouchTimer()
    }
    
    func clearTouchTimer() {
        startTouchTimer?.invalidate()
        startTouchTimer = nil
        self.backgroundColor = startColor
        touchDuration = 0
        lastFired = 0
        numberOfCounts = 0
    }
    
    @objc func touchTimerFired() {
        touchDuration += timerRate
        
        if lastFired + 0.1 < touchDuration || lastFired == 0 {
            delegate?.firedFunc?(number: numberOfCounts)
            numberOfCounts += 1
            lastFired = touchDuration
        }
        
        if touchDuration >= requiredTouchDuration {
            clearTouchTimer()
            delegate?.requiredTouchDurationReached()
        }
        let finishColorComponents = finishColor.cgColor.components!
        let startColorComponents = startColor.cgColor.components!

        let percentage = min(CGFloat(touchDuration / requiredTouchDuration), 1.0)
        self.backgroundColor = UIColor(red: startColorComponents[0] + (finishColorComponents[0] - startColorComponents[0]) * percentage, green: startColorComponents[1] + (finishColorComponents[1] - startColorComponents[1]) * percentage, blue: startColorComponents[2] + (finishColorComponents[2] - startColorComponents[2]) * percentage, alpha: startColorComponents[3] + (finishColorComponents[3] - startColorComponents[3]) * percentage)
    }
    
}
