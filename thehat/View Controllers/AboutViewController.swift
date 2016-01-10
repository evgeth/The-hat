//
//  RulesViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 20/06/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Crashlytics

class AboutViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setNavigationBarTitleWithCustomFont(NSLocalizedString("ABOUT", comment: "About"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        Answers.logCustomEventWithName("Open Screen", customAttributes: ["Screen name": "Main Menu"])
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
