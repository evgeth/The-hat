//
//  WordsLoader.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation

class LocalWordsLoader: WordsLoaderDelegate {
    var localPool = [String]()
    
    init() {
//        super.init()
        println("loading")
        let path = NSBundle.mainBundle().pathForResource("russian", ofType: "words")
//        let jsonData = NSData.dataWithContentsOfFile(path!, options: .DataReadingMappedIfSafe, error: nil)
        let jsonData = NSData.dataWithContentsOfMappedFile(path!) as! NSData
//        println(NSString(data: jsonData, encoding: NSUTF8StringEncoding))
        let json = JSON(data: jsonData)
        let listOfWordsInJson = json["words"]
//        println(listOfWordsInJson.arrayValue)
        for (index: String, subJson: JSON) in listOfWordsInJson {
            localPool.append(subJson["word"].stringValue)
        }
    }
    
    func getWords(_ numberOfWordsRequired: Int = 5) -> [String] {
        var list: [String] = []
        var cnt = UInt32(localPool.count)
        while list.count < numberOfWordsRequired {
            var randomIndex = arc4random() % cnt
            let newWord = localPool[Int(randomIndex)]
            if list.filter({ (word: String) -> Bool in
                if word == newWord {
                    return true
                }
                return false
            }).count == 0 {
                list.append(newWord)
            }
            
        }
        return list
    }
    
    
}