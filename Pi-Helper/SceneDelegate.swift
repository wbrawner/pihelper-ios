//
//  SceneDelegate.swift
//  Pi-Helper
//
//  Created by Billy Brawner on 10/17/19.
//  Copyright © 2019 William Brawner. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var dataStore: PiHoleDataStore?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        self.dataStore = PiHoleDataStore()
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(self.dataStore!)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        /*

         */
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Is there a shortcut item that has not yet been processed?
        if let shortcutItem = (UIApplication.shared.delegate as! AppDelegate).shortcutItemToProcess {
            if shortcutItem.type == ShortcutAction.enable.rawValue {
                self.dataStore?.enable()
            } else {
                let amount = shortcutItem.userInfo?["forSeconds"] as? Int
                self.dataStore?.disable(amount)
            }

            // Reset the shorcut item so it's never processed twice.
            (UIApplication.shared.delegate as! AppDelegate).shortcutItemToProcess = nil
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
        
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // When the user opens the app through a quick action, this is now the method that will be called
        (UIApplication.shared.delegate as! AppDelegate).shortcutItemToProcess = shortcutItem
    }
}

