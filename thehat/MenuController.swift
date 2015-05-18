//
//  ViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class MenuController: UIViewController, UIPopoverPresentationControllerDelegate, GameDelegate {

    var gameInstance: Game!
    
    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var rulesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameInstance = Game()
        newGameLabel.layer.cornerRadius = 15
        newGameLabel.layer.masksToBounds = true
        rulesLabel.layer.cornerRadius = 12
        rulesLabel.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Rules Segue" {
            if let destinationViewController = segue.destinationViewController as? UIViewController {
                destinationViewController.popoverPresentationController!.backgroundColor = UIColor.whiteColor()
                destinationViewController.popoverPresentationController!.delegate = self
            }
        } else if segue.identifier == "New Game" {
            if let destinationVC = segue.destinationViewController as? GameSettingsViewController {
                destinationVC.delegate = self
            }
        }
    }
    
    // Game Delegate implementation
    
    
    func setPlayers(players: [String]) {
        gameInstance.players = players
    }
    
    func nextRound() {
        gameInstance.nextRound()
    }
    
    func state() -> (Int, Int) {
        return gameInstance.state
    }
    
    func currentPlayers() -> (String, String) {
        let state = gameInstance.state
        return (gameInstance.players[state.0], gameInstance.players[state.1])
    }
    
    func getWord() -> String {
        return gameInstance.getWord()
    }
    
    func game() -> Game {
        return gameInstance
    }
    
    func getRoundNumber() -> Int {
        return gameInstance.roundNumber
    }
    
    func setGuessedWordsInRound(guessedWords: [String]) {
        gameInstance.rounds.last?.guessedWords = guessedWords
        println(guessedWords)
    }

}

