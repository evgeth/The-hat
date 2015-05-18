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
    var timerRate: Float!
    
    var currentWord: String!
    var wordsGuessed: [String]!
    
    var isGameEnded = false
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var timerViewHeightContraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        roundDuration = delegate?.game().roundDuration
        extraRoundDuration = delegate?.game().extraRoundDuration
        timerRate = 0.1
        secondsLeft = roundDuration + timerRate - 0.01
        timerFired()
        reloadWord()
        wordsGuessed = []
        timerView.layer.cornerRadius = 50
        timerView.layer.masksToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(timerRate), target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }
    
    func timerFired() {
        secondsLeft = secondsLeft - timerRate
        
        timerView.percent = CGFloat(secondsLeft / roundDuration)
        
        if secondsLeft <= -extraRoundDuration + 0.01 {
            timer!.invalidate()
            timer = nil
            timerView.percent = 0
            timerLabel.text = "0"
            isGameEnded = true
        } else if secondsLeft < 0 {
            timerView.percent = CGFloat(secondsLeft / extraRoundDuration)
            timerLabel.text = "\(Int(secondsLeft))"
            
        } else {
            timerLabel.text = "\(Int(secondsLeft + 1))"
        }
        timerView.setNeedsDisplay()
    }
    
    func endRound() {
        delegate?.setGuessedWordsInRound(self.wordsGuessed)
        delegate?.nextRound()
        
        dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func reloadWord() {
        currentWord = delegate!.getWord()
        wordLabel.text = currentWord
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func errorButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            var scale = CABasicAnimation(keyPath: "transform.scale")
            scale.duration = 0.3
            scale.repeatCount = 1
            scale.autoreverses = true
            scale.toValue = NSNumber(float: 2.0)
           self.wordLabel.layer.addAnimation(scale, forKey: nil)
        })
        if isGameEnded {
            endRound()
        }
    }
    

    @IBAction func guessed(sender: AnyObject) {
        wordsGuessed.append(currentWord)
        if isGameEnded {
            endRound()
        } else {
            reloadWord()
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
