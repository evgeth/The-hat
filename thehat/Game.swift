//
//  Game.swift
//  thehat
//
//  Created by Eugene Yurtaev on 24/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

class Game: NSObject {
    
    var roundDuration: Float = 5
    var extraRoundDuration: Float = 3
    
    var players: [String] = []
    var state: (Int, Int) = (0, 1)
    var roundNumber: Int = 0
    var listOfWords = ["мама", "абстракционизм", "любовь", "сияние", "анархия", "шляпа", "вычисление"]
    
    var rounds: [Round] = []
    
    
    func nextRound() {
        state.0 += 1
        state.1 += 1
        state.1 %= players.count
        if state.0 == players.count {
            state.0 = 0
            state.1 += 1
            state.1 %= players.count
        }
        if state.0 == 0 && state.0 == state.1 {
            state.1 += 1
        }
        roundNumber = roundNumber + 1
        rounds.append(Round(number: roundNumber, speaker: players[state.0], listener: players[state.1]))
    }
    
    func getWord() -> String {
        return listOfWords[Int(arc4random()) % listOfWords.count]
    }
}