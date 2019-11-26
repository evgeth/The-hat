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

class AboutViewController: UITableViewController { //, SKProductsRequestDelegate {
    
    var productIDs = Set<String>()
    var productsArray: Array<SKProduct?> = []
    var productRequest: SKProductsRequest!
    
    var titles = [NSLocalizedString("Social", comment: "Social"),
                NSLocalizedString("developer", comment: "developer"),
                NSLocalizedString("thanks", comment: "thanks")]
    var rows: [[(String, String)]] = [
//        [(NSLocalizedString("facebook", comment: "facebook"), "https://www.facebook.com/thehatgameofwords/"),
            [(NSLocalizedString("vk", comment: "vk"), "https://vk.com/club111664652"),
            (NSLocalizedString("friends", comment: "tell friends"), "share"),
            (NSLocalizedString("rate", comment: "rate"), "rate")],
        [(NSLocalizedString("yurtaev", comment: "yurtaev"), "https://vk.com/id17890829")],
        [(NSLocalizedString("koroleva", comment: "koroleva"), "https://vk.com/id81679642"),
            (NSLocalizedString("emelin", comment: "emelin"), "https://vk.com/id24027100"),
            (NSLocalizedString("lksh", comment: "lskh"), "http://lksh.ru")]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setNavigationBarTitleWithCustomFont(title: NSLocalizedString("ABOUT", comment: "About"))
        
//        SKPaymentQueue.default().add(self)
//        productIDs.insert("com.dpfbop.thehat.coffee")
//        requestProductInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        SKPaymentQueue.default().remove(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            var imgtitle = ""
            switch indexPath.row {
            case 0:
                imgtitle = "vk.png"
            case 1:
                imgtitle = "share.png"
            case 2:
                imgtitle = "star.png"
            default:
                break
            }
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
