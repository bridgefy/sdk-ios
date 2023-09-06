//
//  AppDelegate.swift
//  Alerts
//
//  Created by Francisco on 05/09/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let customRedColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        UINavigationBar.appearance().tintColor = customRedColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:customRedColor]
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BridgefyManager.shared.stop()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        BridgefyManager.shared.start()
    }


}

