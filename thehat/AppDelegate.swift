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

    // The window is owned by SceneDelegate (UIScene lifecycle).

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.

        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        Analytics.logEvent("app_started", parameters: ["lang": Locale.preferredLanguages[0]])

        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = AppColors.textSecondary
        pageControl.currentPageIndicatorTintColor = AppColors.textPrimary
        pageControl.backgroundColor = AppColors.background

        // Set navigation bar and bar button tint color
        UINavigationBar.appearance().tintColor = AppColors.primaryDark
        UIBarButtonItem.appearance().tintColor = AppColors.primaryDark

        // The global window tint is set in SceneDelegate, which owns the window.

        ScreenshotMode.applyIfRequested()

        return true
    }
}

