//
//  TutorialPageViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 04/01/16.
//  Copyright © 2016 dpfbop. All rights reserved.
//

import UIKit

protocol TutorialDelegate: AnyObject {
    func openNewGame()
}

final class TutorialPageViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var newGameButton: UIView!
    @IBOutlet weak var iphoneImageView: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var newGameLabel: UILabel! {
        didSet {
            newGameLabel.text = LS.localizedString(forKey: "NEW_GAME")
        }
    }

    var descriptionText: String!
    var imageName: String!
    var pageIndex: Int = 0
    weak var delegate: TutorialDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if descriptionText == "new game" {
            newGameButton.isHidden = false
            descriptionLabel.isHidden = true
            backgroundImage.isHidden = false
            iphoneImageView.isHidden = true
            imageView.isHidden = true
            newGameButton.isUserInteractionEnabled = true
        } else {
            newGameButton.isUserInteractionEnabled = false
            imageView.image = UIImage(named: imageName)
            descriptionLabel.text = descriptionText
        }
    }

    @IBAction func onNewGameAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.openNewGame()
        }
    }

}
