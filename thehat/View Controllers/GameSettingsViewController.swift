//
//  GameSettingsViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import FirebaseAnalytics

let loadedWordsNotificationKey = "com.dpfbop.loadedWordsNotificationKey"

class GameSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, PlayerTableViewCellDelegate {
    
    @IBOutlet weak var playersTableView: UITableView!
    private var revealedDeleteRow: IndexPath?
    var players: [String] = ["", "", "", ""]
    let allowsSkippingSwitch = UISwitch()
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
        while players.count < 2 { players.append("") }
        WarmUI.settings(self)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissEditingOutsideField(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        Analytics.logEvent("open_screen", parameters: ["screen_name": "Game Settings"])
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
        view.endEditing(true)
        reloadRoster()
    }

    private func reloadRoster() {
        revealedDeleteRow = nil
        playersTableView.reloadData()
        playersTableView.superview?.setNeedsLayout()
    }

    func reloadLabels() {
        wordsInTheHatLabel.text = "\(Int(wordsInTheHatStepper.value))"
        roundLengthLabel.text = "\(Int(roundLengthStepper.value))"
    }
    
    @IBAction func cellLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        guard sender.state == .ended, revealedDeleteRow == nil,
              let path = playersTableView.indexPathForRow(at: sender.location(in: playersTableView)),
              players.indices.contains(countRowNumberForIndexPath(indexPath: path)),
              !isPairsMode() || path.section == numberOfSections(in: playersTableView) - 1 else { return }
        view.endEditing(true)
        revealedDeleteRow = path
        playersTableView.reloadRows(at: [path], with: .none)
    }

    @IBAction func cellRightSwipe(_ sender: UISwipeGestureRecognizer) {
        guard sender.state == .ended, revealedDeleteRow == nil,
              let path = playersTableView.indexPathForRow(at: sender.location(in: playersTableView)) else { return }
        let index = countRowNumberForIndexPath(indexPath: path)
        guard players.indices.contains(index) else { return }
        view.endEditing(true)
        players[index] = RandomNames.getRandomName()
        playersTableView.reloadRows(at: [path], with: .none)
    }

    private func hideDeleteButton() {
        guard let path = revealedDeleteRow else { return }
        revealedDeleteRow = nil
        playersTableView.reloadRows(at: [path], with: .none)
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
        guard let cell = sender.superview?.superview as? PlayerTableViewCell,
              let path = playersTableView.indexPath(for: cell) else { return }
        let index = countRowNumberForIndexPath(indexPath: path)
        guard players.indices.contains(index) else { return }
        players[index] = sender.text ?? ""
    }

    @IBAction func addPlayerButtonPressed(sender: UIButton?) {
        view.endEditing(true)
        players.append("")
        reloadRoster()
        playersTableView.scrollToRow(at: playerIndexPath(players.count - 1), at: .none, animated: false)
    }

    @objc private func dismissEditingOutsideField(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        hideDeleteButton()
    }
    
    @IBAction func hideButtonPressed(sender: UIButton) {
        sender.isEnabled = false
        hideDeleteButton()
    }
    
    func deletePlayer(in cell: PlayerTableViewCell) {
        guard let path = playersTableView.indexPath(for: cell), path == revealedDeleteRow else { return }
        guard players.count > 2 else {
            hideDeleteButton()
            let alert = UIAlertController(title: WarmUI.text("warm_error"), message: WarmUI.text("warm_min_players"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: WarmUI.text("warm_ok"), style: .default))
            present(alert, animated: true)
            return
        }
        view.endEditing(true)
        players.remove(at: countRowNumberForIndexPath(indexPath: path))
        reloadRoster()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let cell = textField.superview?.superview as? PlayerTableViewCell,
              let current = playersTableView.indexPath(for: cell) else { return false }
        let next = countRowNumberForIndexPath(indexPath: current) + 1
        if players.indices.contains(next) {
            focusPlayer(at: playerIndexPath(next))
        } else { textField.resignFirstResponder() }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if countRowNumberForIndexPath(indexPath: indexPath) == players.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Add Player")! as UITableViewCell
            cell.showsReorderControl = false
            WarmUI.addPlayerCell(cell)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Player") as! PlayerTableViewCell
        cell.showsReorderControl = !isPairsMode() && indexPath != revealedDeleteRow
        if let textField = cell.playerLabel {
            textField.text = players[countRowNumberForIndexPath(indexPath: indexPath)]
            textField.delegate = self
            if countRowNumberForIndexPath(indexPath: indexPath) < players.count - 1 {
                textField.returnKeyType = UIReturnKeyType.next
            } else {
                textField.returnKeyType = UIReturnKeyType.done
            }
        }
        cell.delegate = self
        cell.deleteButton.isHidden = indexPath != revealedDeleteRow
        cell.hideButton.isHidden = indexPath != revealedDeleteRow
        cell.hideButton.isEnabled = indexPath == revealedDeleteRow
        WarmUI.playerCell(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        isPairsMode() ? (players.count + 1) / 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isPairsMode() else { return players.count + 1 }
        let members = min(2, players.count - 2 * section)
        let isLastPair = section == numberOfSections(in: tableView) - 1
        return members + (isLastPair ? 1 : 0)
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
            return "\(LS.localizedString(forKey: "PAIR")) \(section + 1)"
        } else {
            return ""
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        !isPairsMode() && indexPath != revealedDeleteRow && indexPath.row < players.count
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
        let previousString = players[sourceIndexPath.row]
        players.remove(at: sourceIndexPath.row)
        players.insert(previousString, at: destinationIndexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        self.tableView(tableView, canMoveRowAt: indexPath)
    }

    private func focusPlayer(at path: IndexPath) {
        if playersTableView.cellForRow(at: path) == nil {
            playersTableView.scrollToRow(at: path, at: .middle, animated: false)
            playersTableView.layoutIfNeeded()
        }
        (playersTableView.cellForRow(at: path) as? PlayerTableViewCell)?.playerLabel.becomeFirstResponder()
    }

    private func shouldStartGame() -> Bool {
        for (index, player) in players.enumerated() {
            if player == "" {
                focusPlayer(at: playerIndexPath(index))
                return false
            }
        }
        if isPairsMode() && players.count % 2 == 1 {
            let alert = UIAlertController(title: WarmUI.text("warm_error"), message: WarmUI.text("NOT_ENOUGH_PLAYERS_IN_PAIR"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: WarmUI.text("warm_ok"), style: .default))
            present(alert, animated: true)
            return false
        }
        if gameInstance.didWordsLoad == false {
            let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
            NotificationCenter.default.addObserver(self, selector: #selector(wordsLoadedNotificationArrived(notification:)), name: NSNotification.Name(rawValue: loadedWordsNotificationKey), object: nil)
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
            Analytics.logEvent("player", parameters: ["name": playerName.lowercased().capitalized])
        }
        gameInstance.allowsSkipping = allowsSkippingSwitch.isOn
        gameInstance.players = playersList
        gameInstance.roundDuration = Float(Int(roundLengthStepper.value))
        gameInstance.wordsInTheHat = Int(wordsInTheHatStepper.value)
        gameInstance.type = gameTypeSegmentControl.selectedSegmentIndex == 0 ? GameType.EachToEach : GameType.Pairs
        gameInstance.difficulty = 20 * difficultyPicker.selectedRow(inComponent: 0) + 10

        Analytics.logEvent("start_game", parameters: [
            "duration": "\(gameInstance.roundDuration)",
            "number_of_words": "\(gameInstance.wordsInTheHat)",
            "game_type": "\(gameInstance.type)",
            "difficulty": "\(gameInstance.difficulty)"
        ])

        navigationController?.pushViewController(AddWordViewController(), animated: true)
    }
    
    func countRowNumberForIndexPath(indexPath: IndexPath) -> Int {
        indexPath.section * 2 + indexPath.row
    }

    private func playerIndexPath(_ index: Int) -> IndexPath {
        isPairsMode() ? IndexPath(row: index % 2, section: index / 2) : IndexPath(row: index, section: 0)
    }

    func isPairsMode() -> Bool {
        gameTypeSegmentControl.selectedSegmentIndex == 1
    }

}


// Let the text field handle cursor placement and direct focus changes. A tap
// anywhere else dismisses the keyboard without consuming a control's action.
extension GameSettingsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var target = touch.view
        while let current = target {
            if current is UITextField { return false }
            if let cell = current as? PlayerTableViewCell,
               let button = touch.view, button.isDescendant(of: cell.deleteButton) || button.isDescendant(of: cell.hideButton) {
                return false
            }
            target = current.superview
        }
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
}
