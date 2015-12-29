//
//  ViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class MenuController: UIViewController, UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate {

    var gameInstance: Game!
    
    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var holdToStartNewGameLabel: UILabel!
    @IBOutlet weak var rulesLabel: UILabel!
    @IBOutlet weak var newGameView: ColorChangingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameInstance = Game()
        
        self.gameInstance.loadWords()
        newGameLabel.layer.cornerRadius = 15
        newGameLabel.layer.masksToBounds = true
        rulesLabel.layer.cornerRadius = 12
        rulesLabel.layer.masksToBounds = true
        initNewGameButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        initNewGameButton()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initNewGameButton() {
        if gameInstance.isGameInProgress {
            holdToStartNewGameLabel.hidden = false
            newGameLabel.text = NSLocalizedString("CONTINUE", comment: "Continue")
            newGameView.initializer(UIColor(r: 109, g: 236, b: 158, a: 80), finishColor: UIColor(r: 109, g: 250, b: 130, a: 90), requiredTouchDuration: 0.6, delegate: self)
        } else {
            holdToStartNewGameLabel.hidden = true
            newGameLabel.text = NSLocalizedString("NEW_GAME",comment:"New Game")
            newGameView.initializer(UIColor(r: 109, g: 236, b: 158, a: 80), finishColor: UIColor(r: 109, g: 236, b: 158, a: 80), requiredTouchDuration: 100, delegate: self)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Rules Segue" {
            if let destinationViewController = segue.destinationViewController as? UIViewController {
//                destinationViewController.popoverPresentationController!.backgroundColor = UIColor.whiteColor()
//                destinationViewController.popoverPresentationController!.delegate = self
            }
        } else if segue.identifier == "New Game Segue" {
            if let destinationVC = segue.destinationViewController as? GameSettingsViewController {
                destinationVC.gameInstance = self.gameInstance
            }
        } else if segue.identifier == "Continue Segue" {
            if let destinationVC = segue.destinationViewController as? PreparationViewController {
                destinationVC.gameInstance = self.gameInstance
            }
        }
    }
    
    func touchEnded() {
        if gameInstance.isGameInProgress {
            performSegueWithIdentifier("Continue Segue", sender: nil)
        } else {
            performSegueWithIdentifier("New Game Segue", sender: nil)
        }
    }
    
    func requiredTouchDurationReached() {
        if gameInstance.isGameInProgress {
            performSegueWithIdentifier("New Game Segue", sender: nil)
        }
    }
    
   

}

