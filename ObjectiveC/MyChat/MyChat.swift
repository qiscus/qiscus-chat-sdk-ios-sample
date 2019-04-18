//
//  MyChat.swift
//  MyChat
//
//  Created by Qiscus on 22/11/18.
//

import Foundation
import QiscusCore

@objc public class MyChat : NSObject {
    @objc public static let shared : MyChat = MyChat()
    class var bundle:Bundle{
        get{
            let podBundle = Bundle(for: MyChat.self)
            if let bundleURL = podBundle.url(forResource: "MyChat", withExtension: "bundle") {
                return Bundle(url: bundleURL)!
            }else{
                return podBundle
            }
        }
    }
    
    @objc public static func isLogined() -> Bool {
        QiscusCore.enableDebugPrint = true
        return QiscusCore.isLogined
    }
    
    
    @objc public func setup(withAppId appId:String) {
        QiscusCore.setup(WithAppID: appId)
        // enable debug log
        QiscusCore.enableDebugPrint = true
    }
    
    
    @objc public func setup(withAppId appId:String, userEmail:String, userKey:String, username:String, avatarURL:String? = nil, extras:[String: Any]? = nil) {
        QiscusCore.setup(WithAppID: appId)
        let url = URL(string: avatarURL ?? "http://")
        QiscusCore.loginOrRegister(userID: userEmail, userKey: userKey,username: username, avatarURL: url, extras: extras, onSuccess: { (userModel) in
            // when login success
            print(userModel)
        }) { (error) in
            // when login error
        }
        // enable debug log
        QiscusCore.enableDebugPrint = true
    }
    
    
    @objc public func chat(withUser user: String) {
        if !QiscusCore.isLogined{
            return
        }else{
            QiscusCore.connect()
        }
        
        QiscusCore.shared.getRoom(withUser: user, onSuccess: { (room, comments) in
            let vc = UIChatViewController()
            vc.room = room
            UIApplication.currentViewController()?.navigationController?.pushViewController(vc, animated: true)
        }) { (error) in
            
            print("error chat: \(error.message)")
        }
    }
    
    
    /// Post Message by room id
    ///
    /// - Parameters:
    ///   - roomID: room id
    ///   - message: message text
    ///   - extras: extra data
    @objc public func postMessage(roomID: String, message: String, extras: [String:Any]?) {
        let comment         = CommentModel()
        comment.message     = message
        comment.extras      = extras
        comment.type        = "text"
        
        QiscusCore.shared.sendMessage(roomID: roomID, comment: comment, onSuccess: { (results) in
            //
        }) { (error) in
            //
        }
    }
    
    @objc public func postMessage(user: String, message: String, extras: [String:Any]?) {
        QiscusCore.shared.getRoom(withUser: user, onSuccess: { (room, comments) in
            // 
            MyChat.shared.postMessage(roomID: room.id, message: message, extras: extras)
        }) { (error) in
            //
        }
    }
    
    @objc public func clearMessage(roomID: String) {
        QiscusCore.shared.deleteAllMessage(roomID: [roomID]) { (error) in
            if let message = error?.message {
                print("error \(message)")
            }else {
                // success
            }
        }
    }
    
    @objc public func clearMessage(withUser user: String) {
        QiscusCore.shared.getRoom(withUser: user, onSuccess: { (room, comments) in
            MyChat.shared.clearMessage(roomID: room.id)
        }) { (error) in
            //
        }
    }
    
    @objc public func logout() {
        QiscusCore.logout { (error) in
            if let message = error?.message {
                print("error logout \(message)")
            }
        }
    }
}

public extension UIApplication {
    
    // Get current view controller
    public class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if NSClassFromString("HaloDoc.AppRootViewController") != nil && (base?.isKind(of: NSClassFromString("HaloDoc.AppRootViewController")!)) == true {
            if let root = base?.value(forKey: "tabController") as? UIViewController {
                return currentViewController(base:root)
            }
        }
        
        if NSClassFromString("HDDoctor.HDDAppTabRootViewController") != nil && (base?.isKind(of: NSClassFromString("HDDoctor.HDDAppTabRootViewController")!)) == true {
            if let root = base?.value(forKey: "appRootVC") as? UIViewController {
                return currentViewController(base:root)
            }
        }
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
    
    public class func topNavigationController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if NSClassFromString("HaloDoc.AppRootViewController") != nil && (base?.isKind(of: NSClassFromString("HaloDoc.AppRootViewController")!)) == true {
            if let root = base?.value(forKey: "tabController") as? UIViewController {
                print("TOP VC Navigation TOP 1 > \(root)")
                return topNavigationController(base:root)
            }
        }
        
        if NSClassFromString("HDDoctor.HDDAppTabRootViewController") != nil && (base?.isKind(of: NSClassFromString("HDDoctor.HDDAppTabRootViewController")!)) == true {
            if let root = base?.value(forKey: "appRootVC") as? UIViewController {
                print("TOP VC Navigation TOP 2 > \(root)")
                return topNavigationController(base:root)
            }
        }
        
        if let nav = base as? UINavigationController {
            print("TOP VC Navigation TOP 3 > \(nav)")
            return topNavigationController(base: nav.topViewController)
        }
        
        if let tab = base as? UITabBarController {
            print("TOP VC Navigation TOP 4 > \(tab)")
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                print("TOP VC Navigation TOP 5 > \(top)")
                return topNavigationController(base: top)
            } else if let selected = tab.selectedViewController {
                print("TOP VC Navigation TOP 6 > \(selected)")
                return topNavigationController(base: selected)
            }
        }
        
        return base
    }
    
    //Only for doctor app.
    public class func isTabBarPresent(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> Bool{
        
        if NSClassFromString("HDDoctor.HDDAppTabRootViewController") != nil && (base?.isKind(of: NSClassFromString("HDDoctor.HDDAppTabRootViewController")!)) == true {
            if let _ = base?.value(forKey: "appRootVC") as? UIViewController {
                return true
            }
        }
        
        if let nav = base as? UINavigationController {
            return isTabBarPresent(base: nav.visibleViewController)
        }
        
        if let presented = base?.presentedViewController {
            return isTabBarPresent(base: presented)
        }
        
        return false
    }
}

