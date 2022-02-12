//
//  RulesViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 20/06/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Crashlytics
import StoreKit
import SafariServices

final class AboutViewController: UITableViewController { //, SKProductsRequestDelegate {
    
    var productIDs = Set<String>()
    var productsArray: Array<SKProduct?> = []
    var productRequest: SKProductsRequest!
    
    var titles = [
        LS.localizedString(forKey: "social"),
        LS.localizedString(forKey: "developer"),
        LS.localizedString(forKey: "thanks")
    ]
    var rows: [[(String, String, String)]] = [
        [
            (LS.localizedString(forKey: "vk"), "https://vk.com/club111664652", "vk"),
            (LS.localizedString(forKey: "telegram"), "https://t.me/thehatapp", "telegram"),
            (LS.localizedString(forKey: "friends"), "share", "share"),
            (LS.localizedString(forKey: "rate"), "rate", "star")
        ],
        [
            (LS.localizedString(forKey: "yurtaev"), "https://t.me/yurtaev", "telegram")
        ],
        [
            (LS.localizedString(forKey: "koroleva"), "https://vk.com/id81679642", "vk"),
            (LS.localizedString(forKey: "emelin"), "https://vk.com/id24027100", "vk"),
            (LS.localizedString(forKey: "lksh"), "http://lksh.ru", "")
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarTitleWithCustomFont(title: LS.localizedString(forKey: "ABOUT"))
        
        //        SKPaymentQueue.default().add(self)
        //        productIDs.insert("com.dpfbop.thehat.coffee")
        //        requestProductInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //        SKPaymentQueue.default().remove(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        Answers.logCustomEvent(withName: "Open Screen", customAttributes: ["Screen name": "Main Menu"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        productRequest.delegate = nil
        //        productRequest.cancel()
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
        Answers.logCustomEvent(withName: "About action", customAttributes: ["Action": obj.1])
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

//extension AboutViewController: SKPaymentTransactionObserver {
//
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case SKPaymentTransactionState.purchased:
//                print("Transaction completed successfully.")
//                SKPaymentQueue.default().finishTransaction(transaction)
////                delegate.didBuyColorsCollection(selectedProductIndex)
//                Answers.logCustomEvent(withName: "Coffee", customAttributes: ["Status": "Complete"])
//
//
//            case SKPaymentTransactionState.failed:
//                print("Transaction Failed");
////                print(transaction.error)
//                SKPaymentQueue.default().finishTransaction(transaction)
//                Answers.logCustomEvent(withName: "Coffee", customAttributes: ["Status": "Failed"])
//            default:
//                print(transaction.transactionState.rawValue)
//            }
//        }
//    }
//
//}
