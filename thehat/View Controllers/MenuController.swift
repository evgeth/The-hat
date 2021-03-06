//
//  ViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Crashlytics

class MenuController: UIViewController, UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate {

    var gameInstance = GameSingleton.gameInstance
    
    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var holdToStartNewGameLabel: UILabel!
    @IBOutlet weak var rulesLabel: UILabel!
    @IBOutlet weak var newGameView: ColorChangingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.gameInstance.loadWords()
        newGameLabel.layer.cornerRadius = 15
        newGameLabel.layer.masksToBounds = true
        rulesLabel.layer.cornerRadius = 12
        rulesLabel.layer.masksToBounds = true
        initNewGameButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Answers.logCustomEvent(withName: "Open Screen", customAttributes: ["Screen name": "Main Menu"])
        initNewGameButton()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initNewGameButton() {
        if gameInstance.isGameInProgress {
            holdToStartNewGameLabel.isHidden = false
            newGameLabel.text = NSLocalizedString("CONTINUE", comment: "Continue")
            newGameView.initializer(startColor: UIColor(r: 109, g: 236, b: 158, a: 80), finishColor: UIColor(r: 109, g: 250, b: 130, a: 90), requiredTouchDuration: 0.6, delegate: self)
        } else {
            holdToStartNewGameLabel.isHidden = true
            newGameLabel.text = NSLocalizedString("NEW_GAME",comment:"New Game")
            newGameView.initializer(startColor: UIColor(r: 109, g: 236, b: 158, a: 80), finishColor: UIColor(r: 109, g: 236, b: 158, a: 80), requiredTouchDuration: 100, delegate: self)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func touchEnded() {
        if gameInstance.isGameInProgress {
            performSegue(withIdentifier: "Continue Segue", sender: nil)
        } else {
            performSegue(withIdentifier: "New Game Segue", sender: nil)
        }
    }
    
    func requiredTouchDurationReached() {
        if gameInstance.isGameInProgress {
            performSegue(withIdentifier: "New Game Segue", sender: nil)
        }
    }
    
   

}

