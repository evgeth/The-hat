//
//  WordsLoader.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation
import SwiftyJSON

class LocalWordsLoader: WordsLoaderDelegate {
    var localPool = [Word]()
    
    init() {
        let path = Bundle.main.path(forResource: LanguageChanger.shared.localizedString(forKey: "WORDS_FILE"), ofType: "words")
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
            let json = try JSON(data: jsonData)
            let listOfWordsInJson = json["words"]
            for (_, subJson): (String, JSON) in listOfWordsInJson {
                localPool.append(Word(word: subJson["word"].stringValue, complexity: subJson["complexity"].intValue))
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getWords(count numberOfWordsRequired: Int = 5, averageDifficulty: Int = 50) -> [String] {
        var list: [String] = []
        var localPoolWithDifficulty = localPool.filter { (word: Word) -> Bool in
            if abs(word.complexity - averageDifficulty) <= 10 {
                return true
            } else {
                return false
            }
        }
        localPoolWithDifficulty.shuffle()
        
        for word in localPoolWithDifficulty {
            list.append(word.word)
            if list.count == numberOfWordsRequired {
                break
            }
        }
        return list
    }
    
    
}
