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

//let APP_ID : String = "sdksample"
//let APP_ID : String = "dinosauru-nqmxcraaqm1"//stag
let APP_ID : String = "dinosauru-l88z1enpnz4"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        QiscusCoreManager.qiscusCore1.enableDebugMode(value : true)
        QiscusCoreManager.qiscusCore1.setup(AppID: "sdksample")
        QiscusCoreManager.qiscusCore2.setupWithCustomServer(AppID: "dragongo", baseUrl: URL(string: "https://dragongo.qiscus.com")!, brokerUrl: "mqtt.qiscus.com", brokerLBUrl: nil)
        QiscusCoreManager.qiscusCore2.enableDebugMode(value : true)
      // QiscusCore.setup(WithAppID: "dinosauru-nqmxcraaqm1", server: QiscusServer(url:URL(string: "https://qiscus-lb.stage.halodoc.com")!, realtimeURL: "qiscus-mqtt.stage.halodoc.com", realtimePort: 1885,brokerLBUrl: "https://qiscus-mqtt-lb.stage.halodoc.com"))
        //QiscusCore.setup(WithAppID: APP_ID, server: QiscusServer(url:URL(string: "https://qiscus-lb.stage.halodoc.com")!, realtimeURL: "qiscus-mqtt.stage.halodoc.com", realtimePort: 1885,brokerLBUrl: nil))
        
        //QiscusCore.setupWithCustomServer(AppID: APP_ID, baseUrl: URL(string: "https://qiscus-lb.stage.halodoc.com")!, brokerUrl: "qiscus-mqtt.stage.halodoc.com", brokerLBUrl: nil)an
        //QiscusCore.setupWithCustomServer(AppID: APP_ID, baseUrl: URL(string: "https://qiscus-lb.api.halodoc.com")!, brokerUrl: "qiscus-mqtt.api.halodoc.com", brokerLBUrl: nil)
        
       // QiscusCore.setup(WithAppID: "sdksample", server: QiscusServer(url:URL(string: "https://api.qiscus.com")!, realtimeURL: "mqtt.qiscus.com", realtimePort: 1885))
        //QiscusCore.setupWithCustomServer(AppID: "dragongo", baseUrl: URL(string: "https://dragongo.qiscus.com")!, brokerUrl: "mqtt.qiscus.com", brokerLBUrl: nil)
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
        
        // This is the workaround for Xcode 11.2
        //UITextViewWorkaround.unique.executeWorkaround()
        
//        let URL =  getDocumentsDirectory()
//        print("arief cek\(URL)")
        
        return true
    }
    
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
//
//
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var tokenString: String = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("token = \(tokenString)")
        UserDefaults.standard.setDeviceToken(value: tokenString)
        if QiscusCoreManager.qiscusCore1.hasSetupUser() {
            //change isDevelopment to false for production and true for development
            QiscusCoreManager.qiscusCore1.shared.registerDeviceToken(token: tokenString, onSuccess: { (response) in
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
                    QiscusCoreManager.qiscusCore1.shared.markAsDelivered(roomId: roomID, commentId: messageID)
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
        if QiscusCoreManager.qiscusCore1.hasSetupUser() {
            target = UIChatListViewController()
            _ = QiscusCoreManager.qiscusCore1.connect(delegate: self)
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
            //change isDevelopment to false for production and true for development
            QiscusCoreManager.qiscusCore1.shared.registerDeviceToken(token: deviceToken, onSuccess: { (success) in
                print("success register device token =\(deviceToken)")
            }) { (error) in
                print("failed register device token = \(error.message)")
            }
        }
    }
}

extension AppDelegate : QiscusConnectionDelegate {
    func onConnected(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reSubscribeRoom"), object: nil)
    }
    func onReconnecting(){
        
    }
    func onDisconnected(withError err: QError?){
        
    }
    
    func connectionState(change state: QiscusConnectionState) {
        if (state == .disconnected){
            var roomsId = [String]()
            
            let rooms = QiscusCoreManager.qiscusCore1.database.room.all()
            
            if rooms.count != 0{
                
                for room in rooms {
                    roomsId.append(room.id)
                }
                
                QiscusCoreManager.qiscusCore1.shared.getChatRooms(roomIds: roomsId, showRemoved: false, showParticipant: true, onSuccess: { (rooms) in
                    //brodcast rooms to your update ui ex in ui listRoom
                }, onError: { (error) in
                    print("error = \(error.message)")
                })
                
            }
            
        }
        
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
//// [END ios_10_message_handling]
//
////******************************************************************
//// MARK: - Workaround for the Xcode 11.2 bug
////******************************************************************
//class UITextViewWorkaround: NSObject {
//
//    // --------------------------------------------------------------------
//    // MARK: Singleton
//    // --------------------------------------------------------------------
//    // make it a singleton
//    static let unique = UITextViewWorkaround()
//
//    // --------------------------------------------------------------------
//    // MARK: executeWorkaround()
//    // --------------------------------------------------------------------
//    func executeWorkaround() {
//
//        if #available(iOS 13.2, *) {
//
//            NSLog("UITextViewWorkaround.unique.executeWorkaround(): we are on iOS 13.2+ no need for a workaround")
//
//        } else {
//
//            // name of the missing class stub
//            let className = "_UITextLayoutView"
//
//            // try to get the class
//            var cls = objc_getClass(className)
//
//            // check if class is available
//            if cls == nil {
//
//                // it's not available, so create a replacement and register it
//                cls = objc_allocateClassPair(UIView.self, className, 0)
//                objc_registerClassPair(cls as! AnyClass)
//
//                #if DEBUG
//                NSLog("UITextViewWorkaround.unique.executeWorkaround(): added \(className) dynamically")
//               #endif
//           }
//        }
//    }
//}
