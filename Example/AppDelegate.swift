//
//  AppDelegate.swift
//  Example
//
//  Created by Qiscus on 07/11/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import Foundation
import UserNotifications
import SwiftyJSON

let APP_ID : String = "sdksample"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        QiscusCore.enableDebugPrint = true
        QiscusCore.setup(WithAppID: APP_ID)
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        self.auth()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var tokenString: String = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("token = \(tokenString)")
        UserDefaults.standard.setDeviceToken(value: tokenString)
        if QiscusCore.isLogined {
            QiscusCore.shared.register(deviceToken: tokenString, onSuccess: { (response) in
                print("success register device token =\(tokenString)")
            }) { (error) in
                print("failed register device token = \(error.message)")
            }
        }
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("AppDelegate. didReceive: \(notification)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("AppDelegate. didReceiveRemoteNotification: \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("AppDelegate. didReceiveRemoteNotification2: \(userInfo)")
        
        //you can custom redirect to chatRoom
        
        let userInfoJson = JSON(arrayLiteral: userInfo)[0]
        if let payload = userInfo["payload"] as? [String: Any] {
            if let payloadData = payload["payload"] {
                let jsonPayload = JSON(arrayLiteral: payload)[0]
                
                let messageID = jsonPayload["id_str"].string ?? ""
                let roomID = jsonPayload["room_id_str"].string ?? ""
            
                if !messageID.isEmpty && !roomID.isEmpty{
                    QiscusCore.shared.updateCommentReceive(roomId: roomID, lastCommentReceivedId: messageID)
                }
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    // Auth
    func auth() {
        let target : UIViewController
        if QiscusCore.isLogined {
            target = UIChatListViewController()
            // QiscusUI.delegate = self
            _ = QiscusCore.connect(delegate: self)
        }else {
            target = LoginViewController()
        }
        let navbar = UINavigationController()
        navbar.viewControllers = [target]
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navbar
        self.window?.makeKeyAndVisible()
    }
    
    func registerDeviceToken(){
        if let deviceToken = UserDefaults.standard.getDeviceToken(){
            QiscusCore.shared.register(deviceToken: deviceToken, onSuccess: { (response) in
                print("success register device token =\(deviceToken)")
            }) { (error) in
                print("failed register device token = \(error.message)")
            }
        }
    }
}

extension AppDelegate : QiscusConnectionDelegate {
    func disconnect(withError err: QError?) {
        //
    }
    
    func connected() {
        //
    }
    
    func connectionState(change state: QiscusConnectionState) {
        //
    }
    
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]
