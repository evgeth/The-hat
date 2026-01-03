//
//  PreparationViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAnalytics

final class PreparationViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate, PopoverSaveDelegate {
    var gameInstance = GameSingleton.gameInstance
    private var defaultsService: DefaultsServiceProtocol = DefaultsService()
    private var usedWordsService: UsedWordsServiceProtocol = UsedWordsService.shared
    @IBOutlet weak var listener: UILabel!
    @IBOutlet weak var speaker: UILabel!
    //    @IBOutlet weak var startImageView: UIImageView!
    
    @IBOutlet weak var startButtonView: ColorChangingView!
    var inactiveColor: UIColor!
    
    @IBOutlet weak var holdToStartLabel: UILabel! {
        didSet {
            holdToStartLabel.text = LS.localizedString(forKey: "hold_to_start")
        }
    }
    @IBOutlet weak var startLabel: UILabel! {
        didSet {
            startLabel.text = LS.localizedString(forKey: "start")
        }
    }
    @IBOutlet weak var loadingViewWidth: NSLayoutConstraint!

    var loadingView: UIView!
    
    var notUndestandingHowToStartCounter = 0
    
    var isProceedingToResults: Bool = false
    
    var countdownSound: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentPlayers = gameInstance.currentPlayers()
        speaker.text = currentPlayers.0.name
        listener.text = currentPlayers.1.name
        
        
        inactiveColor = startButtonView.backgroundColor
        
        startButtonView.initializer(startColor: inactiveColor, finishColor: inactiveColor, requiredTouchDuration: 1.8, delegate: self)
        
