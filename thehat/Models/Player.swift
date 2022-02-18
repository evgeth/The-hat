//
//  Player.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

final class Player: Codable {
    var name: String = ""
    var explained: Int = 0
    var guessed: Int = 0
    var score: Int {
        return explained + guessed
    }
    
    init(name: String) {
        self.name = name
    }
    
}
