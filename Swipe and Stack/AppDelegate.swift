//
//  AppDelegate.swift
//  Swipe and Stack
//
//  Created by Alif on 15/01/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let vc = StackedCardViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }
}

