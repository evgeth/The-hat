//
//  ResultsViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Crashlytics

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var gameInstance = GameSingleton.gameInstance
    var sortedPlayers = [Player]()
    var sortedPairs = [PlayersPair]()
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: Selector(("doneButtonPressed")))
        setNavigationBarTitleWithCustomFont(title: NSLocalizedString("RESULTS", comment: "Results"))
        
        
        if isPairsMode() {
            for (index, _) in gameInstance.players.enumerated() {
                if index % 2 == 0 {
                    let element = PlayersPair(first: gameInstance.players[index], second: gameInstance.players[index + 1])
                    sortedPairs.append(element)
                }
            }
            sortedPairs.sort(by: { (a, b) -> Bool in
                return a.first.score + a.second.score > b.first.score + b.second.score
            })
        } else {
            sortedPlayers = gameInstance.players
            sortedPlayers.sort { (a: Player, b: Player) -> Bool in
                return a.score > b.score
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Answers.logCustomEvent(withName: "Open Screen", customAttributes: ["Screen name": "Results"])
        for player in sortedPlayers {
            Answers.logCustomEvent(withName: "Player Finished", customAttributes: ["name": player.name.lowercased().capitalized, "score": player.score])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPairsMode() {
            if indexPath.section == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "Header Cell")! as UITableViewCell
            } else {
                let playersPair = sortedPairs[indexPath.section - 1]
                let player = indexPath.row == 0 ? playersPair.first : playersPair.second
                return playerCellForPlayer(tableView: tableView, player: player)
            }
        } else {
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "Header Cell")! as UITableViewCell
            } else {
                let player = sortedPlayers[indexPath.row - 1]
                return playerCellForPlayer(tableView: tableView, player: player)
            }
        }
    }
    
    func playerCellForPlayer(tableView: UITableView, player: Player) -> PlayerResultCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Player Result Cell") as? PlayerResultCell
        cell?.playerNameLabel.text = player.name
        cell?.playerExplainedLabel.text = "\(player.explained)"
        cell?.playerGuessedLabel.text = "\(player.guessed)"
        cell?.playerSumLabel.text = "\(player.score)"
        return cell ?? PlayerResultCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isPairsMode() {
            return gameInstance.players.count / 2 + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPairsMode() {
            return section == 0 ? 1 : 2
        } else {
            return gameInstance.players.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPairsMode() {
            return section == 0 ? 0 : 22
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isPairsMode() {
            return "Pair \(section)"
        } else {
            return ""
        }
    }
    
    @objc func doneButtonPressed() {
        gameInstance.isGameInProgress = false
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func isPairsMode() -> Bool {
        return gameInstance.type == GameType.Pairs
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class PlayersPair {
    var first: Player
    var second: Player
    
    init() {
        self.first = Player(name: "")
        self.second = Player(name: "")
    }

    init(first: Player, second: Player) {
        self.first = first
        self.second = second
    }
    
}

