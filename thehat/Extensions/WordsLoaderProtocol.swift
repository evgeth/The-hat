//
//  WordsLoaderDelegate.swift
//  thehat
//
//  Created by Eugene Yurtaev on 24/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

protocol WordsLoaderProtocol {
    
//    func nextRound()
//    func game() -> Game
//    func state() -> (Int, Int)
//    func currentPlayers() -> (Player, Player)
//    func setPlayers([Player])
//    func getWord() -> String
//    func getCurrentRound() -> Round?
//    func setGuessedWordsInRound([String])
    
    func getWords(count: Int, averageDifficulty: Int) -> [String]
    
}
