//
//  GameSettingsViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

let loadedWordsNotifictionKey = "com.dpfbop.loadedWordsNotificationKey"

class GameSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, PlayerTableViewCellDelegate {
    
    @IBOutlet weak var playersTableView: UITableView!
    var isReadyToDeleteRow: Bool = false
    var readyToDeleteIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var players: [String] = ["", "", "", ""]
    var sectionsCount = 2
    var isAddingSection = false
    var numberOfRowsInLastSection = 3
    var gameInstance: Game?
    
    @IBOutlet weak var difficultyPicker: UIPickerView!
    @IBOutlet weak var wordsPerPlayerStepper: UIStepper!
    @IBOutlet weak var wordsPerPlayerLabel: UILabel!
    
    @IBOutlet weak var roundLengthStepper: UIStepper!
    @IBOutlet weak var roundLengthLabel: UILabel!
    
    @IBOutlet weak var gameTypeSegmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playersTableView.dataSource = self
        playersTableView.delegate = self
        
        difficultyPicker.delegate = self
        difficultyPicker.dataSource = self
        
        setNavigationBarTitleWithCustomFont(NSLocalizedString("GAME_SETTINGS", comment: "Game Settings"))
        
        playersTableView.setEditing(true, animated: true)
        roundLengthLabel.text = "\(Int(roundLengthStepper.value))"
        difficultyPicker.selectRow(2, inComponent: 0, animated: false)
        
        
        if gameInstance != nil {
            if gameInstance!.players.count != 0 {
                var playersList = [String]()
                for player in gameInstance!.players {
                    playersList.append(player.name)
                }
                players = playersList
            }
            roundLengthStepper.value = Double(gameInstance!.roundDuration)
            wordsPerPlayerStepper.value = Double(gameInstance!.wordsPerPlayer)
            reloadLabels()
            gameTypeSegmentControl.selectedSegmentIndex =
                (gameInstance!.type == GameType.Pairs) ? 1:0
            difficultyPicker.selectRow((gameInstance!.difficulty - 10) / 20, inComponent: 0, animated: false)
            sectionsCount = (players.count + 1) / 2
            numberOfRowsInLastSection = players.count % 2 == 0 ? 3 : 2
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var difficulties = ["Very Easy", "Easy", "Normal", "Hard", "Very Hard"]
        return difficulties[row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func wordsPerPlayerValueChanged(sender: UIStepper) {
        reloadLabels()
    }
    
    @IBAction func roundLengthChanged(sender: UIStepper) {
        reloadLabels()
    }
    
    @IBAction func gameTypeChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            playersTableView.reloadData()
        } else {
            if players.count % 2 == 0 {
                sectionsCount = players.count / 2
                numberOfRowsInLastSection = 3
            } else {
                sectionsCount = (players.count / 2) + 1
                numberOfRowsInLastSection = 2
            }
//            if players.count % 2 == 1 {
//                addPlayerButtonPressed(nil)
//            }
            playersTableView.reloadData()
        }
    }
    
    func reloadLabels() {
        wordsPerPlayerLabel.text = "\(Int(wordsPerPlayerStepper.value))"
        roundLengthLabel.text = "\(Int(roundLengthStepper.value))"
    }
    
