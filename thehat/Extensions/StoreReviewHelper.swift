//
//  StoreReviewHelper.swift
//  thehat
//
//  Created by Evgeny Yurtaev on 11/26/19.
//  Copyright © 2019 dpfbop. All rights reserved.
//
import Foundation
import StoreKit

struct UserDefaultsKeys {
    static let GAME_FINISHED_COUNT = "GAME_FINISHED_COUNT"
    static let SAVED_PLAYER_NAMES = "SAVED_PLAYER_NAMES"
}

struct StoreReviewHelper {
    static func incrementGameFinishedCount() {
        guard var gameFinishedCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.GAME_FINISHED_COUNT) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.GAME_FINISHED_COUNT)
            return
        }
        gameFinishedCount += 1
        UserDefaults.standard.set(gameFinishedCount, forKey: UserDefaultsKeys.GAME_FINISHED_COUNT)
    }
    static func checkAndAskForReview() {
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let gameFinishedCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.GAME_FINISHED_COUNT) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.GAME_FINISHED_COUNT)
            return
        }

        switch gameFinishedCount {
        case 1,3,7:
            StoreReviewHelper().requestReview()
        case _ where gameFinishedCount % 10 == 0 :
            StoreReviewHelper().requestReview()
        default:
            print("Game finished count : \(gameFinishedCount)")
            break;
        }
        
    }
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
        }
    }
}
