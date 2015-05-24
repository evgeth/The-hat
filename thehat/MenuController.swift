//
//  ViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class MenuController: UIViewController, UIPopoverPresentationControllerDelegate {

    var gameInstance: Game!
    
    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var rulesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameInstance = Game()
        
        self.gameInstance.loadWords()
        newGameLabel.layer.cornerRadius = 15
        newGameLabel.layer.masksToBounds = true
        rulesLabel.layer.cornerRadius = 12
        rulesLabel.layer.masksToBounds = true
        
//        UIBarButtonItem.appearance().setTitleTextAttributes(<#attributes: [NSObject : AnyObject]!#>, forState: <#UIControlState#>)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Rules Segue" {
            if let destinationViewController = segue.destinationViewController as? UIViewController {
                destinationViewController.popoverPresentationController!.backgroundColor = UIColor.whiteColor()
                destinationViewController.popoverPresentationController!.delegate = self
            }
        } else if segue.identifier == "New Game" {
            if let destinationVC = segue.destinationViewController as? GameSettingsViewController {
                destinationVC.gameInstance = self.gameInstance
            }
        }
    }
    
    // Game Delegate implementation
    
    
   

}

