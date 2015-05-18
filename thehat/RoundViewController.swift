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
    var secondsLeft: Float!
    var timer: NSTimer?
    var timerRate: Float!
    
    var currentWord: String!
    var wordsGuessed: [String]!
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        roundDuration = delegate?.game().roundDuration
        timerRate = 0.1
        secondsLeft = roundDuration + timerRate
        timerFired()
        reloadWord()
        wordsGuessed = []
    }
    
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(timerRate), target: self, selector: "timerFired", userInfo: nil, repeats: true)
    }
    
    func timerFired() {
        secondsLeft = secondsLeft - timerRate
        progressBar.setProgress(Float(secondsLeft / roundDuration), animated: true)
        if secondsLeft <= 0.0 {
            delegate?.setGuessedWordsInRound(self.wordsGuessed)
            delegate?.nextRound()
            timer!.invalidate()
            timer = nil
            dismissViewControllerAnimated(true, completion: { () -> Void in
                let alert = UIAlertView(title: "Guessed", message: ", ".join(self.wordsGuessed), delegate: nil, cancelButtonTitle: "Okay")
//                alert.show()

            })
        } else {
            if (Int(secondsLeft) == 1) {
                timerLabel.text = "1 second"
            } else {
                timerLabel.text = "\(Int(secondsLeft)) seconds"
            }
        }
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
    }
    

    @IBAction func guessed(sender: AnyObject) {
        wordsGuessed.append(currentWord)
        reloadWord()
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
