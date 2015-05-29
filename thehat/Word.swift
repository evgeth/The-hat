//
//  Word.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

enum State {
    case New, Guessed, Fail
}


class Word: NSObject {
    var word: String = ""
    var state: State = .New
    var complexity = 0
    
    init(word: String) {
        self.word = word
        self.state = State.New
    }
    
    init(word: String, complexity: Int) {
        self.word = word
        self.state = State.New
        self.complexity = complexity
    }
}