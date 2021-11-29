//
//  AppDelegate.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/17/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var shortcutItemToProcess: UIApplicationShortcutItem? = nil
        
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
            print("Shortcut pressed")
        }
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
