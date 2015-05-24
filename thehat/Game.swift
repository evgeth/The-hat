//
//  Game.swift
//  thehat
//
//  Created by Eugene Yurtaev on 24/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

//let loadedWordsNotifictionKey = "com.dpfbop.loadedWordsNotificationKey"

class Game: NSObject {
    
    var roundDuration: Float = 5
    var extraRoundDuration: Float = 3
    
    var players: [Player] = []
    var playingPair: (Int, Int) = (0, 1)
    
    var areWordsLoading = false
    
    var didWordsLoad = false {
        didSet {
            if didWordsLoad == true && didWordsLoad != oldValue {
                println("\(oldValue) -> \(didWordsLoad)")
                NSNotificationCenter.defaultCenter().postNotificationName(loadedWordsNotifictionKey, object: nil)
            }
        }
    }
    var wordsLoader: WordsLoaderDelegate!
    
    var isPoolShouldBeUpdated = true
    var words = [Word]()
    var newWords: Set<Word> = Set<Word>()
    
    var rounds = [Round]()
    var roundNumber: Int = 0
    
    var isNoMoreWords: Bool {
        get {
            if self.newWords.count == 0 {
                return true
            } else {
                return false
            }
        }
    }
    
    func loadWords() {
        if areWordsLoading || didWordsLoad {
            return
        }
        areWordsLoading = true
        if wordsLoader == nil {
            let queue = NSOperationQueue()
            queue.addOperationWithBlock() {
                // do something in the background
                self.wordsLoader = LocalWordsLoader()
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.didWordsLoad = true
                    self.areWordsLoading = false
                }
            }
            
        }
        
    }
    
    func updatePool() {
        if !didWordsLoad {
            loadWords()
            return
        }
        if !isPoolShouldBeUpdated {
            return
        }
        var wordsStrings: [String] = wordsLoader.getWords(players.count * 5)
        var listOfWords: [Word] = []
        for word in wordsStrings {
            newWords.insert(Word(word: word))
            words.append(Word(word: word))
        }
        isPoolShouldBeUpdated = false
    }
    
    func nextRound() {
        playingPair.0 += 1
        playingPair.1 += 1
        playingPair.1 %= players.count
        if playingPair.0 == players.count {
            playingPair.0 = 0
            playingPair.1 += 1
            playingPair.1 %= players.count
        }
        if playingPair.0 == 0 && playingPair.0 == playingPair.1 {
            playingPair.1 += 1
        }
        roundNumber = roundNumber + 1
        rounds.append(Round(number: roundNumber, speaker: players[playingPair.0], listener: players[playingPair.1]))
    }
    
    func getWord() -> String {
        updatePool()
        if newWords.count == 0 {
            return ""
        }
        var index = Int(arc4random() % UInt32(newWords.count))
        var currentIndex = 0
        for element in newWords {
            if currentIndex == index {
                newWords.remove(element)
                return element.word
            }
            currentIndex += 1
        }
        return ""
    }
    
    func initFirstRound() {
        self.rounds = [Round]()
        let players = currentPlayers()
        rounds.append(Round(number: 0, speaker: players.0, listener: players.1))
    }
    
    func currentPlayers() -> (Player, Player) {
        let state = self.playingPair
        return (self.players[state.0], self.players[state.1])
    }
    
    func getCurrentRound() -> Round {
        if self.rounds.count == 0 {
            self.initFirstRound()
        }
        return self.rounds.last!
    }
    
    func setGuessedWordsForRound(guessedWords: [String], roundIndex: Int) {
        self.rounds.last?.guessedWords = guessedWords
        var players = currentPlayers()
        players.0.explained += guessedWords.count
        players.1.guessed += guessedWords.count
    }
    
    func reinitialize() {
//        players = []
        initFirstRound()
        isPoolShouldBeUpdated = true
        updatePool()
        roundNumber = 0
        playingPair = (0, 1)
    }
}