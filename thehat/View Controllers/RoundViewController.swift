//
//  GameViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import AVFoundation
import Crashlytics


class RoundViewController: UIViewController, ColorChangingViewDelegate {

    
    var gameInstance = GameSingleton.gameInstance
    var roundDuration: Float!
    var extraRoundDuration: Float!
    var secondsLeft: Float!
    var timer: Timer?
    var timerRate: Float = 0.01
    
    var currentWord: String!
    var wordsGuessed = [Word]()
    
    var isRoundEnded = false
    var isBasicTimeEnded = false
    var isBasicTimeAlmostEnded = false
    var isExtraTimeEnded = false
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var timerViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var redErrorView: ColorChangingView!
    var inactiveColor: UIColor!
    
    var isRoundVCDismissed: Bool = false
    
    var scoreSound = AVAudioPlayer()
    var failSound = AVAudioPlayer()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        roundDuration = gameInstance.roundDuration
        extraRoundDuration = gameInstance.extraRoundDuration
        secondsLeft = roundDuration + timerRate - 0.01
        timerFired()
        reloadWord()
        wordsGuessed = []
        timerView.layer.cornerRadius = 50
        timerView.layer.masksToBounds = true
        inactiveColor = redErrorView.backgroundColor
        
        redErrorView.initializer(startColor: inactiveColor, finishColor: UIColor(r: 184, g: 49, b: 49, a: 80), requiredTouchDuration: 0.6, delegate: self)
        
        self.scoreSound = self.setupAudioPlayerWithFile(file: "score", type:"wav")
        self.failSound = self.setupAudioPlayerWithFile(file: "mistake", type:"wav")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: Double(timerRate), target: self, selector: Selector(("timerFired")), userInfo: nil, repeats: true)
    }
    
    func setupAudioPlayerWithFile(file:String, type:String) -> AVAudioPlayer  {
        //1
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = URL(fileURLWithPath: path!)
        
        var audioPlayer:AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch _  {
            audioPlayer = nil
        }
        
        //4
        return audioPlayer!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Answers.logCustomEvent(withName: "Open Screen", customAttributes: ["Screen name": "Main Menu"])
    }
    
    @objc func timerFired() {
        if isRoundVCDismissed {
            return
        }
        secondsLeft = secondsLeft - timerRate
        
        timerView.percent = CGFloat(secondsLeft / roundDuration)
        
        if secondsLeft <= -extraRoundDuration + 0.01 {
            isExtraTimeEnded = true
            setRoundEndedState()
            failSound.play()
        } else if secondsLeft < 1 {
            isBasicTimeAlmostEnded = true
            if secondsLeft < 0 {
                if !isBasicTimeEnded {
                    failSound.play()
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.redErrorView.backgroundColor = UIColor(r: 184, g: 49, b: 49, a: 80)
                        self.errorLabel.text = NSLocalizedString("NO_WAY", comment: "No way (hold for mistake)")
                    })
                }
                isBasicTimeEnded = true
                timerView.percent = CGFloat(secondsLeft / extraRoundDuration)
                timerLabel.text = "\(Int(secondsLeft))"
                
            } else {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
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
//        if isExtraTimeEnded {
//            wordsGuessed.append(Word(word: currentWord))
//            wordsGuessed.last!.state = State.New
//        }
    }
    
    func endRound() {
        if !isRoundVCDismissed {
            gameInstance.nextRound()
            gameInstance.setGuessedWordsForRound(guessedWords: self.wordsGuessed)
            dismiss(animated: true, completion: nil)
            isRoundVCDismissed = true
        }
    }
    
    func reloadWord() {
        currentWord = gameInstance.getWord()
        if currentWord == "" && gameInstance.isNoMoreWords {
            endRound()
            return
        }
        let transitionOptions = UIView.AnimationOptions.transitionFlipFromBottom
        UIView.transition(with: wordLabel, duration: 0.3, options: transitionOptions, animations: {
            self.wordLabel.text = self.currentWord
            },
            completion: nil)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func guessed(_ sender: AnyObject) {
        wordsGuessed.append(Word(word: currentWord))
        wordsGuessed.last!.state = .Guessed
        if scoreSound.isPlaying {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.scoreSound.pause()
                self.scoreSound.currentTime = 0.0
            }, completion: { (error) -> Void in
                self.scoreSound.play()
            })
        } else {
            scoreSound.play()
        }
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
        if isBasicTimeEnded {
            wordsGuessed.append(Word(word: currentWord))
            wordsGuessed.last!.state = State.New
            endRound()
        }
    }
    

}
