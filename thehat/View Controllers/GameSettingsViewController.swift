//
//  GameSettingsViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Crashlytics

let loadedWordsNotifictionKey = "com.dpfbop.loadedWordsNotificationKey"

class GameSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, PlayerTableViewCellDelegate {
    
    @IBOutlet weak var playersTableView: UITableView!
    var isReadyToDeleteRow: Bool = false
    var readyToDeleteIndexPath = IndexPath(row: 0, section: 0)
    var players: [String] = ["", "", "", ""]
    var sectionsCount = 2
    var isAddingSection = false
    var numberOfRowsInLastSection = 3
    var gameInstance = GameSingleton.gameInstance
    
    @IBOutlet weak var gameTypeLabel: UILabel! {
        didSet {
            gameTypeLabel.text = LS.localizedString(forKey: "game_type")

        }
    }
    @IBOutlet weak var difficultyPicker: UIPickerView!
    @IBOutlet weak var wordsInTheHatStepper: UIStepper!
    @IBOutlet weak var wordsInTheHatLabel: UILabel!
    @IBOutlet weak var wordsLabel: UILabel! {
        didSet {
            wordsLabel.text = LS.localizedString(forKey: "words_in_the_hat")
        }
    }

    @IBOutlet weak var roundLabel: UILabel! {
        didSet {
            roundLabel.text = LS.localizedString(forKey: "round_length")
        }
    }

    @IBOutlet weak var roundLengthStepper: UIStepper!
    @IBOutlet weak var roundLengthLabel: UILabel!
    @IBOutlet weak var gameTypeSegmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playersTableView.dataSource = self
        playersTableView.delegate = self
        
