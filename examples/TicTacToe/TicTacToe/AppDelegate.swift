//
//  AppDelegate.swift
//  TicTacToe
//
//  Created by Francisco on 06/09/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        UINavigationBar.appearance().tintColor = APP_RED_COLOR
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:APP_RED_COLOR]
        UITabBar.appearance().tintColor = APP_RED_COLOR
        UIButton.appearance().tintColor = APP_RED_COLOR
        
        window?.overrideUserInterfaceStyle = .light
    
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BridgefyManager.shared.bridgefy?.stop()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        BridgefyManager.shared.bridgefy?.start()
    }


}

