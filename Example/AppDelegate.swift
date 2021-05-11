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
import Alamofire
import Firebase
import FirebaseCrashlytics
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var timer : Timer?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        FirebaseApp.configure()
        
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        let defaults = UserDefaults.standard
        defaults.setValue(0, forKey: "lastTab")
        defaults.removeObject(forKey: "lastSelectedListRoom")
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
        if QiscusCore.isLogined{
            QiscusCore.connect()
            setupReachability()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    func setupReachability(){
        QiscusCore.shared.reachability = QiscusReachability()
        
      
        QiscusCore.shared.reachability?.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                   //print("connected via wifi")
                } else {
                    //print("connected via cellular data")
                }
                
                if reachability.isReachable {
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "hasInternet")
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "stableConnection"), object: nil)
                    
                }
               
            }
            
        }
        QiscusCore.shared.reachability?.whenUnreachable = { reachability in
            //print("no internet connection")
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "hasInternet")
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
        }
        do {
            try   QiscusCore.shared.reachability?.startNotifier()
        } catch {
           // print("Unable to start network notifier")
        }
    }
    
    func heartBeat(){
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkApi), userInfo: nil, repeats: true)
       
    }
    
    @objc func checkApi() {
        let startDate = Date()
        QiscusCore.shared.synchronize { (comments) in
            let now = startDate
            
            let currentDate = Date()
            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: currentDate)
            let seconds = diffComponents.second ?? 0
            
            if seconds >= 5 {
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "hasInternet")
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
            }else{
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "hasInternet")
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "stableConnection"), object: nil)
            }
        } onError: { (error) in
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "hasInternet")
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unStableConnection"), object: nil)
        }

    }
    
    // Auth
    func auth() {
        QiscusCore.enableDebugPrint = true
        let target : UIViewController
        if QiscusCore.isLogined {
           
            if let appID = UserDefaults.standard.getAppID(){
                QiscusCore.setup(WithAppID: appID)
            }
            target = HomeVC()//UIChatTabViewController()//UIChatListViewController()
            _ = QiscusCore.connect(delegate: self)
            DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
                self.setupReachability()
                self.heartBeat()
            })
           
        }else {
            var defaults = UserDefaults.standard
            defaults.removeObject(forKey: "filter")
            defaults.removeObject(forKey: "filterTag")
            defaults.removeObject(forKey: "filterAgent")
            defaults.removeObject(forKey: "filterSelectedTypeWA")
            defaults.removeObject(forKey: "lastSelectedListRoom")
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
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
    
    func validateUserToken(appId :String,identityToken :String, qismo_key : String){
        UserDefaults.standard.setAppID(value: appId)
        QiscusCore.setup(WithAppID: appId)
        
        QiscusCore.login(withIdentityToken: identityToken, onSuccess: { (user) in
            
            let header = ["Authorization": user.token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
            
            let params = ["app_id": appId,
                          "qismo_key": qismo_key] as [String : Any]
            
            
            Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/auth/get_token_by_qismo_key", method: .post, parameters: params, headers: header as! HTTPHeaders).responseJSON { (response) in
                print("response call \(response)")
                if response.result.value != nil {
                    if (response.response?.statusCode)! >= 300 {
                        //failed
                    } else {
                        //success
                        
                        let result = response.result.value
                        let json = JSON(result)
                        print("check json ini =\(json)")
                        
                        let token = json["data"]["authentication_token"].stringValue
                        let userType = json["data"]["type"].intValue
                        let bubbleColor = json["data"]["bubble_color"].stringValue
                        
                        UserDefaults.standard.setBubbleColor(value: bubbleColor)
                        UserDefaults.standard.setAfterLogin(value: true)
                        
                        self.auth()
                        
                        self.registerDeviceToken()
                       
                    }
                } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                    //failed
                } else {
                    //failed
                }
            }
        }) { (error) in
            self.auth()
        }
    }
}

extension AppDelegate : QiscusConnectionDelegate {
    func connectionState(change state: QiscusConnectionState) {
        
    }
    
    func onConnected() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reSubscribeRoom"), object: nil)
    }
    
    func onReconnecting() {
        
    }
    
    func onDisconnected(withError err: QError?) {
        var roomsId = [String]()
        
        let rooms = QiscusCore.database.room.all()
        
        if rooms.count != 0{
            
            for room in rooms {
                roomsId.append(room.id)
            }
            
            QiscusCore.shared.getRooms(withId: roomsId, onSuccess: { (rooms) in
                //brodcast rooms to your update ui ex in ui listRoom
            }) { (error) in
                print("error = \(error.message)")
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
// [END ios_10_message_handling]
