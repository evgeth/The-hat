//
//  WordsLoader.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

class LocalWordsLoader: WordsLoaderDelegate {
    var localPool = [Word]()
    
    init() {
        let path = NSBundle.mainBundle().pathForResource(NSLocalizedString("WORDS_FILE", comment: "Words file"), ofType: "words")
        let jsonData = NSData.dataWithContentsOfMappedFile(path!) as! NSData
        let json = JSON(data: jsonData)
        let listOfWordsInJson = json["words"]
        for (_, subJson): (String, JSON) in listOfWordsInJson {
            localPool.append(Word(word: subJson["word"].stringValue, complexity: subJson["complexity"].intValue))
        }
    }
    
    func getWords(numberOfWordsRequired: Int = 5, averageDifficulty: Int = 50) -> [String] {
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