//
//  EditWordsGuessedViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 18/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class EditWordsGuessedViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var guessedWordsTableView: UITableView!
    var wordList = [Word]()
    var gameInstance: Game?
    
    @IBOutlet weak var saveView: UIView!
    var pullToMarkMistakeLabel: UILabel!
    var isPulledEnough = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guessedWordsTableView.delegate = self
        guessedWordsTableView.dataSource = self
        // Do any additional setup after loading the view.
        if (gameInstance != nil) {
            var rounds = gameInstance!.rounds
            for wordString in rounds[rounds.count - 2].guessedWords {
                wordList.append(Word(word: wordString.word))
                wordList.last!.state = wordString.state
            }
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: -60, width: guessedWordsTableView.frame.width, height: 60))
        label.font = UIFont(name: "Avenir Next", size: 24)
        label.text = "Pull to mark mistake"
        label.backgroundColor = UIColor(r: 203, g: 222, b: 203, a: 80)
        label.textAlignment = NSTextAlignment.Center
        pullToMarkMistakeLabel = label
        guessedWordsTableView.addSubview(label)
    }
    
    override func viewWillDisappear(animated: Bool) {
        gameInstance?.setGuessedWordsForRound(wordList)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pullToMarkMistakeLabel.frame.size = CGSize(width: scrollView.frame.width, height: pullToMarkMistakeLabel.frame.height)
        let percentage = CGFloat(-scrollView.contentOffset.y / pullToMarkMistakeLabel.frame.height)
        let color = UIColor(r: 180, g: 60, b: 10, a: 80)
        let finishColorComponents = CGColorGetComponents(color.CGColor)
        let startColorComponents = CGColorGetComponents(UIColor(r: 203, g: 222, b: 203, a: 80).CGColor)
        pullToMarkMistakeLabel.backgroundColor = UIColor(red: startColorComponents[0] + (finishColorComponents[0] - startColorComponents[0]) * percentage, green: startColorComponents[1] + (finishColorComponents[1] - startColorComponents[1]) * percentage, blue: startColorComponents[2] + (finishColorComponents[2] - startColorComponents[2]) * percentage, alpha: startColorComponents[3] + (finishColorComponents[3] - startColorComponents[2]) * percentage)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        scrollView.contentOffset.y = -pullToMarkMistakeLabel.frame.height
        if -scrollView.contentOffset.y >= pullToMarkMistakeLabel.frame.height {
            isPulledEnough = true
            wordList.last?.state = State.Fail
            guessedWordsTableView.reloadData()
            gameInstance?.setGuessedWordsForRound(wordList)
        }
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
        cell.wordLabel.textColor = UIColor.blackColor()
        if wordList[indexPath.row].state == State.Guessed{
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else if wordList[indexPath.row].state == State.New {
            cell.accessoryType = UITableViewCellAccessoryType.None
        } else {
            cell.wordLabel.textColor = UIColor.redColor()
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GuessedWordCell
        cell.wordLabel.textColor = UIColor.blackColor()
        if wordList[indexPath.row].state == State.Guessed{
            cell.accessoryType = UITableViewCellAccessoryType.None
            wordList[indexPath.row].state = State.New
        } else if wordList[indexPath.row].state == State.New {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            wordList[indexPath.row].state = State.Guessed
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            wordList[indexPath.row].state = State.Guessed
        }
    }
    
    @IBAction func saveButtonTouch(sender: UIButton) {
        saveCorrectionsAndClose()
    }
    
    func saveCorrectionsAndClose() {
        gameInstance?.setGuessedWordsForRound(wordList)
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
