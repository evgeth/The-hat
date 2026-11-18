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
    
    let actionHint = UILabel()
    let actionSymbol = UILabel()
    private let skipButton = UIButton(type: .custom)

    var currentWord: String!
    var wordsGuessed = [Word]()
    
    var isRoundEnded = false
    var isBasicTimeEnded = false
    var isBasicTimeAlmostEnded = false
    var isExtraTimeEnded = false
    
    @IBOutlet weak var wordPaper: NotebookWordView!
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
    // Keep the card slide playing through the handoff if the last word is skipped.
    // Kenney, Casino Audio (CC0), card-slide-4: https://kenney.nl/assets/casino-audio
    private static let skipSound = setupAudioPlayerWithFile(file: "skip", type: "wav")

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
        
        scoreSound = Self.setupAudioPlayerWithFile(file: "score", type: "wav")
        failSound = Self.setupAudioPlayerWithFile(file: "mistake", type: "wav")
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        WarmUI.round(self)
        if gameInstance.allowsSkipping {
            Self.skipSound?.prepareToPlay()
            skipButton.accessibilityIdentifier = "round.skip"
            skipButton.addTarget(self, action: #selector(skipWord), for: .touchUpInside)
            redErrorView.addSubview(skipButton)
        }
        updateSecondaryAction()
    }

    private func updateSecondaryAction() {
        let skipping = gameInstance.allowsSkipping
        let title = isBasicTimeEnded ? "round_not_guessed" : skipping ? "skip_word" : "mistake"
        let hint = isBasicTimeEnded ? (skipping ? "tap_to_return" : "overtime_actions") : skipping ? "skip_no_penalty" : "hold_to_end"
        actionSymbol.text = isBasicTimeEnded ? "↶" : skipping ? "→" : "×"
        if isBasicTimeEnded {
            redErrorView.startColor = AppColors.returnedWord
            redErrorView.backgroundColor = AppColors.returnedWord
        }
        errorLabel.text = LS.localizedString(forKey: title)
        actionHint.text = LS.localizedString(forKey: hint)
        skipButton.accessibilityLabel = errorLabel.text
        skipButton.accessibilityHint = actionHint.text
    }

    @objc private func skipWord() {
        guard gameInstance.allowsSkipping, !isRoundVCDismissed, !wordPaper.isChangingWord else { return }
        if !isBasicTimeEnded, let sound = Self.skipSound {
            sound.currentTime = 0
            sound.play()
        }
        // A .new entry returns to the hat when the turn is committed. It
        // cannot be redrawn during this turn, even if it was the last word.
        wordsGuessed.append(Word(word: currentWord))
        if isBasicTimeEnded || gameInstance.isNoMoreWords { endRound() }
        else { reloadWord() }
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

    private static func setupAudioPlayerWithFile(file: String, type: String) -> AVAudioPlayer? {
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
                    isBasicTimeEnded = true
                    updateSecondaryAction()
                }
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
            isRoundVCDismissed = true
            setRoundEndedState()
            gameInstance.nextRound()
            gameInstance.setGuessedWordsForRound(guessedWords: self.wordsGuessed)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func reloadWord() {
        currentWord = gameInstance.getWord()
        if currentWord == "" && gameInstance.isNoMoreWords {
            endRound()
            return
        }
        wordPaper.show(currentWord)
    }

    @IBAction func guessed(_ sender: AnyObject) {
        guard !isRoundVCDismissed, !wordPaper.isChangingWord else { return }
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
        if isBasicTimeEnded || isRoundEnded {
            endRound()
        } else {
            reloadWord()
        }
    }
    
    func requiredTouchDurationReached() {
        guard !gameInstance.allowsSkipping, !isRoundVCDismissed else { return }
        let word = Word(word: currentWord)
        word.state = .fail
        wordsGuessed.append(word)
        endRound()
    }

    func touchEnded() {
        guard !gameInstance.allowsSkipping, !isRoundVCDismissed else { return }
        if !isBasicTimeEnded {
            actionHint.text = LS.localizedString(forKey: "keep_holding")
            UISelectionFeedbackGenerator().selectionChanged()
            return
        }
        wordsGuessed.append(Word(word: currentWord))
        endRound()
    }
}
