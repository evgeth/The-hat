//
//  PreparationViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import AVFoundation
import Crashlytics


class PreparationViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate, PopoverSaveDelegate {
    var gameInstance = GameSingleton.gameInstance

    @IBOutlet weak var listener: UILabel!
    @IBOutlet weak var speaker: UILabel!
    //    @IBOutlet weak var startImageView: UIImageView!
    
    @IBOutlet weak var startButtonView: ColorChangingView!
    var inactiveColor: UIColor!
    
    @IBOutlet weak var holdToStartLabel: UILabel! {
        didSet {
            holdToStartLabel.text = LanguageChanger.shared.localizedString(forKey: "hold_to_start")
        }
    }
    @IBOutlet weak var startLabel: UILabel! {
        didSet {
            startLabel.text = LanguageChanger.shared.localizedString(forKey: "start")
        }
    }
    
    var loadingView: UIView!
    
    var notUndestandingHowToStartCounter = 0
    
    @IBOutlet weak var loadingViewWidth: NSLayoutConstraint!
    var isProceedingToResults: Bool = false
    
    var countdownSound = AVAudioPlayer()

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
        self.loadingView.backgroundColor = UIColor(red: 109.0/256.0, green: 236.0/255.0, blue: 158.0/255.0, alpha: 1)
    }
    

    func setupAudioPlayerWithFile(file:String, type:String) -> AVAudioPlayer  {
        //1
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = URL.init(fileURLWithPath: path!)
        
        
        
        var audioPlayer:AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch _ {
            audioPlayer = nil
        }
        
        //4
        return audioPlayer!
    }



    override func viewWillAppear(_ animated: Bool) {
        Answers.logCustomEvent(withName: "Open Screen", customAttributes: ["Screen name": "Preparation"])
        
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
            startLabel.text = LanguageChanger.shared.localizedString(forKey: "FINISH")
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
            navigationItem.backBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 18)!, NSAttributedString.Key.foregroundColor : UIColor.red], for: UIControl.State.normal)
        }
        var size = UIFont.systemFont(ofSize: 18).sizeOfString(string: "\(gameInstance.newWords.count) " + String(        LanguageChanger.shared.localizedString(forKey: "WORDS_LEFT")), constrainedToWidth: 200)
        size.width += 10
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        label.text = "\(gameInstance.newWords.count) " + String(LanguageChanger.shared.localizedString(forKey: "WORDS_LEFT"))
        label.textColor = UIColor(red: 0.272523, green: 0.594741, blue: 0.400047, alpha: 1)
        label.font = UIFont(name: "Avenir Next", size: 18)
        label.textAlignment = NSTextAlignment.right
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(self.closeButtonPressed)), UIBarButtonItem(customView: label)]
    }
    
    @objc func closeButtonPressed() {
        let alert = UIAlertController(title: nil, /* NSLocalizedString("PAUSE_TITLE", comment: "stop or pause title") */ message: nil /* NSLocalizedString("PAUSE_OR_STOP", comment: "Pause or stop the game") */,  preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: LanguageChanger.shared.localizedString(forKey: "PAUSE"), style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: LanguageChanger.shared.localizedString(forKey: "FINISH_GAME"), style: UIAlertAction.Style.destructive, handler: { (action) -> Void in
            self.proceedToResults()
        }))
        alert.addAction(UIAlertAction(title: LanguageChanger.shared.localizedString(forKey: "CANCEL"), style: UIAlertAction.Style.cancel, handler: nil))
        
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
        countdownSound.play()
        loadingViewWidth.constant = self.startButtonView.frame.width
        UIView.animate(withDuration: 1.8) { () -> Void in
            self.startButtonView.layoutIfNeeded()
        }
    }
    
    func touchEnded() {
        countdownSound.pause()
        countdownSound.currentTime = 0.0
        if (gameInstance.isNoMoreWords) {
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
            if word.state == State.Fail {
                state = "Fail"
            } else if word.state == State.Guessed {
                state = "Guessed"
            }
            Answers.logCustomEvent(withName: "Word guessed", customAttributes:
                ["word": word.word,
                    "status": state])
            Answers.logCustomEvent(withName: "Word_played_" + word.word, customAttributes:
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
            gameInstance.reinitialize()
            performSegue(withIdentifier: "Results Segue", sender: nil)
        }
    }
}

protocol PopoverSaveDelegate {
    func updated()
}

