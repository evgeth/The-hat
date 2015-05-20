//
//  GameViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class RoundViewController: UIViewController {

    
    var delegate: GameDelegate?
    var roundDuration: Float!
    var extraRoundDuration: Float!
    var secondsLeft: Float!
    var timer: NSTimer?
    var timerRate: Float = 0.01
    
    var currentWord: String!
    var wordsGuessed: [String]!
    
    var isGameEnded = false
    var isBasicTimeEnded = false
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var timerViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var redErrorView: UIView!
    var mistakeTouchTimer: NSTimer?
    var inactiveColor: UIColor!
    var mistakeTouchDuraton: CGFloat = 0
    var mistakeTouchTimerRate: Double = 0.03
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        roundDuration = delegate?.game().roundDuration
        extraRoundDuration = delegate?.game().extraRoundDuration
        secondsLeft = roundDuration + timerRate - 0.01
        timerFired()
        reloadWord()
        wordsGuessed = []
        timerView.layer.cornerRadius = 50
        timerView.layer.masksToBounds = true
        inactiveColor = redErrorView.backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(timerRate), target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func timerFired() {
        secondsLeft = secondsLeft - timerRate
        
        timerView.percent = CGFloat(secondsLeft / roundDuration)
        
        if secondsLeft <= -extraRoundDuration + 0.01 {
            setRoundEndedState()
        } else if secondsLeft < 1 {
            isBasicTimeEnded = true
            if secondsLeft < 0 {
                timerView.percent = CGFloat(secondsLeft / extraRoundDuration)
                timerLabel.text = "\(Int(secondsLeft))"
            } else {
                timerLabel.text = "\(Int(secondsLeft + 1))"
            }
        } else {
            timerLabel.text = "\(Int(secondsLeft + 1))"
        }
        timerView.setNeedsDisplay()
    }
    
    func setRoundEndedState() {
        timer?.invalidate()
        timer = nil
        timerView.percent = 0
        timerLabel.text = "0"
        isGameEnded = true
        let transitionOptions = UIViewAnimationOptions.TransitionCurlUp
//        UIView.transitionWithView(redErrorView, duration: 0.3, options: transitionOptions, animations: {
//            self.errorLabel.text = "No way (hold for mistake)"
//            },
//            completion: nil)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.redErrorView.backgroundColor = UIColor.redColor()
            self.errorLabel.text = "No way (hold for mistake)"
        })
    }
    
    func endRound() {
        delegate?.setGuessedWordsInRound(self.wordsGuessed)
        delegate?.nextRound()
        
        dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func reloadWord() {
        currentWord = delegate!.getWord()
        let transitionOptions = UIViewAnimationOptions.TransitionFlipFromBottom
        UIView.transitionWithView(wordLabel, duration: 0.3, options: transitionOptions, animations: {
            self.wordLabel.text = self.currentWord
            },
            completion: nil)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func guessed(sender: AnyObject) {
        wordsGuessed.append(currentWord)
        if isBasicTimeEnded {
            setRoundEndedState()
            endRound()
        }
        if isGameEnded {
            endRound()
        } else {
            reloadWord()
        }
        
    }
    
    @IBAction func mistakeButtonTouchStarted(sender: UIButton) {
        mistakeTouchTimer = NSTimer.scheduledTimerWithTimeInterval(mistakeTouchTimerRate, target: self, selector: "mistakeTouchTimerFired", userInfo: nil, repeats: true)
    }
    
    @IBAction func mistakeButtonTouchEnded(sender: AnyObject) {
        if isBasicTimeEnded {
            endRound()
        }
        clearMistakeTouchTimer()
    }
    
    @IBAction func mistakeButtonTouchCancelled(sender: UIButton) {
        clearMistakeTouchTimer()
    }
    
    func clearMistakeTouchTimer() {
        mistakeTouchTimer?.invalidate()
        mistakeTouchTimer = nil
        redErrorView.backgroundColor = inactiveColor
        mistakeTouchDuraton = 0
    }
    
    func mistakeTouchTimerFired() {
        mistakeTouchDuraton += CGFloat(mistakeTouchTimerRate)

        var neededTouchDuration: CGFloat = 1.5
        if mistakeTouchDuraton >= neededTouchDuration {
            endRound()
        }
        var components = CGColorGetComponents(UIColor.redColor().CGColor)
        var inactiveColorComponents = CGColorGetComponents(inactiveColor.CGColor)
        redErrorView.backgroundColor = UIColor(red: inactiveColorComponents[0] + (components[0] - inactiveColorComponents[0]) * (mistakeTouchDuraton / neededTouchDuration), green: inactiveColorComponents[1] + (components[1] - inactiveColorComponents[1]) * (mistakeTouchDuraton / neededTouchDuration), blue: inactiveColorComponents[2] + (components[2] - inactiveColorComponents[2]) * (mistakeTouchDuraton / neededTouchDuration), alpha: 1)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
