//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by Shannon Coyne on 8/1/15.
//  Copyright (c) 2015 Shannon Coyne. All rights reserved.
//

import UIKit
import CoreData



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainVC:PomodoroViewController?
   


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
      
        
        // Register for notifications  註冊
        let categories = NotificationCategories.categories()
        let settings = UIUserNotificationSettings(forTypes: ([.Alert, .Badge, .Sound]), categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        if let viewControllers = self.window?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if viewController.isKindOfClass(PomodoroViewController) {
                    mainVC = viewController as! PomodoroViewController
                      // print("Found the view controller")
                }
            }
        }

        return true
    }
    
    // Handle tapping on a notification action 處理通知被按
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        if let action = identifier {
            if identifier == "PAUSE_ACTION" {
                mainVC!.startstop(false,notiPeer:true )
            } else if identifier == "STOP_ACTION" {
                mainVC!.closeCallback()
            }
        }
        completionHandler()
    }
    
    // Handle received notification  //處理收到通知
    //  - When app is in the FG, this will fire immediately
    //  - When app is in the BG, this will fire when user taps on the notification
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let category = notification.category {
            print("Received a local notification with category: \(category)")
        } else {
            print("Received a local notification without a category")
        }
    }
    
/*
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
*/

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.


    }

    
}

