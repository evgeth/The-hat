//
//  ViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Crashlytics

final class MenuController: UIViewController {

    var gameInstance = GameSingleton.gameInstance
    private let languageChanger = LanguageChanger.shared

    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var holdToStartNewGameLabel: UILabel! {
        didSet {

        }
    }
    @IBOutlet weak var holdToStartLabel: UILabel! {
        didSet {
            holdToStartLabel.text = LS.localizedString(forKey: "hold_to_start_new_game")
        }
    }

    @IBOutlet weak var rulesLabel: UILabel! {
        didSet {
            rulesLabel.text = LS.localizedString(forKey: "RULES")
        }
    }

    @IBOutlet weak var aboutLabel: UILabel! {
        didSet {
            aboutLabel.text = LS.localizedString(forKey: "ABOUT")
        }
    }

    @IBOutlet weak var newGameView: ColorChangingView!
    @IBOutlet weak var languageButton: UIButton! {
        didSet {
            languageButton.setTitle(LS.localizedString(forKey: "language"), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gameInstance.loadWords()
        setupView()
        setupLanguageButton()
        initNewGameButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Answers.logCustomEvent(
            withName: "Open Screen",
            customAttributes: ["Screen name": "Main Menu"]
        )
        initNewGameButton()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func initNewGameButton() {
        if gameInstance.isGameInProgress {
            holdToStartNewGameLabel.isHidden = false
            newGameLabel.text = LS.localizedString(forKey: "CONTINUE")
            newGameView.initializer(
                startColor: UIColor(r: 109, g: 236, b: 158, a: 80),
                finishColor: UIColor(r: 109, g: 250, b: 130, a: 90),
                requiredTouchDuration: 0.6, delegate: self
            )
        } else {
            holdToStartNewGameLabel.isHidden = true
            newGameLabel.text = LS.localizedString(forKey: "NEW_GAME")
            newGameView.initializer(
                startColor: UIColor(r: 109, g: 236, b: 158, a: 80),
                finishColor: UIColor(r: 109, g: 236, b: 158, a: 80),
                requiredTouchDuration: 100, delegate: self
            )
        }
    }

    private func setupView() {
        newGameLabel.layer.cornerRadius = 15
        newGameLabel.layer.masksToBounds = true
        rulesLabel.layer.cornerRadius = 12
        rulesLabel.layer.masksToBounds = true
    }

    private func setupLanguageButton() {
        languageButton.addTarget(self, action: #selector(changeLanguage), for: .touchUpInside)
    }

    @objc
    private func changeLanguage() {
        languageChanger.changeLanguage()
        gameInstance.changeLanguage()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func touchEnded() {
        if gameInstance.isGameInProgress {
            performSegue(withIdentifier: "Continue Segue", sender: nil)
        } else {
            performSegue(withIdentifier: "New Game Segue", sender: nil)
        }
    }
    
    func requiredTouchDurationReached() {
        if gameInstance.isGameInProgress {
            performSegue(withIdentifier: "New Game Segue", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tutorial" {
            guard let tutorialVC = segue.destination as? TutorialViewController else {
                return
            }
            tutorialVC.delegate = self
        }
    }
}

extension MenuController: UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate {
}

extension MenuController: TutorialDelegate {
    func openNewGame() {
        if let settingsViewController = self.storyboard?.instantiateViewController(withIdentifier: "settings") {
            navigationController?.pushViewController(settingsViewController, animated: true)
        }
    }
}
