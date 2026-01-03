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
        if wordList[indexPath.row].state == State.fail {
            
        }
        cell.wordStatus.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        cell.wordStatus.font = UIFont(name: "Excalifont", size: 42)
        if wordList[indexPath.row].state == State.guessed {
            cell.wordStatus.text = "✓";
            cell.wordStatus.textColor = AppColors.success
            cell.wordLabel.textColor = AppColors.success
        } else if wordList[indexPath.row].state == State.new {
            cell.wordStatus.text = "🎩";
            cell.wordStatus.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            cell.wordStatus.font = UIFont(name: "Excalifont", size: 34)
            cell.wordStatus.textColor = AppColors.textPrimary
            cell.wordLabel.textColor = AppColors.textPrimary
        } else {
            cell.wordStatus.text = "✗";
            cell.wordStatus.textColor = AppColors.fail
            cell.wordLabel.textColor = AppColors.fail
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        LS.localizedString(forKey: "GUESSED_WORDS")
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
