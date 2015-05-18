//
//  Round.swift
//  thehat
//
//  Created by Eugene Yurtaev on 18/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

class Round: NSObject {
    
    var number: Int = 0
    var speaker: String = ""
    var listener: String = ""
    var guessedWords: [String] = []
    
    init(number: Int, speaker: String, listener: String) {
        self.number = number
        self.speaker = speaker
        self.listener = listener
    }
}