    @IBAction func cellLeftSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Ended) {
            let swipeLocation = sender.locationInView(playersTableView)
            let swipedIndexPath = playersTableView.indexPathForRowAtPoint(swipeLocation)
            
            if swipedIndexPath == nil || countRowNumberForIndexPath(swipedIndexPath!) == players.count || isReadyToDeleteRow {
                return
            }
            if isPairsMode() && swipedIndexPath!.section != playersTableView.numberOfSections - 1 {
                return
            }
            var swipedCell = playersTableView.cellForRowAtIndexPath(swipedIndexPath!)! as UITableViewCell
            
            
            isReadyToDeleteRow = true
            readyToDeleteIndexPath = swipedIndexPath!
            playersTableView.reloadRowsAtIndexPaths([swipedIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func hideDeleteButton() {
        if isReadyToDeleteRow {
            isReadyToDeleteRow = false
            
            playersTableView.reloadRowsAtIndexPaths([readyToDeleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    @IBAction func textFieldEditBegin(sender: UITextField) {
        if let cell = sender.superview?.superview as? PlayerTableViewCell {
            let indexPath = playersTableView.indexPathForCell(cell)
            if indexPath != nil {
                if countRowNumberForIndexPath(indexPath!) < players.count - 1 {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.Next
                } else {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.Done
                }
            }
        }
        hideDeleteButton()
    }
    
    @IBAction func playerNameModified(sender: UITextField, forEvent event: UIEvent) {
        if let cell = sender.superview?.superview as? PlayerTableViewCell {
            let indexPath = playersTableView.indexPathForCell(cell)
            if indexPath != nil {
                players[countRowNumberForIndexPath(indexPath!)] = sender.text!
                if countRowNumberForIndexPath(indexPath!) < players.count - 1 {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.Next
                } else {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.Done
                }
            }
        }
    }
    
    @IBAction func addPlayerButtonPressed(sender: UIButton?) {
        if isPairsMode() {
            if players.count % 2 == 0 {
                numberOfRowsInLastSection = 2
                playersTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: playersTableView.numberOfSections - 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
                sectionsCount += 1
                players.append("")
                playersTableView.insertSections(NSIndexSet(index: playersTableView.numberOfSections), withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                players.append("")
                numberOfRowsInLastSection = 3
                playersTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: playersTableView.numberOfSections - 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        } else {
            players.append("")
            playersTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: players.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            playersTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: players.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    @IBAction func tapOnPlayersTable(sender: UITapGestureRecognizer) {
        view.endEditing(true)
        hideDeleteButton()
    }
    
    @IBAction func hideButtonPressed(sender: UIButton) {
        sender.enabled = false
        hideDeleteButton()
    }
    
    @IBAction func deleteButtonPressed(indexPath: NSIndexPath) {
        if let cell = playersTableView.cellForRowAtIndexPath(indexPath) {
            let indexPath = playersTableView.indexPathForCell(cell)
            hideDeleteButton()
            if players.count > 2 {
                if isPairsMode() {
                    if indexPath?.section == playersTableView.numberOfSections - 1 {
                        players.removeAtIndex(countRowNumberForIndexPath(indexPath!))
                        if players.count % 2 == 1 {
                            numberOfRowsInLastSection = 2
                            playersTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                        } else {
                            numberOfRowsInLastSection = 1
                            playersTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                            sectionsCount -= 1
                            numberOfRowsInLastSection = 2
                            playersTableView.deleteSections(NSIndexSet(index: playersTableView.numberOfSections - 1), withRowAnimation: UITableViewRowAnimation.Fade)
                            numberOfRowsInLastSection = 3
                            playersTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: playersTableView.numberOfSections - 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
                            
                        }
                    }
                } else {
                    players.removeAtIndex(indexPath!.row)
                    playersTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            } else {
                let alertView = UIAlertView(title: "Error", message: "You need at least 2 players for game", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let centerOfView = textField.superview?.superview?.center
        if (centerOfView == nil) {
            return false
        }
        let indexPathForTextField = playersTableView.indexPathForRowAtPoint(centerOfView!)!
        let cell = playersTableView.cellForRowAtIndexPath(indexPathForTextField) as! PlayerTableViewCell
        let indexPathToMoveFocus = nextIndexPath(playersTableView, indexPath: indexPathForTextField)
        if indexPathToMoveFocus != nil && countRowNumberForIndexPath(indexPathToMoveFocus!) != players.count {
            let nextCell = playersTableView.cellForRowAtIndexPath(indexPathToMoveFocus!) as! PlayerTableViewCell
            if let textField = nextCell.playerLabel {
                let responder: UIResponder = textField
                responder.becomeFirstResponder()
            }
        } else {
            if let textField = cell.playerLabel {
                let responder: UIResponder = textField
                responder.resignFirstResponder()
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if countRowNumberForIndexPath(indexPath) == players.count {
            var cell = tableView.dequeueReusableCellWithIdentifier("Add Player")! as UITableViewCell
            cell.showsReorderControl = false
            return cell
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("Player") as! PlayerTableViewCell
        cell.showsReorderControl = true
        if let textField = cell.playerLabel {
            textField.text = players[countRowNumberForIndexPath(indexPath)]
            textField.delegate = self
            if countRowNumberForIndexPath(indexPath) < players.count - 1 {
                textField.returnKeyType = UIReturnKeyType.Next
            } else {
                textField.returnKeyType = UIReturnKeyType.Done
            }
        }
        var deleteButton = cell.deleteButton
        var hideButton = cell.hideButton
        cell.delegate = self
        deleteButton.alpha = 0
        hideButton.enabled = false
        if isReadyToDeleteRow && readyToDeleteIndexPath == indexPath {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                deleteButton.alpha = 1
            })
            hideButton.enabled = true
        }
        
        
        return cell
    }
    
    func indexPathForCell(cell: UITableViewCell) -> NSIndexPath {
        return playersTableView.indexPathForCell(cell)!
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isPairsMode() {
            return sectionsCount
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPairsMode() {
            if section == numberOfSectionsInTableView(tableView) - 1 {
                return numberOfRowsInLastSection
            }
            return 2
        } else {
            return players.count + 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPairsMode() {
            return 22
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isPairsMode() {
            return "Pair \(section + 1)"
        } else {
            return ""
        }
    }
    
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if !isPairsMode() {
            if isReadyToDeleteRow && readyToDeleteIndexPath == indexPath.row {
                return false
            }
            if indexPath.row != players.count {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        hideDeleteButton()
        if isPairsMode() {
            return proposedDestinationIndexPath
        } else {
            if proposedDestinationIndexPath.row == players.count {
                return NSIndexPath(forRow: players.count - 1, inSection: sourceIndexPath.section)
            } else {
                return proposedDestinationIndexPath
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if isPairsMode() {
            return
        }
        if isReadyToDeleteRow && sourceIndexPath.row == readyToDeleteIndexPath {
            readyToDeleteIndexPath = destinationIndexPath
        }
        let previousString = players[sourceIndexPath.row]
        players.removeAtIndex(sourceIndexPath.row)
        players.insert(previousString, atIndex: destinationIndexPath.row)
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isPairsMode() {
            return false
        }
        if isReadyToDeleteRow && readyToDeleteIndexPath == indexPath {
            return false
        }
        if countRowNumberForIndexPath(indexPath) == players.count {
            return false
        } else {
            return true
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
                gameInstance?.roundDuration = Float(Int(roundLengthStepper.value))
                gameInstance?.wordsPerPlayer = Int(wordsPerPlayerStepper.value)
                gameInstance?.type = gameTypeSegmentControl.selectedSegmentIndex == 0 ? GameType.EachToEach : GameType.Pairs
                gameInstance?.difficulty = 20 * difficultyPicker.selectedRowInComponent(0) + 10
                gameInstance?.reinitialize()
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "Start Round" {
            for (index, player) in players.enumerate() {
                if player == "" {
                    let cell = playersTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index % 2, inSection: index / 2)) as! PlayerTableViewCell
                    cell.playerLabel.becomeFirstResponder()
                    return false
                }
            }
            if isPairsMode() && players.count % 2 == 1 {
                let alertView = UIAlertView(title: "Error", message: "Each pair should have exactly 2 players", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
                return false
            }
            if gameInstance!.didWordsLoad == false {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("startRound"))
        startRound()
    }
    
    func startRound() {
        self.performSegueWithIdentifier("Start Round", sender: nil)
    }
    
    func countRowNumberForIndexPath(indexPath: NSIndexPath) -> Int {
        var rowNumber = 0
        for i in 0..<indexPath.section {
            rowNumber += playersTableView.numberOfRowsInSection(i)
        }
        rowNumber += indexPath.row
        return rowNumber
    }
    
    func nextIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> NSIndexPath? {
        var currentIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        while (currentIndexPath.row >= tableView.numberOfRowsInSection(currentIndexPath.section)) {
            currentIndexPath = NSIndexPath(forRow: 0, inSection: currentIndexPath.section + 1)
            if currentIndexPath.section == numberOfSectionsInTableView(tableView) {
                return nil
            }
        }
        return currentIndexPath
    }
    
    func isPairsMode() -> Bool {
        return gameTypeSegmentControl.selectedSegmentIndex == 1 ? true : false
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

