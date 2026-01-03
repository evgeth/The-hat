//
//  WordsLoader.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation
import SwiftyJSON

final class LocalWordsLoader: WordsLoaderProtocol {
    private var localPool = [Word]()
    
    init() {
        fillPool()
    }

    private func fillPool() {
        let fileName = LS.localizedString(forKey: "WORDS_FILE")
        guard let path = Bundle.main.path(forResource: fileName, ofType: "words") else {
            print("Words file not found: \(fileName).words")
            return
        }
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let json = try JSON(data: jsonData)
            let listOfWordsInJson = json["words"]
            for (_, subJson): (String, JSON) in listOfWordsInJson {
                localPool.append(Word(word: subJson["word"].stringValue, complexity: subJson["complexity"].intValue))
            }
        } catch {
            print("Failed to load words: \(error.localizedDescription)")
        }
    }
    
    func getWords(count numberOfWordsRequired: Int = 5, averageDifficulty: Int = 50) -> [String] {
        var list: [String] = []
        var localPoolWithDifficulty = localPool.filter { abs($0.complexity - averageDifficulty) <= 10 }
        localPoolWithDifficulty.shuffle()

        // Filter out recently used words to avoid repetition across games
        let usedWords = UsedWordsService.shared.getUsedWords()
        let freshWords = localPoolWithDifficulty.filter { !usedWords.contains($0.word) }

        // Use fresh words first, fall back to used words if not enough
        let wordsToUse = freshWords.count >= numberOfWordsRequired ? freshWords : localPoolWithDifficulty

        for word in wordsToUse {
            list.append(word.word)
            if list.count == numberOfWordsRequired {
                break
            }
        }
        return list
    }

}
