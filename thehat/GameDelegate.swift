//
//  GameDelegate.swift
//  thehat
//
//  Created by Eugene Yurtaev on 24/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

protocol GameDelegate {
    
    func nextRound()
    func game() -> Game
    func state() -> (Int, Int)
    func currentPlayers() -> (String, String)
    func setPlayers([String])
    func getWord() -> String
    func getRoundNumber() -> Int
    func setGuessedWordsInRound([String])
    
}