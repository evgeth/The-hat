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
    
    var descriptionText: String!
    var imageName: String!
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: imageName)
        descriptionLabel.text = descriptionText
        
//        imageView.layer.borderWidth = 1
//        imageView.layer.borderColor = UIColor(red: CGFloat(0), green: CGFloat(192.0 / 256.0), blue: 50.0 / 256.0, alpha: 0.9).CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
