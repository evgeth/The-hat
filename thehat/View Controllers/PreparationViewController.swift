//
//  PreparationViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import AVFoundation

class PreparationViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate {
    var gameInstance: Game?

    @IBOutlet weak var listener: UILabel!
    @IBOutlet weak var speaker: UILabel!
    
//    @IBOutlet weak var startImageView: UIImageView!
    
    @IBOutlet weak var startButtonView: ColorChangingView!
    var inactiveColor: UIColor!
    @IBOutlet weak var holdToStartLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    var notUndestandingHowToStartCounter = 0
    
    var isProceedingToResults: Bool = false
    
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentPlayers = gameInstance?.currentPlayers() {
            speaker.text = currentPlayers.0.name
            listener.text = currentPlayers.1.name
        }
        
        inactiveColor = startButtonView.backgroundColor
        
        startButtonView.initializer(inactiveColor, finishColor: UIColor(red: 109.0/256.0, green: 236.0/255.0, blue: 158.0/255.0, alpha: 0.8), requiredTouchDuration: 2.5, delegate: self)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let currentPlayers = gameInstance?.currentPlayers() {
            speaker.text = currentPlayers.0.name
            listener.text = currentPlayers.1.name
        }
        
        
        if gameInstance != nil {
            if (gameInstance!.isNoMoreWords) {
                startLabel.text = NSLocalizedString("FINISH", comment: "Finish")
            }
            let roundNumber = gameInstance!.getCurrentRound().number
            self.navigationItem.title = ""
            if roundNumber != 0 {
                self.navigationItem.setHidesBackButton(true, animated: false)
                let editWordsImage = UIImage(named: "Edit words")
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: editWordsImage, style: .Plain, target: self, action: Selector("editGuessedWords"))
            } else {
                navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!, NSForegroundColorAttributeName : UIColor.redColor()], forState: UIControlState.Normal)
            }
//            setNavigationBarTitleWithCustomFont("№\(roundNumber + 1)")
            var size = UIFont.systemFontOfSize(18).sizeOfString("\(gameInstance!.newWords.count) " + String(NSLocalizedString("WORDS_LEFT", comment: "words left")), constrainedToWidth: 200)
            size.width += 10
            let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
            label.text = "\(gameInstance!.newWords.count) " + String(NSLocalizedString("WORDS_LEFT", comment: "words left"))
            label.textColor = view.tintColor
            label.font = UIFont(name: "Avenir Next", size: 18)
            label.textAlignment = NSTextAlignment.Right
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: Selector("closeButtonPressed")), UIBarButtonItem(customView: label)]

        }
        
        notUndestandingHowToStartCounter = 0
        holdToStartLabel.hidden = true
    }
    
    func closeButtonPressed() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
//        if gameInstance != nil {
//            for player in gameInstance!.players {
//                print("\(player.name) scored \(player.score)")
//            }
//            print("#####################")
//        }
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
        if gameInstance!.isNoMoreWords {
            return
        }
        myUtterance = AVSpeechUtterance(string: NSLocalizedString("TIMER_STRING", comment: "3. 2. 1.   Go!"))
        myUtterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        myUtterance.rate = 0.07
        synth.speakUtterance(myUtterance)
    }
    
    func touchEnded() {
        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        if (gameInstance!.isNoMoreWords) {
            proceedToResults()
            return
        }
        notUndestandingHowToStartCounter += 1
        if notUndestandingHowToStartCounter == 2 {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.holdToStartLabel.hidden = false
            })
        }
    }
    
    func requiredTouchDurationReached() {
        if (gameInstance!.isNoMoreWords) {
            proceedToResults()
            return
        }
        let roundVC = storyboard?.instantiateViewControllerWithIdentifier("RoundViewController") as! RoundViewController
        roundVC.gameInstance = self.gameInstance
        self.presentViewController(roundVC, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Results Segue" {
            if let destinationVC = segue.destinationViewController as? ResultsViewController {
                destinationVC.gameInstance = self.gameInstance
            }
        }
    }

    func proceedToResults() {
        if !isProceedingToResults {
            isProceedingToResults = true
            gameInstance?.reinitialize()
            performSegueWithIdentifier("Results Segue", sender: nil)
        }
    }
}

