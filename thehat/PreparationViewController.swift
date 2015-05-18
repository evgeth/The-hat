//
//  PreparationViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 22/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class PreparationViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var delegate: GameDelegate?

    @IBOutlet weak var listener: UILabel!
    @IBOutlet weak var speaker: UILabel!
    
    @IBOutlet weak var startImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentPlayers = delegate?.currentPlayers() {
            speaker.text = currentPlayers.0
            listener.text = currentPlayers.1
            delegate?.game().rounds.append(Round(number: delegate!.getRoundNumber(), speaker: currentPlayers.0, listener: currentPlayers.1))
        }
        
        // Do any additional setup after loading the view.
        startImageView.layer.cornerRadius = 50
        startImageView.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let currentPlayers = delegate?.currentPlayers() {
            speaker.text = currentPlayers.0
            listener.text = currentPlayers.1
        }
        
        if delegate != nil {
            let roundNumber = delegate?.getRoundNumber()
            if roundNumber != 0 {
                self.navigationItem.setHidesBackButton(true, animated: false)
                var editWordsImage = UIImage(named: "Edit words")
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: editWordsImage, style: .Plain, target: self, action: Selector("editGuessedWords"))
//                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Edit guessed", style: .Plain, target: nil, action: nil)
                self.navigationItem.title = "Round \(roundNumber! + 1)"
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func screenLeftEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        println("elodsofsd")
    }
    
    func editGuessedWords() {
        var editWordsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EditGuessedWords") as! EditWordsGuessedViewController
        editWordsViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        editWordsViewController.gameDelegate = self.delegate
        
        var popoverPC = editWordsViewController.popoverPresentationController
        popoverPC!.delegate = self
        popoverPC!.barButtonItem = self.navigationItem.leftBarButtonItem
        popoverPC!.backgroundColor = UIColor.whiteColor()
        self.presentViewController(editWordsViewController, animated: true, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Start Round" {
            if let roundVC = segue.destinationViewController as? RoundViewController {
                roundVC.delegate = self.delegate
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
