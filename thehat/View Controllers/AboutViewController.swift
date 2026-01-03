//
//  RulesViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 20/06/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import StoreKit
import SafariServices

final class AboutViewController: UITableViewController { //, SKProductsRequestDelegate {
    
    var productIDs = Set<String>()
    var productsArray: Array<SKProduct?> = []
    var productRequest: SKProductsRequest!
    
    var titles = [
        LS.localizedString(forKey: "social"),
        LS.localizedString(forKey: "developer")
    ]
    var rows: [[(String, String, String)]] = [
        [
            (LS.localizedString(forKey: "friends"), "share", "share"),
            (LS.localizedString(forKey: "rate"), "rate", "star")
        ],
        [
            (LS.localizedString(forKey: "yurtaev"), "https://t.me/yurtaev", "telegram")
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitleWithCustomFont(title: LS.localizedString(forKey: "ABOUT"))
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.logEvent("open_screen", parameters: ["screen_name": "Main Menu"])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = rows[indexPath.section][indexPath.row]
        switch obj.1 {
        case "share":
            let objectsToShare = ["https://itunes.apple.com/app/id1073529279"]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            // todo process the completion (thanks/ ads maybe)
            if (self.isIpad()) {
                let popup = UIPopoverController(contentViewController: activityVC)
                let currentCell = tableView.cellForRow(at: indexPath as IndexPath)
                popup.present(from: currentCell!.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            } else {
                self.present(activityVC, animated: true, completion: nil)
            }
        case "rate":
            if #available( iOS 10.3,*){
                SKStoreReviewController.requestReview()
            }
        case "":
            break
        default:
            let url = URL(string: obj.1)!
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(url: url as URL)
                self.present(svc, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
        Analytics.logEvent("about_action", parameters: ["action": obj.1])
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "About Cell") as! AboutTableViewCell
        let obj = rows[indexPath.section][indexPath.row]
        cell.label.text = obj.0
        if indexPath.section == 0 {
            let imgtitle = obj.2 + ".png"
            cell.img.image = UIImage(named: imgtitle)
        } else if obj.1 == "tip"  {
            cell.img.image = UIImage(named: "coffee.png")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
}
