//
//  GameViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAnalytics

final class RoundViewController: UIViewController, ColorChangingViewDelegate {

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
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.text = LS.localizedString(forKey: "mistake")
        }
    }
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var timerViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var gotItLabel: UILabel! {
        didSet {
            gotItLabel.text = LS.localizedString(forKey: "got_it")
        }
    }

    @IBOutlet weak var redErrorView: ColorChangingView!
    var inactiveColor: UIColor!
    
    var isRoundVCDismissed: Bool = false
    
    var scoreSound: AVAudioPlayer?
    var failSound: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        roundDuration = gameInstance.roundDuration
        extraRoundDuration = gameInstance.extraRoundDuration
        secondsLeft = roundDuration + timerRate - 0.01
        timerFired()
        reloadWord()
        wordsGuessed = []
        timerView.layer.cornerRadius = 50
        timerView.layer.masksToBounds = true
        inactiveColor = redErrorView.backgroundColor
        
        redErrorView.initializer(startColor: inactiveColor, finishColor: AppColors.fail, requiredTouchDuration: 0.6, delegate: self)
        
        self.scoreSound = self.setupAudioPlayerWithFile(file: "score", type:"wav")
        self.failSound = self.setupAudioPlayerWithFile(file: "mistake", type:"wav")
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(
            timeInterval: Double(timerRate),
            target: self,
            selector: #selector(self.timerFired),
            userInfo: nil,
            repeats: true
        )
    }

    func setupAudioPlayerWithFile(file: String, type: String) -> AVAudioPlayer? {
        guard let path = Bundle.main.path(forResource: file, ofType: type) else {
            print("Audio file not found: \(file).\(type)")
            return nil
        }
        let url = URL(fileURLWithPath: path)

        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Failed to create audio player: \(error)")
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("open_screen", parameters: ["screen_name": "Main Menu"])
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
            failSound?.play()
        } else if secondsLeft < 1 {
            isBasicTimeAlmostEnded = true
            if secondsLeft < 0 {
                if !isBasicTimeEnded {
                    failSound?.play()
                    UIView.animate(withDuration: 0.3) {
                        self.redErrorView.backgroundColor = AppColors.fail
                        self.errorLabel.text = LS.localizedString(forKey: "NO_WAY")
                    }
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
    }
    
    func endRound() {
        if !isRoundVCDismissed {
            gameInstance.nextRound()
            gameInstance.setGuessedWordsForRound(guessedWords: self.wordsGuessed)
            navigationController?.popViewController(animated: true)
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

    @IBAction func guessed(_ sender: AnyObject) {
        let word = Word(word: currentWord)
        word.state = .guessed
        wordsGuessed.append(word)
        if scoreSound?.isPlaying == true {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.scoreSound?.pause()
                self.scoreSound?.currentTime = 0.0
            }, completion: { _ in
                self.scoreSound?.play()
            })
        } else {
            scoreSound?.play()
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
        let word = Word(word: currentWord)
        word.state = .fail
        wordsGuessed.append(word)
        endRound()
    }

    func touchEnded() {
        if isBasicTimeEnded {
            let word = Word(word: currentWord)
            word.state = .new
            wordsGuessed.append(word)
            endRound()
        }
    }
}
