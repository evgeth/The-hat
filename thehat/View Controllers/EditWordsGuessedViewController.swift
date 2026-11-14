//
//  EditWordsGuessedViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 18/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class EditWordsGuessedViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var saveDelegate: PopoverSaveDelegate?
    var wordList = [Word]()
    var gameInstance = GameSingleton.gameInstance
    var pullToMarkMistakeLabel: UILabel!
    var isPulledEnough = false
    
    @IBOutlet weak var saveLabel: UILabel! {
        didSet {
            saveLabel.text = LS.localizedString(forKey: "save")
        }
    }
    @IBOutlet weak var guessedWordsTableView: UITableView!

    @IBOutlet weak var saveView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        guessedWordsTableView.delegate = self
        guessedWordsTableView.dataSource = self
        let rounds = gameInstance.rounds
        for wordString in rounds[rounds.count - 2].guessedWords {
            let word = Word(word: wordString.word)
            word.state = wordString.state
            wordList.append(word)
        }
        WarmUI.review(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        gameInstance.setGuessedWordsForRound(guessedWords: wordList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("open_screen", parameters: ["screen_name": "Edit words"])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word") as! GuessedWordCell
        cell.wordLabel.text = wordList[indexPath.row].word
        let state = wordList[indexPath.row].state
        switch state {
        case .guessed: cell.wordStatus.text = "✓"; cell.wordStatus.textColor = AppColors.success
        case .new: cell.wordStatus.text = "↶"; cell.wordStatus.textColor = AppColors.returnedWord
        case .fail: cell.wordStatus.text = "×"; cell.wordStatus.textColor = AppColors.fail
        }
        cell.accessibilityLabel = cell.wordLabel.text
        cell.accessibilityValue = LS.localizedString(forKey: state == .new ? "review_returned" : state == .guessed ? "review_guessed" : "mistake")
        cell.accessibilityTraits = .button
        WarmUI.reviewCell(cell, at: indexPath)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if wordList[indexPath.row].state == State.guessed{
            wordList[indexPath.row].state = State.new
        } else if wordList[indexPath.row].state == State.new {
            wordList[indexPath.row].state = State.fail
        } else {
            wordList[indexPath.row].state = State.guessed
        }
        tableView.reloadRows(at: [(indexPath as IndexPath)], with: UITableView.RowAnimation.automatic)
        self.saveDelegate?.updated()
    }
    
    @IBAction func saveButtonTouch(_ sender: UIButton) {
        saveCorrectionsAndClose()
    }
    
    func saveCorrectionsAndClose() {
        gameInstance.setGuessedWordsForRound(guessedWords: wordList)
        self.saveDelegate?.updated()
        dismiss(animated: true, completion: nil)
    }
}
