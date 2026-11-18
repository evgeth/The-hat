//
//  thehatTests.swift
//  thehatTests
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import XCTest
@testable import thehat

final class TurnRotationTests: XCTestCase {
    func testPairsKeepPartnersAndGiveEachPlayerBothRoles() {
        for playerCount in stride(from: 2, through: 12, by: 2) {
            let game = Game()
            game.type = .Pairs
            game.players = (0..<playerCount).map { Player(name: String($0)) }
            game.initFirstRound()
            for turn in 0..<(2 * playerCount) {
                let first = (turn % (playerCount / 2)) * 2
                let swapsRoles = (turn / (playerCount / 2)) % 2 == 1
                let round = game.getCurrentRound()
                XCTAssertEqual(round.speaker.name, String(swapsRoles ? first + 1 : first))
                XCTAssertEqual(round.listener.name, String(swapsRoles ? first : first + 1))
                game.nextRound()
                XCTAssertTrue(game.getPreviousRound() === round)
            }
        }
    }

    func testSinglesCoverEverySpeakerListenerCombination() {
        for count in 2...9 {
            let game = Game()
            game.players = (0..<count).map { Player(name: String($0)) }
            game.initFirstRound()
            var combinations = Set<[String]>()
            for _ in 0..<(count * (count - 1)) {
                let round = game.getCurrentRound()
                XCTAssertNotEqual(round.speaker.name, round.listener.name)
                XCTAssertTrue(combinations.insert([round.speaker.name, round.listener.name]).inserted)
                game.nextRound()
            }
            XCTAssertEqual(game.playingPair.0, 0)
            XCTAssertEqual(game.playingPair.1, 1)
        }
    }

    func testStartingWithFewerPlayersResetsRoundParticipants() {
        let game = Game()
        game.type = .Pairs
        game.players = ["A", "B", "C", "D"].map { Player(name: $0) }
        game.initFirstRound()
        game.nextRound()
        XCTAssertEqual(game.currentPlayers().0.name, "C")
        game.players = ["X", "Y"].map { Player(name: $0) }
        game.didWordsLoad = true
        game.reinitialize(isPoolShouldBeUpdated: false)
        let round = game.getCurrentRound()
        XCTAssertEqual(round.speaker.name, "X")
        XCTAssertEqual(round.listener.name, "Y")
        XCTAssertEqual(game.rounds.count, 1)
        XCTAssertNil(game.getPreviousRound())
    }
}
