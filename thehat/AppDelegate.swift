//
//  AppDelegate.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        Answers.logCustomEvent(withName: "App started", customAttributes: ["lang": Locale.preferredLanguages[0]])

        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor.white
        return true
    }

    func initRootView(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootController: UINavigationController? = storyboard.instantiateViewController(withIdentifier: "appNavigationController") as? UINavigationController

        window?.rootViewController = rootController
    }
}

