//
//  TutorialPageViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 04/01/16.
//  Copyright © 2016 dpfbop. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var newGameButton: UIView!
    
    var descriptionText: String!
    var imageName: String!
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if descriptionText == "new game" {
            newGameButton.hidden = false
            descriptionLabel.hidden = true
        } else {
            imageView.image = UIImage(named: imageName)
            descriptionLabel.text = descriptionText
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "New Game Segue" {
//            if let destinationVC = segue.destinationViewController as? GameSettingsViewController {
//                let game = Game()
//                game.loadWords()
//                destinationVC.gameInstance = game
//            }
        }
    }

}