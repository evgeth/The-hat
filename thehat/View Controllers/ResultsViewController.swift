//
//  ResultsViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 23/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var gameInstance: Game?
    var sortedPlayers = [Player]()
    var sortedPairs = [PlayersPair]()
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("doneButtonPressed"))
        setNavigationBarTitleWithCustomFont(NSLocalizedString("RESULTS", comment: "Results"))
        
        
        if isPairsMode() {
            for (index, _) in (gameInstance?.players ?? []).enumerate() {
                if index % 2 == 0 {
                    let element = PlayersPair(first: gameInstance!.players[index], second: gameInstance!.players[index + 1])
                    sortedPairs.append(element)
                }
            }
            sortedPairs = sortedPairs.sort({ (a: PlayersPair , b: PlayersPair) -> Bool in
                return a.first.score + a.second.score > b.first.score + b.second.score
            })
        } else {
            sortedPlayers = gameInstance?.players ?? []
            sortedPlayers = sortedPlayers.sort({ (a: Player, b: Player) -> Bool in
                return a.score > b.score
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewWillDisappear(animated: Bool) {

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isPairsMode() {
            if indexPath.section == 0 {
                return tableView.dequeueReusableCellWithIdentifier("Header Cell")! as UITableViewCell
            } else {
                let playersPair = sortedPairs[indexPath.section - 1]
                let player = indexPath.row == 0 ? playersPair.first : playersPair.second
                return playerCellForPlayer(tableView, player: player)
            }
        } else {
            if indexPath.row == 0 {
                return tableView.dequeueReusableCellWithIdentifier("Header Cell")! as UITableViewCell
            } else {
                let player = sortedPlayers[indexPath.row - 1]
                return playerCellForPlayer(tableView, player: player)
            }
        }
    }
    
    func playerCellForPlayer(tableView: UITableView, player: Player) -> PlayerResultCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Player Result Cell") as? PlayerResultCell
        cell?.playerNameLabel.text = player.name
        cell?.playerExplainedLabel.text = "\(player.explained)"
        cell?.playerGuessedLabel.text = "\(player.guessed)"
        cell?.playerSumLabel.text = "\(player.score)"
        return cell ?? PlayerResultCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isPairsMode() {
            return (gameInstance?.players.count ?? 0) / 2 + 1
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPairsMode() {
            return section == 0 ? 1 : 2
        } else {
            return (gameInstance?.players.count ?? 0) + 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPairsMode() {
            return section == 0 ? 0 : 22
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isPairsMode() {
            return "Pair \(section)"
        } else {
            return ""
        }
    }
    
    func doneButtonPressed() {
        gameInstance?.isGameInProgress = false
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func isPairsMode() -> Bool {
        return gameInstance?.type == GameType.Pairs
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

class PlayersPair: NSObject {
    var first: Player
    var second: Player
    
    override init() {
        self.first = Player(name: "")
        self.second = Player(name: "")
    }

    init(first: Player, second: Player) {
        self.first = first
        self.second = second
    }
    
}

