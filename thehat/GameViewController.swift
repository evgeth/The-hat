//
//  GameViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var listOfWords: [String]!
    @IBOutlet weak var wordLabel: UILabel!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listOfWords = ["мама", "абстракционизмабстракционизм", "любовь", "сияние", "анархия"]
        index = 0
        reloadWord()
    }
    
    func reloadWord() {
        wordLabel.text = listOfWords[index]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func errorButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            var scale = CABasicAnimation(keyPath: "transform.scale")
            scale.duration = 0.3
            scale.repeatCount = 1
            scale.autoreverses = true
            scale.toValue = NSNumber(float: 2.0)
           self.wordLabel.layer.addAnimation(scale, forKey: nil)
        })
    }
    

    @IBAction func guessed(sender: AnyObject) {
        index = index + 1
        index = index % listOfWords.count
        reloadWord()
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
