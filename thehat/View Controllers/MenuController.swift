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
            holdToStartLabel.text = languageChanger.localizedString(forKey: "hold_to_start_new_game")
        }
    }

    @IBOutlet weak var rulesLabel: UILabel! {
        didSet {
            rulesLabel.text = languageChanger.localizedString(forKey: "RULES")
        }
    }

    @IBOutlet weak var aboutLabel: UILabel! {
        didSet {
            aboutLabel.text = languageChanger.localizedString(forKey: "ABOUT")
        }
    }

    @IBOutlet weak var newGameView: ColorChangingView!
    @IBOutlet weak var languageButton: UIButton! {
        didSet {
            languageButton.setTitle(languageChanger.localizedString(forKey: "language"), for: .normal)
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
            newGameLabel.text = languageChanger.localizedString(forKey: "CONTINUE")
            newGameView.initializer(
                startColor: UIColor(r: 109, g: 236, b: 158, a: 80),
                finishColor: UIColor(r: 109, g: 250, b: 130, a: 90),
                requiredTouchDuration: 0.6, delegate: self
            )
        } else {
            holdToStartNewGameLabel.isHidden = true
            newGameLabel.text = languageChanger.localizedString(forKey: "NEW_GAME")
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
}

extension MenuController: UIPopoverPresentationControllerDelegate, ColorChangingViewDelegate {
}
