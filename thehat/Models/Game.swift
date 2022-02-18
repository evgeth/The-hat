//
//  Game.swift
//  thehat
//
//  Created by Eugene Yurtaev on 24/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

//let loadedWordsNotifictionKey = "com.dpfbop.loadedWordsNotificationKey"

enum GameType: Codable {
    case EachToEach, Pairs

    var title: String {
        switch self {
        case .EachToEach:
            return LS.localizedString(forKey: "each_to_each")
        case .Pairs:
            return LS.localizedString(forKey: "pairs")
        }
    }
}

class Game {
    
    var isGameInProgress = false
    
    var roundDuration: Float = 20
    var difficulty: Int = 50
    var extraRoundDuration: Float = 3
    var type = GameType.EachToEach
    var wordsInTheHat = 60
    
    var players: [Player] = []
    var previousPair: (Int, Int) = (0, 0)
    var playingPair: (Int, Int) = (0, 1)
    
    
    var isPoolShouldBeUpdated = true
    var words = [Word]()
    var newWords = Set<String>()
    
    var rounds = [Round]()
    var roundNumber: Int = 0
    
    var areWordsLoading = false
    var didWordsLoad = false {
        didSet {
            if didWordsLoad == true && didWordsLoad != oldValue {
                NotificationCenter.default.post(name: Notification.Name(rawValue: loadedWordsNotifictionKey), object: nil)
            }
        }
    }
    var wordsLoader: WordsLoaderProtocol!
    
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
            let queue = OperationQueue()
            queue.addOperation() {
                // do something in the background
                self.wordsLoader = LocalWordsLoader()
                OperationQueue.main.addOperation() {
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
        let wordsStrings: [String] = wordsLoader.getWords(count: wordsInTheHat, averageDifficulty: difficulty)
        newWords.removeAll(keepingCapacity: true)
        for word in wordsStrings {
            newWords.insert(word)
            words.append(Word(word: word))
        }
        isPoolShouldBeUpdated = false
    }
    
    func nextRound() {
        previousPair = playingPair
        roundNumber = roundNumber + 1
        if type == GameType.EachToEach {
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
            
        } else {
            let numberOfPairs = Int(players.count / 2)
            playingPair.0 = (roundNumber % numberOfPairs) * 2
            playingPair.1 = (roundNumber % numberOfPairs) * 2 + 1
            if (roundNumber / numberOfPairs) % 2 == 1 {
                playingPair = (playingPair.1, playingPair.0)
            }
        }
        rounds.append(Round(number: roundNumber, speaker: players[playingPair.0], listener: players[playingPair.1]))
    }

    func changeLanguage() {
        words = []
        didWordsLoad = false
        wordsLoader = nil
    }
    
    func getWord() -> String {
        updatePool()
        if newWords.count == 0 {
            return ""
        }
        let index = Int(arc4random() % UInt32(newWords.count))
        var currentIndex = 0
        for element in newWords {
            if currentIndex == index {
                newWords.remove(element)
                return element
            }
            currentIndex += 1
        }
        return ""
    }
    
    func initFirstRound() {
        if !isGameInProgress {
            self.rounds = [Round]()
            let curPlayers = currentPlayers()
            rounds.append(Round(number: 0, speaker: curPlayers.0, listener: curPlayers.1))
            isGameInProgress = true
        }
    }
    
    func currentPlayers() -> (Player, Player) {
        let state = self.playingPair
        return (self.players[state.0], self.players[state.1])
    }
    
    func previousPlayers() -> (Player, Player) {
        let state = self.previousPair
        return (self.players[state.0], self.players[state.1])
    }
    
    func getCurrentRound() -> Round {
        if self.rounds.count == 0 {
            self.initFirstRound()
        }
        return self.rounds.last!
    }
    
    func getPreviousRound() -> Round? {
        let roundIndex = self.rounds.count - 2
        if roundIndex < 0 {
            return nil
        }
        return self.rounds[roundIndex]
    }
    
    func setGuessedWordsForRound(guessedWords: [Word]) {
        guard let round = getPreviousRound() else {
            return
        }
        let players = previousPlayers()
        if round.guessedWords.count == guessedWords.count {
            for word in round.guessedWords {
                if word.state == State.guessed {
                    players.0.explained -= 1
                    players.1.guessed -= 1
                } else if word.state == State.new {
                    newWords.remove(word.word)
                }
            }
        }
        for word in guessedWords {
            if word.state == State.guessed {
                players.0.explained += 1
                players.1.guessed += 1
            } else if word.state == State.new {
                newWords.insert(word.word)
            }
        }
        round.guessedWords = guessedWords
    }
    
    func reinitialize() {
        isGameInProgress = false
        initFirstRound()
        isPoolShouldBeUpdated = true
        updatePool()
        roundNumber = 0
        previousPair = (0, 0)
        playingPair = (0, 1)
    }
}
class GameSingleton {
    static let gameInstance = Game()
}