        difficultyPicker.delegate = self
        difficultyPicker.dataSource = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        setNavigationBarTitleWithCustomFont(title: LS.localizedString(forKey: "GAME_SETTINGS"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(self.startRound)
        )
        playersTableView.setEditing(true, animated: true)
        roundLengthLabel.text = "\(Int(roundLengthStepper.value))"
        difficultyPicker.selectRow(2, inComponent: 0, animated: false)
        
        
        if gameInstance.players.count != 0 {
            var playersList = [String]()
            for player in gameInstance.players {
                playersList.append(player.name)
            }
            players = playersList
        }
        
        if let savedPlayers = UserDefaults.standard.value(forKey: UserDefaultsKeys.SAVED_PLAYER_NAMES) as? [String] {
            players = savedPlayers
        }
        
        roundLengthStepper.value = Double(gameInstance.roundDuration)
        wordsInTheHatStepper.value = Double(gameInstance.wordsInTheHat)
        reloadLabels()
        gameTypeSegmentControl.setTitle(LS.localizedString(forKey: "each_to_each"), forSegmentAt: 0)
        gameTypeSegmentControl.setTitle(LS.localizedString(forKey: "pairs"), forSegmentAt: 1)

        gameTypeSegmentControl.selectedSegmentIndex =
            (gameInstance.type == GameType.Pairs) ? 1:0
        difficultyPicker.selectRow((gameInstance.difficulty - 10) / 20, inComponent: 0, animated: false)
        sectionsCount = (players.count + 1) / 2
        numberOfRowsInLastSection = players.count % 2 == 0 ? 3 : 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        Answers.logCustomEvent(withName: "Open Screen", customAttributes: ["Screen name": "Game Settings"])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        5
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let difficulties = [
            LS.localizedString(forKey: "VERY_EASY"),
            LS.localizedString(forKey: "EASY"),
            LS.localizedString(forKey: "NORMAL"),
            LS.localizedString(forKey: "HARD"),
            LS.localizedString(forKey: "VERY_HARD")
        ]
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: pickerView.rowSize(forComponent: component)))
        label.text = difficulties[row]
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = NSTextAlignment.center
        
        return label
    }
    
    @IBAction func wordsInTheHatValueChanged(sender: UIStepper) {
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
        wordsInTheHatLabel.text = "\(Int(wordsInTheHatStepper.value))"
        roundLengthLabel.text = "\(Int(roundLengthStepper.value))"
    }
    
    @IBAction func cellLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.ended) {
            let swipeLocation = sender.location(in: playersTableView)
            let swipedIndexPath = playersTableView.indexPathForRow(at: swipeLocation)
            
            if swipedIndexPath == nil || countRowNumberForIndexPath(indexPath: swipedIndexPath!) == players.count || isReadyToDeleteRow {
                return
            }
            if isPairsMode() && swipedIndexPath!.section != playersTableView.numberOfSections - 1 {
                return
            }
            
            
            isReadyToDeleteRow = true
            readyToDeleteIndexPath = swipedIndexPath!
            playersTableView.reloadRows(at: [swipedIndexPath!], with: UITableView.RowAnimation.automatic)
        }
    }
    
    @IBAction func cellRightSwipe(_ sender: AnyObject) {
        if (sender.state == UIGestureRecognizer.State.ended) {
            let swipeLocation = sender.location(in: playersTableView)
            let swipedIndexPath = playersTableView.indexPathForRow(at: swipeLocation)
            
            if swipedIndexPath == nil || countRowNumberForIndexPath(indexPath: swipedIndexPath!) == players.count || isReadyToDeleteRow {
                return
            }
            guard let indexPath = swipedIndexPath else {
                return
            }
            players[indexPath.row] = RandomNames.getRandomName()
            playersTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
    func hideDeleteButton() {
        if isReadyToDeleteRow {
            isReadyToDeleteRow = false
            
            playersTableView.reloadRows(at: [readyToDeleteIndexPath], with: UITableView.RowAnimation.fade)
        }
    }
    
    @IBAction func textFieldEditBegin(_ sender: UITextField) {
        if let cell = sender.superview?.superview as? PlayerTableViewCell {
            let indexPath = playersTableView.indexPath(for: cell)
            if indexPath != nil {
                if countRowNumberForIndexPath(indexPath: indexPath!) < players.count - 1 {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.next
                } else {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.done
                }
            }
        }
        hideDeleteButton()
    }
    
    @IBAction func playerNameModified(_ sender: UITextField, forEvent event: UIEvent) {
        if let cell = sender.superview?.superview as? PlayerTableViewCell {
            let indexPath = playersTableView.indexPath(for: cell)
            if indexPath != nil {
                players[countRowNumberForIndexPath(indexPath: indexPath!)] = sender.text!
                if countRowNumberForIndexPath(indexPath: indexPath!) < players.count - 1 {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.next
                } else {
                    cell.playerLabel.returnKeyType = UIReturnKeyType.done
                }
            }
        }
    }
    
    @IBAction func addPlayerButtonPressed(sender: UIButton?) {
        if isPairsMode() {
            if players.count % 2 == 0 {
                numberOfRowsInLastSection = 2
                playersTableView.deleteRows(at: [IndexPath(row: 2, section: playersTableView.numberOfSections - 1)], with: UITableView.RowAnimation.automatic)
                sectionsCount += 1
                players.append("")
                playersTableView.insertSections(NSIndexSet(index: playersTableView.numberOfSections) as IndexSet, with: UITableView.RowAnimation.automatic)
            } else {
                players.append("")
                numberOfRowsInLastSection = 3
                playersTableView.insertRows(at: [IndexPath(row: 1, section: playersTableView.numberOfSections - 1)], with: UITableView.RowAnimation.automatic)
            }
        } else {
            players.append("")
            playersTableView.insertRows(at: [IndexPath(row: players.count - 1, section: 0)], with: UITableView.RowAnimation.none)
            playersTableView.reloadRows(at: [IndexPath(row: players.count - 1, section: 0)], with: UITableView.RowAnimation.fade)
        }
    }
    
    @IBAction func tapOnPlayersTable(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        hideDeleteButton()
    }
    
    @IBAction func hideButtonPressed(sender: UIButton) {
        sender.isEnabled = false
        hideDeleteButton()
    }
    
    func deleteButtonPressed(_ indexPath: IndexPath) {
        if let cell = playersTableView.cellForRow(at: indexPath) {
            let indexPath = playersTableView.indexPath(for: cell)
            hideDeleteButton()
            if players.count > 2 {
                if isPairsMode() {
                    if indexPath?.section == playersTableView.numberOfSections - 1 {
                        players.remove(at: countRowNumberForIndexPath(indexPath: indexPath!))
                        if players.count % 2 == 1 {
                            numberOfRowsInLastSection = 2
                            playersTableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                        } else {
                            numberOfRowsInLastSection = 1
                            playersTableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                            sectionsCount -= 1
                            numberOfRowsInLastSection = 2
                            playersTableView.deleteSections(IndexSet(integer: playersTableView.numberOfSections - 1) as IndexSet, with: UITableView.RowAnimation.fade)
                            numberOfRowsInLastSection = 3
                            playersTableView.insertRows(at: [IndexPath(row: 2, section: playersTableView.numberOfSections - 1)], with: UITableView.RowAnimation.automatic)
                            
                        }
                    }
                } else {
                    players.remove(at: indexPath!.row)
                    playersTableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.fade)
                }
            } else {
                let alertView = UIAlertView(title: "Error", message: "You need at least 2 players for game", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let centerOfView = textField.superview?.superview?.center
        if (centerOfView == nil) {
            return false
        }
        let indexPathForTextField = playersTableView.indexPathForRow(at: centerOfView!)!
        let cell = playersTableView.cellForRow(at: indexPathForTextField) as! PlayerTableViewCell
        let indexPathToMoveFocus = nextIndexPath(tableView: playersTableView, indexPath: indexPathForTextField)
        if indexPathToMoveFocus != nil && countRowNumberForIndexPath(indexPath: indexPathToMoveFocus!) != players.count {
            let nextCell = playersTableView.cellForRow(at: indexPathToMoveFocus!) as! PlayerTableViewCell
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if countRowNumberForIndexPath(indexPath: indexPath) == players.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Add Player")! as UITableViewCell
            cell.showsReorderControl = false
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Player") as! PlayerTableViewCell
        cell.showsReorderControl = true
        if let textField = cell.playerLabel {
            textField.text = players[countRowNumberForIndexPath(indexPath: indexPath)]
            textField.delegate = self
            if countRowNumberForIndexPath(indexPath: indexPath) < players.count - 1 {
                textField.returnKeyType = UIReturnKeyType.next
            } else {
                textField.returnKeyType = UIReturnKeyType.done
            }
        }
        let deleteButton = cell.deleteButton
        let hideButton = cell.hideButton
        cell.delegate = self
        deleteButton?.alpha = 0
        hideButton?.isEnabled = false
        if isReadyToDeleteRow && readyToDeleteIndexPath == indexPath {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                deleteButton?.alpha = 1
            })
            hideButton?.isEnabled = true
        }
        
        
        return cell
    }
    
    func indexPathForCell(cell: UITableViewCell) -> IndexPath {
        return playersTableView.indexPath(for: cell)!
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isPairsMode() {
            return sectionsCount
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPairsMode() {
            if section == numberOfSections(in: tableView) - 1 {
                return numberOfRowsInLastSection
            }
            return 2
        } else {
            return players.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isPairsMode() {
            return 22
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isPairsMode() {
            return "\(NSLocalizedString("PAIR", comment: "pair")) \(section + 1)"
        } else {
            return ""
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if !isPairsMode() {
            if isReadyToDeleteRow && readyToDeleteIndexPath.count == indexPath.row {
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
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        hideDeleteButton()
        if isPairsMode() {
            return proposedDestinationIndexPath
        } else {
            if proposedDestinationIndexPath.row == players.count {
                return IndexPath(row: players.count - 1, section: sourceIndexPath.section)
            } else {
                return proposedDestinationIndexPath
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if isPairsMode() {
            return
        }
        if isReadyToDeleteRow && sourceIndexPath.row == readyToDeleteIndexPath.count {
            readyToDeleteIndexPath = destinationIndexPath
        }
        let previousString = players[sourceIndexPath.row]
        players.remove(at: sourceIndexPath.row)
        players.insert(previousString, at: destinationIndexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isPairsMode() {
            return false
        }
        if isReadyToDeleteRow && readyToDeleteIndexPath == indexPath {
            return false
        }
        if countRowNumberForIndexPath(indexPath: indexPath) == players.count {
            return false
        } else {
            return true
        }
    }

    private func shouldStartGame() -> Bool {
        for (index, player) in players.enumerated() {
            if player == "" {
                var cell: PlayerTableViewCell!
                if isPairsMode() {
                    cell = playersTableView.cellForRow(at: IndexPath(row: index % 2, section: index / 2) as IndexPath) as! PlayerTableViewCell
                } else {
                    cell = playersTableView.cellForRow(at: IndexPath(row: index, section: 0) as IndexPath) as! PlayerTableViewCell
                }
                cell.playerLabel.becomeFirstResponder()
                return false
            }
        }
        if isPairsMode() && players.count % 2 == 1 {
            let alertView = UIAlertView(title: "Error", message: NSLocalizedString("NOT_ENOUGH_PLAYERS_IN_PAIR", comment: "not enough players in pair"), delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
            return false
        }
        if gameInstance.didWordsLoad == false {
            let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
            NotificationCenter.default.addObserver(self, selector: Selector(("wordsLoadedNotificationArrived:")), name: NSNotification.Name(rawValue: loadedWordsNotifictionKey), object: nil)
            activityIndicator.center = view.center
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
            return false
        } else {
            return true
        }
    }

    @objc
    func wordsLoadedNotificationArrived(notification: NSNotification) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(self.startRound)
        )
        startRound()
    }
    
    @objc
    private func startRound() {
        guard shouldStartGame() else {
            return
        }
        UserDefaults.standard.set(players, forKey: UserDefaultsKeys.SAVED_PLAYER_NAMES)
        var playersList: [Player] = []
        for playerName in players {
            playersList.append(Player(name: playerName))
            Answers.logCustomEvent(
                withName: "Player",
                customAttributes: ["name": playerName.lowercased().capitalized]
            )
        }
        gameInstance.players = playersList
        gameInstance.roundDuration = Float(Int(roundLengthStepper.value))
        gameInstance.wordsInTheHat = Int(wordsInTheHatStepper.value)
        gameInstance.type = gameTypeSegmentControl.selectedSegmentIndex == 0 ? GameType.EachToEach : GameType.Pairs
        gameInstance.difficulty = 20 * difficultyPicker.selectedRow(inComponent: 0) + 10

        Answers.logCustomEvent(
            withName: "Start game",
            customAttributes: [
                "Duration": "\(gameInstance.roundDuration)",
                "Number of words": "\(gameInstance.wordsInTheHat)",
                "Game type": "\(gameInstance.type)",
                "Difficulty": "\(gameInstance.difficulty)"
            ]
        )

        navigationController?.pushViewController(AddWordViewController(), animated: true)
    }
    
    func countRowNumberForIndexPath(indexPath: IndexPath) -> Int {
        var rowNumber = 0
        for i in 0..<indexPath.section {
            rowNumber += playersTableView.numberOfRows(inSection: i)
        }
        rowNumber += indexPath.row
        return rowNumber
    }
    
    func nextIndexPath(tableView: UITableView, indexPath: IndexPath) -> IndexPath? {
        var currentIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        while (currentIndexPath.row >= tableView.numberOfRows(inSection: currentIndexPath.section)) {
            currentIndexPath = IndexPath(row: 0, section: currentIndexPath.section + 1)
            if currentIndexPath.section == numberOfSections(in: tableView) {
                return nil
            }
        }
        return currentIndexPath
    }
    
    func isPairsMode() -> Bool {
        return gameTypeSegmentControl.selectedSegmentIndex == 1 ? true : false
    }

}

