//
//  EditWordsGuessedViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 18/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Crashlytics

class EditWordsGuessedViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var guessedWordsTableView: UITableView!
    var wordList = [Word]()
    var gameInstance = GameSingleton.gameInstance
    
    var saveDelegate: PopoverSaveDelegate?
    
    @IBOutlet weak var saveView: UIView!
    var pullToMarkMistakeLabel: UILabel!
    var isPulledEnough = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guessedWordsTableView.delegate = self
        guessedWordsTableView.dataSource = self
        // Do any additional setup after loading the view.
        var rounds = gameInstance.rounds
        for wordString in rounds[rounds.count - 2].guessedWords {
            wordList.append(Word(word: wordString.word))
            wordList.last!.state = wordString.state
        }
        
//        let label = UILabel(frame: CGRect(x: 0, y: -60, width: guessedWordsTableView.frame.width, height: 60))
//        label.font = UIFont(name: "Avenir Next", size: 24)
//        label.text = "Pull to mark mistake"
//        label.backgroundColor = UIColor(r: 203, g: 222, b: 203, a: 80)
//        label.textAlignment = NSTextAlignment.Center
//        pullToMarkMistakeLabel = label
//        guessedWordsTableView.addSubview(label)
    }
    
    override func viewWillDisappear(animated: Bool) {
        gameInstance.setGuessedWordsForRound(wordList)
    }
    
    override func viewWillAppear(animated: Bool) {
        Answers.logCustomEventWithName("Open Screen", customAttributes: ["Screen name": "Edit words"])
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("word") as! GuessedWordCell
        cell.wordLabel.text = wordList[indexPath.row].word
        if wordList[indexPath.row].state == State.Fail {
            
        }
        cell.wordStatus.transform = CGAffineTransformMakeRotation(CGFloat(0))
        cell.wordStatus.font = UIFont(name: "Avenir Next", size: 42)
        if wordList[indexPath.row].state == State.Guessed {
            cell.wordStatus.text = "✓";
            cell.wordStatus.textColor = UIColor(r: 0, g: 128, b: 0, a: 100)
            cell.wordLabel.textColor = UIColor(r: 0, g: 128, b: 0, a: 100)
        } else if wordList[indexPath.row].state == State.New {
            cell.wordStatus.text = "🎩";
            cell.wordStatus.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            cell.wordStatus.font = UIFont(name: "Avenir Next", size: 34)
            cell.wordStatus.textColor = UIColor(r: 0, g: 0, b: 0, a: 100)
            cell.wordLabel.textColor = UIColor.blackColor()
        } else {
            cell.wordStatus.text = "✗";
            cell.wordStatus.textColor = UIColor(r: 128, g: 0, b: 0, a: 100)
            cell.wordLabel.textColor = UIColor.redColor()
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if wordList[indexPath.row].state == State.Guessed{
            wordList[indexPath.row].state = State.New
        } else if wordList[indexPath.row].state == State.New {
            wordList[indexPath.row].state = State.Fail
        } else {
            wordList[indexPath.row].state = State.Guessed
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.saveDelegate?.updated()
    }
    
    @IBAction func saveButtonTouch(sender: UIButton) {
        saveCorrectionsAndClose()
    }
    
    func saveCorrectionsAndClose() {
        gameInstance.setGuessedWordsForRound(wordList)
        self.saveDelegate?.updated()
        dismissViewControllerAnimated(true, completion: nil)
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
