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


class PreparationViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate {
    var gameInstance = GameSingleton.gameInstance

    @IBOutlet weak var listener: UILabel!
    @IBOutlet weak var speaker: UILabel!
    
//    @IBOutlet weak var startImageView: UIImageView!
    
    @IBOutlet weak var startButtonView: ColorChangingView!
    var inactiveColor: UIColor!
    
    @IBOutlet weak var holdToStartLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    
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
        
        startButtonView.initializer(inactiveColor, finishColor: inactiveColor, requiredTouchDuration: 2, delegate: self)
        
        self.countdownSound = self.setupAudioPlayerWithFile("countdown", type:"wav")
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: self.startButtonView.frame.height))
        self.startButtonView.insertSubview(self.loadingView, atIndex: 0)
        self.loadingView.backgroundColor = UIColor(red: 109.0/256.0, green: 236.0/255.0, blue: 158.0/255.0, alpha: 1)
    }
    

    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        
        var audioPlayer:AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch _ as NSError {
            audioPlayer = nil
        }
        
        //4
        return audioPlayer!
    }



    override func viewWillAppear(animated: Bool) {
        Answers.logCustomEventWithName("Open Screen", customAttributes: ["Screen name": "Preparation"])
        
        let currentPlayers = gameInstance.currentPlayers()
        speaker.text = currentPlayers.0.name
        listener.text = currentPlayers.1.name
        var wordList = speaker.text!.componentsSeparatedByString(" ").filter{$0 != ""}
        if wordList.count == 1 {
            speaker.numberOfLines = 1
        }
        wordList = listener.text!.componentsSeparatedByString(" ").filter{$0 != ""}
        if wordList.count == 1 {
            listener.numberOfLines = 1
        }
        
        
        if (gameInstance.isNoMoreWords) {
            startLabel.text = NSLocalizedString("FINISH", comment: "Finish")
        }
        let roundNumber = gameInstance.getCurrentRound().number
        self.navigationItem.title = ""
        if roundNumber != 0 {
            self.navigationItem.setHidesBackButton(true, animated: false)
            let editWordsImage = UIImage(named: "Edit words")
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: editWordsImage, style: .Plain, target: self, action: Selector("editGuessedWords"))
        } else {
            navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!, NSForegroundColorAttributeName : UIColor.redColor()], forState: UIControlState.Normal)
        }
        var size = UIFont.systemFontOfSize(18).sizeOfString("\(gameInstance.newWords.count) " + String(NSLocalizedString("WORDS_LEFT", comment: "words left")), constrainedToWidth: 200)
        size.width += 10
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        label.text = "\(gameInstance.newWords.count) " + String(NSLocalizedString("WORDS_LEFT", comment: "words left"))
        label.textColor = view.tintColor
        label.font = UIFont(name: "Avenir Next", size: 18)
        label.textAlignment = NSTextAlignment.Right
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: Selector("closeButtonPressed")), UIBarButtonItem(customView: label)]
        
        notUndestandingHowToStartCounter = 0
        holdToStartLabel.hidden = true
        
        self.loadingViewWidth.constant = 0
        self.startButtonView.layoutIfNeeded()
    }
    
    func closeButtonPressed() {
        let alert = UIAlertController(title: nil, /* NSLocalizedString("PAUSE_TITLE", comment: "stop or pause title") */ message: nil /* NSLocalizedString("PAUSE_OR_STOP", comment: "Pause or stop the game") */,  preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("PAUSE", comment: "pause"), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("FINISH_GAME", comment: "finish game"), style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.proceedToResults()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "cancel"), style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.size.width - 26, y: 50, width: 1, height: 1)
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    
    func editGuessedWords() {
        let editWordsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EditGuessedWords") as! EditWordsGuessedViewController
        editWordsViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        editWordsViewController.gameInstance = self.gameInstance
        
        let popoverPC = editWordsViewController.popoverPresentationController
        popoverPC!.delegate = self
        popoverPC!.barButtonItem = self.navigationItem.leftBarButtonItem
        popoverPC!.backgroundColor = UIColor.whiteColor()
        self.presentViewController(editWordsViewController, animated: true, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func touchBegan() {
        if gameInstance.isNoMoreWords {
            return
        }
        countdownSound.play()
        loadingViewWidth.constant = self.startButtonView.frame.width
        UIView.animateWithDuration(2) { () -> Void in
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
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.holdToStartLabel.hidden = false
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
            Answers.logCustomEventWithName("Word guessed", customAttributes:
                ["word": word.word,
                    "status": state])
            Answers.logCustomEventWithName("Word_played_" + word.word, customAttributes:
                ["status": state])
        }
    }
    
    func requiredTouchDurationReached() {
        if (gameInstance.isNoMoreWords) {
            proceedToResults()
            return
        }
        let roundVC = storyboard?.instantiateViewControllerWithIdentifier("RoundViewController") as! RoundViewController
        sendWordsAnalytics()
        
        self.presentViewController(roundVC, animated: true, completion: nil)
    }
    
    func showCountdownLabel(viewToScale: UIView, scaleFrom: Double, scaleTo: Double) {
        viewToScale.hidden = false
        viewToScale.alpha = 1
        viewToScale.transform = CGAffineTransformMakeScale(CGFloat(scaleFrom), CGFloat(scaleFrom))
        
        UIView.animateKeyframesWithDuration(0.5, delay: 0.0, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            viewToScale.alpha = 1
            viewToScale.transform = CGAffineTransformMakeScale(CGFloat(scaleTo), CGFloat(scaleTo))
            }) { (error) -> Void in
                viewToScale.hidden = true
                viewToScale.transform = CGAffineTransformIdentity
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Results Segue" {
            sendWordsAnalytics()
        }
    }

    func proceedToResults() {
        if !isProceedingToResults {
            isProceedingToResults = true
            gameInstance.reinitialize()
            performSegueWithIdentifier("Results Segue", sender: nil)
        }
    }
}