        self.countdownSound = self.setupAudioPlayerWithFile(file: "countdown", type:"wav")
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: self.startButtonView.frame.height))
        self.startButtonView.insertSubview(self.loadingView, at: 0)
        self.loadingView.backgroundColor = AppColors.primary
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
        Analytics.logEvent("open_screen", parameters: ["screen_name": "Preparation"])
        
        let currentPlayers = gameInstance.currentPlayers()
        speaker.text = currentPlayers.0.name
        listener.text = currentPlayers.1.name
        var wordList = speaker.text!.components(separatedBy: " ").filter{$0 != ""}
        if wordList.count == 1 {
            speaker.numberOfLines = 1
        }
        wordList = listener.text!.components(separatedBy: " ").filter{$0 != ""}
        if wordList.count == 1 {
            listener.numberOfLines = 1
        }

        if gameInstance.isNoMoreWords {
            startLabel.text = LS.localizedString(forKey: "FINISH")
        }
        updateWordsLeft()
        
        
        notUndestandingHowToStartCounter = 0
        holdToStartLabel.isHidden = true
        
        self.loadingViewWidth.constant = 0
        self.startButtonView.layoutIfNeeded()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func updateWordsLeft() {
        let roundNumber = gameInstance.getCurrentRound().number
        self.navigationItem.title = ""
        if roundNumber != 0 {
            self.navigationItem.setHidesBackButton(true, animated: false)
            let editWordsImage = UIImage(named: "Edit words")
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: editWordsImage, style: .plain, target: self, action: #selector(self.editGuessedWords))
        } else {
            navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Excalifont", size: 18)!, NSAttributedString.Key.foregroundColor : UIColor.red], for: UIControl.State.normal)
        }
        var size = UIFont.systemFont(ofSize: 18).sizeOfString(string: "\(gameInstance.newWords.count) " + String(LS.localizedString(forKey: "WORDS_LEFT")), constrainedToWidth: 200)
        size.width += 10
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        label.text = "\(gameInstance.newWords.count) " + String(LS.localizedString(forKey: "WORDS_LEFT"))
        label.textColor = AppColors.primaryDark
        label.font = UIFont(name: "Excalifont", size: 18)
        label.textAlignment = NSTextAlignment.right
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(self.closeButtonPressed)), UIBarButtonItem(customView: label)]
    }
    
    @objc func closeButtonPressed() {
        let alert = UIAlertController(title: nil, /* NSLocalizedString("PAUSE_TITLE", comment: "stop or pause title") */ message: nil /* NSLocalizedString("PAUSE_OR_STOP", comment: "Pause or stop the game") */,  preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: LS.localizedString(forKey: "PAUSE"), style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: LS.localizedString(forKey: "FINISH_GAME"), style: UIAlertAction.Style.destructive, handler: { (action) -> Void in
            self.proceedToResults()
        }))
        alert.addAction(UIAlertAction(title: LS.localizedString(forKey: "CANCEL"), style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(alert, animated: true, completion: nil)

    }

    @objc func editGuessedWords() {
        let editWordsViewController = self.storyboard!.instantiateViewController(withIdentifier: "EditGuessedWords") as! EditWordsGuessedViewController
        editWordsViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        editWordsViewController.gameInstance = self.gameInstance
        editWordsViewController.saveDelegate = self
        
        let popoverPC = editWordsViewController.popoverPresentationController
        popoverPC!.delegate = self
        popoverPC!.barButtonItem = self.navigationItem.leftBarButtonItem
        popoverPC!.backgroundColor = UIColor.white
        popoverPC?.delegate = self

        self.present(editWordsViewController, animated: true, completion: nil)
    }
    
    func updated() {
        self.updateWordsLeft()
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func touchBegan() {
        if gameInstance.isNoMoreWords {
            return
        }
        countdownSound?.play()
        loadingViewWidth.constant = self.startButtonView.frame.width
        UIView.animate(withDuration: 1.8) { () -> Void in
            self.startButtonView.layoutIfNeeded()
        }
    }
    
    func touchEnded() {
        countdownSound?.pause()
        countdownSound?.currentTime = 0.0
        if gameInstance.isNoMoreWords {
            proceedToResults()
            return
        }
        self.loadingViewWidth.constant = 0
        self.startButtonView.layoutIfNeeded()
        notUndestandingHowToStartCounter += 1
        if notUndestandingHowToStartCounter == 1 {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.holdToStartLabel.isHidden = false
            })
        }
    }
    
    func sendWordsAnalytics() {
        guard let round = gameInstance.getPreviousRound() else {
            return
        }
        for word in round.guessedWords {
            var state = "New"
            if word.state == State.fail {
                state = "Fail"
            } else if word.state == State.guessed {
                state = "Guessed"
            }
            Analytics.logEvent("word_guessed", parameters:
                ["word": word.word,
                    "status": state])
            Analytics.logEvent("word_played_\(word.word)", parameters:
                ["status": state])
        }
    }
    
    func requiredTouchDurationReached() {
        if (gameInstance.isNoMoreWords) {
            proceedToResults()
            return
        }
        let roundVC = storyboard?.instantiateViewController(withIdentifier: "RoundViewController") as! RoundViewController
        sendWordsAnalytics()
        
        
        navigationController?.pushViewController(roundVC, animated: true)
    }
    
    func showCountdownLabel(viewToScale: UIView, scaleFrom: Double, scaleTo: Double) {
        viewToScale.isHidden = false
        viewToScale.alpha = 1
        viewToScale.transform = CGAffineTransform(scaleX: CGFloat(scaleFrom), y: CGFloat(scaleFrom))
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: UIView.KeyframeAnimationOptions.beginFromCurrentState, animations: { () -> Void in
            viewToScale.alpha = 1
            viewToScale.transform = CGAffineTransform(scaleX: CGFloat(scaleTo), y: CGFloat(scaleTo))
            }) { (error) -> Void in
                viewToScale.isHidden = true
                viewToScale.transform = CGAffineTransform.identity
                
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Results Segue" {
            sendWordsAnalytics()
        }
    }

    func proceedToResults() {
        if !isProceedingToResults {
            isProceedingToResults = true
            var history = defaultsService.gamesHistory
            history.append(GameHistoryItem(game: gameInstance))
            defaultsService.gamesHistory = history

            // Mark all played words as used to avoid repetition in future games
            let playedWords = gameInstance.rounds.flatMap { $0.guessedWords.map { $0.word } }
            usedWordsService.markWordsAsUsed(playedWords)

            gameInstance.wordsInTheHat = 60
            gameInstance.reinitialize()
            performSegue(withIdentifier: "Results Segue", sender: nil)
        }
    }
}

protocol PopoverSaveDelegate {
    func updated()
}

