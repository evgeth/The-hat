//
//  GameSettingsViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class GameSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var roundTimeLabel: UILabel!
    @IBOutlet weak var playersTableView: UITableView!
    
    var players: [String] = ["", "", "", ""]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playersTableView.dataSource = self
        playersTableView.delegate = self
        
        playersTableView.setEditing(true, animated: true)
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Player") as! MGSwipeTableCell
        cell.showsReorderControl = true
        if let textField = cell.viewWithTag(1) as? UITextField {
            if indexPath.row != players.count {
                textField.text = players[indexPath.row]
            } else {
                textField.text = ""
            }
        }
        cell.leftButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor())]
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row != players.count {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.row == players.count {
            return NSIndexPath(forRow: players.count - 1, inSection: sourceIndexPath.section)
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
