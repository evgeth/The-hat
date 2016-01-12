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

class AboutViewController: UITableViewController, SKProductsRequestDelegate {
    
    var productIDs = Set<String>()
    var productsArray: Array<SKProduct!> = []
    
    var titles = [NSLocalizedString("Social", comment: "Social"),
                NSLocalizedString("developer", comment: "developer"),
                NSLocalizedString("thanks", comment: "thanks")]
    var rows: [[(String, String)]] = [
        [(NSLocalizedString("facebook", comment: "facebook"), "https://www.facebook.com/thehatgameofwords/"),
            (NSLocalizedString("vk", comment: "vk"), "https://vk.com/club111664652"),
            (NSLocalizedString("friends", comment: "tell friends"), "share"),
            (NSLocalizedString("rate", comment: "rate"), "rate")],
        [(NSLocalizedString("yurtaev", comment: "yurtaev"), "https://vk.com/id17890829")],
        [(NSLocalizedString("koroleva", comment: "koroleva"), "https://vk.com/id81679642"),
            (NSLocalizedString("emelin", comment: "emelin"), "https://vk.com/id24027100"),
            (NSLocalizedString("lksh", comment: "lskh"), "http://lksh.ru")]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setNavigationBarTitleWithCustomFont(NSLocalizedString("ABOUT", comment: "About"))
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

        productIDs.insert("com.dpfbop.thehat.coffee")
        requestProductInfo()
    }
    
    override func viewDidDisappear(animated: Bool) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        Answers.logCustomEventWithName("Open Screen", customAttributes: ["Screen name": "Main Menu"])
    }
    
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productRequest = SKProductsRequest(productIdentifiers: productIDs)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
                print(product)
            }
            titles.insert(NSLocalizedString("tip", comment: "tip"), atIndex: 2)
            rows.insert([(NSLocalizedString("coffee", comment: "coffee"), "tip")], atIndex: 2)
            tableView.insertSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        else {
            print("There are no products.")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let obj = rows[indexPath.section][indexPath.row]
        switch obj.1 {
        case "share":
            let objectsToShare = ["https://itunes.apple.com/app/id1073529279"]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            // todo process the completion (thanks/ ads maybe)
            if (self.isIpad()) {
                let popup = UIPopoverController(contentViewController: activityVC)
                let currentCell = tableView.cellForRowAtIndexPath(indexPath)
                popup.presentPopoverFromRect(currentCell!.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            } else {
                self.presentViewController(activityVC, animated: true, completion: nil)
        }
        case "rate":
            let link = "itms-apps://itunes.apple.com/app/id1073529279"
            UIApplication.sharedApplication().openURL(NSURL(string: link)!)
        case "":
            break
        case "tip":
            let payment = SKPayment(product: self.productsArray[0] as SKProduct)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        default:
            let url = NSURL(string: obj.1)!
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(URL: url)
                self.presentViewController(svc, animated: true, completion: nil)
            } else {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        Answers.logCustomEventWithName("About action", customAttributes: ["Action": obj.1])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("About Cell") as! AboutTableViewCell
        let obj = rows[indexPath.section][indexPath.row]
        cell.label.text = obj.0
        if indexPath.section == 0 {
            var imgtitle = ""
            switch indexPath.row {
            case 0:
                imgtitle = "facebook.png"
            case 1:
                imgtitle = "vk.png"
            case 2:
                imgtitle = "share.png"
            case 3:
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titles.count
    }
    
}

extension AboutViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
//                delegate.didBuyColorsCollection(selectedProductIndex)
                Answers.logCustomEventWithName("Coffee", customAttributes: ["Status": "Complete"])
                
                
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed");
                print(transaction.error)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                Answers.logCustomEventWithName("Coffee", customAttributes: ["Status": "Failed"])
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }

}
