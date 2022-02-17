//
//  Word.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

enum State: Codable {
    case new, guessed, fail
}

class Word: Codable {
    var word: String = ""
    var state: State = .new
    var complexity = 0
    
    init(word: String) {
        self.word = word
        self.state = State.new
    }
    
    init(word: String, complexity: Int) {
        self.word = word
        self.state = .new
        self.complexity = complexity
    }
    
}
