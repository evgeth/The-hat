//
//  GameSettingsViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

let loadedWordsNotifictionKey = "com.dpfbop.loadedWordsNotificationKey"

class GameSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var roundTimeLabel: UILabel!
    @IBOutlet weak var playersTableView: UITableView!
    var isReadyToDeleteRow: Bool = false
    var readyToDeleteRow: Int = 0
    var players: [String] = ["", "", "", ""]
    var gameInstance: Game?
    
    @IBOutlet weak var stepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playersTableView.dataSource = self
        playersTableView.delegate = self
        
        playersTableView.setEditing(true, animated: true)
        roundTimeLabel.text = "\(Int(stepper.value))"
        
        if gameInstance != nil {
            if gameInstance!.players.count != 0 {
                var playersList = [String]()
                for player in gameInstance!.players {
                    playersList.append(player.name)
                }
                players = playersList
            }
            
        }
        
        setNavigationBarTitleWithCustomFont("Game Settings")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count + 1
    }
    
    @IBAction func roundTimeChanged(sender: UIStepper) {
        roundTimeLabel.text = "\(Int(sender.value))"
    }
    
    
    
    @IBAction func cellLeftSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Ended) {
            let swipeLocation = sender.locationInView(playersTableView)
            let swipedIndexPath = playersTableView.indexPathForRowAtPoint(swipeLocation)
            if swipedIndexPath == nil || swipedIndexPath?.row == players.count || isReadyToDeleteRow {
                return
            }
            var swipedCell = playersTableView.cellForRowAtIndexPath(swipedIndexPath!)! as UITableViewCell
            
            
            isReadyToDeleteRow = true
            readyToDeleteRow = swipedIndexPath!.row
            playersTableView.reloadRowsAtIndexPaths([swipedIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func hideDeleteButton() {
        if isReadyToDeleteRow {
            isReadyToDeleteRow = false
            
            playersTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: readyToDeleteRow, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    @IBAction func playerNameModified(sender: UITextField, forEvent event: UIEvent) {
        if let cell = sender.superview?.superview as? UITableViewCell {
            let indexPath = playersTableView.indexPathForCell(cell)
            if indexPath != nil {
                players[indexPath!.row] = sender.text
            }
        }
    }
    
    @IBAction func addPlayerButtonPressed(sender: UIButton) {
        players.append("")
        playersTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: players.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        playersTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: players.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    @IBAction func tapOnPlayersTable(sender: UITapGestureRecognizer) {
        hideDeleteButton()
    }
    
    @IBAction func hideButtonPressed(sender: UIButton) {
        sender.enabled = false
        hideDeleteButton()
    }
    
    @IBAction func deleteButtonPressed(sender: UIButton) {
        if let cell = sender.superview?.superview as? UITableViewCell {
            let indexPath = playersTableView.indexPathForCell(cell)
            hideDeleteButton()
            players.removeAtIndex(indexPath!.row)
            playersTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    @IBAction func textFieldEditBegin(sender: UITextField) {
        hideDeleteButton()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == players.count {
            var cell = tableView.dequeueReusableCellWithIdentifier("Add Player") as! UITableViewCell
            return cell
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("Player") as! UITableViewCell
        cell.showsReorderControl = true
        if let textField = cell.viewWithTag(1) as? UITextField {
            textField.text = players[indexPath.row]
        }
        var deleteButton = cell.viewWithTag(2)! as! UIButton
        var hideButton = cell.viewWithTag(3)! as! UIButton
        deleteButton.alpha = 0
        hideButton.enabled = false
        if isReadyToDeleteRow && readyToDeleteRow == indexPath.row {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                deleteButton.alpha = 1
            })
            hideButton.enabled = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isReadyToDeleteRow && readyToDeleteRow == indexPath.row {
            return false
        }
        if indexPath.row != players.count {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        hideDeleteButton()
        if proposedDestinationIndexPath.row == players.count {
            return NSIndexPath(forRow: players.count - 1, inSection: sourceIndexPath.section)
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if isReadyToDeleteRow && sourceIndexPath.row == readyToDeleteRow {
            readyToDeleteRow = destinationIndexPath.row
        }
        let previousString = players[sourceIndexPath.row]
        players.removeAtIndex(sourceIndexPath.row)
        players.insert(previousString, atIndex: destinationIndexPath.row)
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Insert {
            var cell = playersTableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            if let textField = cell.viewWithTag(1) as? UITextField {
                players.append(textField.text)
            }
        } else if editingStyle == UITableViewCellEditingStyle.Delete {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Start Round" {
            if let destinationVC = segue.destinationViewController as? PreparationViewController {
                destinationVC.gameInstance = self.gameInstance
                var playersList: [Player] = []
                for playerName in players {
                    playersList.append(Player(name: playerName))
                }
                gameInstance?.players = playersList
                gameInstance?.roundDuration = Float(Int(stepper.value))
                gameInstance?.rounds = []
                gameInstance?.initFirstRound()
                gameInstance?.updatePool()
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        println("should")
        if identifier == "Start Round" {
            println("should perform segue for round")
            if gameInstance!.didWordsLoad == false {
                println("didWordsLoad = false")
                var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("wordsLoadedNotificationArrived:"), name: loadedWordsNotifictionKey, object: nil)
                activityIndicator.center = view.center
                activityIndicator.hidden = false
                activityIndicator.startAnimating()
//                self.view.addSubview(activityIndicator)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    func wordsLoadedNotificationArrived(notification: NSNotification) {
        println("notification arrived")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("startRound"))
        startRound()
    }
    
    func startRound() {
        println("up to make segue")
        self.performSegueWithIdentifier("Start Round", sender: nil)
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

