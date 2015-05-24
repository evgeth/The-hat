//
//  EditWordsGuessedViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 18/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class EditWordsGuessedViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate, ColorChangingViewDelegate {

    @IBOutlet weak var guessedWordsTableView: UITableView!
    var wordList: [String] = []
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
            wordList = rounds[rounds.count - 2].guessedWords
        }
        
        var label = UILabel(frame: CGRect(x: 0, y: -60, width: guessedWordsTableView.frame.width, height: 60))
        label.font = UIFont(name: "Avenir Next", size: 24)
        label.text = "Pull to mark mistake"
        label.backgroundColor = UIColor(r: 203, g: 222, b: 203, a: 80)
        label.textAlignment = NSTextAlignment.Center
        pullToMarkMistakeLabel = label
        guessedWordsTableView.addSubview(label)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pullToMarkMistakeLabel.frame.size = CGSize(width: scrollView.frame.width, height: pullToMarkMistakeLabel.frame.height)
        var percentage = CGFloat(-scrollView.contentOffset.y / pullToMarkMistakeLabel.frame.height)
        var color = UIColor(r: 180, g: 60, b: 10, a: 80)
        let finishColorComponents = CGColorGetComponents(color.CGColor)
        let startColorComponents = CGColorGetComponents(UIColor(r: 203, g: 222, b: 203, a: 80).CGColor)
        pullToMarkMistakeLabel.backgroundColor = UIColor(red: startColorComponents[0] + (finishColorComponents[0] - startColorComponents[0]) * percentage, green: startColorComponents[1] + (finishColorComponents[1] - startColorComponents[1]) * percentage, blue: startColorComponents[2] + (finishColorComponents[2] - startColorComponents[2]) * percentage, alpha: startColorComponents[3] + (finishColorComponents[3] - startColorComponents[2]) * percentage)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        scrollView.contentOffset.y = -pullToMarkMistakeLabel.frame.height
        if -scrollView.contentOffset.y >= pullToMarkMistakeLabel.frame.height {
            isPulledEnough = true
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        if isPulledEnough {
             scrollView.setContentOffset(CGPoint(x: 0, y: -pullToMarkMistakeLabel.frame.height), animated: true)
        }
//        scrollView.setContentOffset(CGPoint(x: 0, y: -pullToMarkMistakeLabel.frame.height), animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("word") as! GuessedWordCell
        cell.wordLabel.text = wordList[indexPath.row]
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell?.accessoryType = UITableViewCellAccessoryType.None
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }
    
    func touchEnded() {
        
    }
    
    func requiredTouchDurationReached() {
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
