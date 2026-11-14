//
//  AppDelegate.swift
//  thehat
//
//  Created by Eugene Yurtaev on 19/04/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.

        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        Analytics.logEvent("app_started", parameters: ["lang": Locale.preferredLanguages[0]])

        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = AppColors.textSecondary.withAlphaComponent(0.48)
        pageControl.currentPageIndicatorTintColor = AppColors.primaryDark
        pageControl.backgroundColor = AppColors.background

        // Set navigation bar and bar button tint color
        UINavigationBar.appearance().tintColor = AppColors.primaryDark
        UIBarButtonItem.appearance().tintColor = AppColors.primaryDark

        // Set global tint color
        if let window = window {
            window.tintColor = AppColors.primaryDark
        }

        if #available(iOS 13.0, *) {
            // The scene owns the window and applies screenshot setup once it connects.
        } else {
            ScreenshotMode.applyIfRequested()
        }

        return true
    }

    func initRootView(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootController: UINavigationController? = storyboard.instantiateViewController(withIdentifier: "appNavigationController") as? UINavigationController

        window?.rootViewController = rootController
    }
}

@available(iOS 13.0, *)
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene, let window = window else { return }
        window.tintColor = AppColors.primaryDark
        // Keep the existing language switch and screenshot paths on the same window.
        (UIApplication.shared.delegate as? AppDelegate)?.window = window
        ScreenshotMode.applyIfRequested()
    }
}

