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

class AboutViewController: UITableViewController, SKProductsRequestDelegate {
    
    var productIDs = Set<String>()
    var productsArray: Array<SKProduct!> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setNavigationBarTitleWithCustomFont(NSLocalizedString("ABOUT", comment: "About"))
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

        productIDs.insert("com.dpfbop.thehat.donation")
        requestProductInfo()
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
        }
        else {
            print("There are no products.")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let payment = SKPayment(product: self.productsArray[0] as SKProduct)
        SKPaymentQueue.defaultQueue().addPayment(payment)
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
                
                
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed");
                print(transaction.error)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }

}
