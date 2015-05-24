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
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("doneButtonPressed"))
        setNavigationBarTitleWithCustomFont("Results")
        
        sortedPlayers = gameInstance!.players
        sortedPlayers = sorted(sortedPlayers, { (a: Player, b: Player) -> Bool in
            return a.score > b.score
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("Header Cell") as! UITableViewCell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("Player Result Cell") as! PlayerResultCell
            let player = sortedPlayers[indexPath.row - 1]
            cell.playerNameLabel.text = player.name
            cell.playerExplainedLabel.text = "\(player.explained)"
            cell.playerGuessedLabel.text = "\(player.guessed)"
            cell.playerSumLabel.text = "\(player.score)"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if gameInstance != nil {
            return gameInstance!.players.count + 1
        } else {
            return 1
        }
    }
    
    func doneButtonPressed() {
        self.navigationController?.popToRootViewControllerAnimated(true)
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

