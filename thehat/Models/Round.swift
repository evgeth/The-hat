//
//  Round.swift
//  thehat
//
//  Created by Eugene Yurtaev on 18/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

class Round {
    
    var number: Int = 0
    var speaker: Player
    var listener: Player
    var guessedWords = [Word]()
    
    init(number: Int, speaker: Player, listener: Player) {
        self.number = number
        self.speaker = speaker
        self.listener = listener
    }
}
