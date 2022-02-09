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
    @IBOutlet weak var iphoneImageView: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var newGameLabel: UILabel! {
        didSet {
            newGameLabel.text = LanguageChanger.shared.localizedString(forKey: "NEW_GAME")
        }
    }

    var descriptionText: String!
    var imageName: String!
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if descriptionText == "new game" {
            newGameButton.isHidden = false
            descriptionLabel.isHidden = true
            backgroundImage.isHidden = false
            iphoneImageView.isHidden = true
            imageView.isHidden = true
        } else {
            imageView.image = UIImage(named: imageName)
            descriptionLabel.text = descriptionText
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "New Game Segue" {
//            if let destinationVC = segue.destinationViewController as? GameSettingsViewController {
//                let game = Game()
//                game.loadWords()
//                destinationVC.gameInstance = game
//            }
        }
    }

}
