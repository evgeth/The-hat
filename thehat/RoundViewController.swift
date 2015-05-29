//
//  GameViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class RoundViewController: UIViewController, ColorChangingViewDelegate {

    
    var gameInstance: Game?
    var roundDuration: Float!
    var extraRoundDuration: Float!
    var secondsLeft: Float!
    var timer: NSTimer?
    var timerRate: Float = 0.01
    
    var currentWord: String!
    var wordsGuessed = [Word]()
    
    var isRoundEnded = false
    var isBasicTimeEnded = false
    var isBasicTimeAlmostEnded = false
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var timerViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var redErrorView: ColorChangingView!
    var inactiveColor: UIColor!
    
    var isRoundVCDismissed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        roundDuration = gameInstance?.roundDuration
        extraRoundDuration = gameInstance?.extraRoundDuration
        secondsLeft = roundDuration + timerRate - 0.01
        timerFired()
        reloadWord()
        wordsGuessed = []
        timerView.layer.cornerRadius = 50
        timerView.layer.masksToBounds = true
        inactiveColor = redErrorView.backgroundColor
        
        redErrorView.initializer(startColor: inactiveColor, finishColor: UIColor(r: 184, g: 49, b: 49, a: 80), requiredTouchDuration: 0.6, delegate: self)
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
            isBasicTimeAlmostEnded = true
            if secondsLeft < 0 {
                isBasicTimeEnded = true
                timerView.percent = CGFloat(secondsLeft / extraRoundDuration)
                timerLabel.text = "\(Int(secondsLeft))"
            } else {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.timerLabel.text = "\(Int(self.secondsLeft + 1))"
                })
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
        isRoundEnded = true
        let transitionOptions = UIViewAnimationOptions.TransitionCurlUp
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.redErrorView.backgroundColor = UIColor(r: 184, g: 49, b: 49, a: 80)
            self.errorLabel.text = "No way (hold for mistake)"
        })
    }
    
    func endRound() {
        if !isRoundVCDismissed {
            gameInstance?.nextRound()
            gameInstance?.setGuessedWordsForRound(self.wordsGuessed)
            dismissViewControllerAnimated(true, completion: nil)
            isRoundVCDismissed = true
        }
    }
    
    func reloadWord() {
        currentWord = gameInstance!.getWord()
        if currentWord == "" && gameInstance!.isNoMoreWords {
            endRound()
            return
        }
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
        wordsGuessed.append(Word(word: currentWord))
        wordsGuessed.last!.state = .Guessed
        if isBasicTimeEnded {
            setRoundEndedState()
            endRound()
        }
        if isRoundEnded {
            endRound()
        } else {
            reloadWord()
        }
        
    }
    
    func requiredTouchDurationReached() {
        wordsGuessed.append(Word(word: currentWord))
        wordsGuessed.last!.state = State.Fail
        endRound()
    }
    
    func touchEnded() {
        if isRoundEnded {
            endRound()
        }
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
