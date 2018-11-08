//
//  QiscusHelper.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 7/22/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class QIndexPathData: NSObject{
    open var row = 0
    open var section = 0
    open var newGroup:Bool = false
}
open class QiscusSearchIndexPathData{
    open var row = 0
    open var section = 0
    open var found:Bool = false
}
open class QCommentIndexPath{
    open var row = 0
    open var section = 0
}
open class QiscusHelper: NSObject {
    class func screenWidth()->CGFloat{
        return UIScreen.main.bounds.size.width
    }
    class func screenHeight()->CGFloat{
        return UIScreen.main.bounds.size.height
    }
    class func statusBarSize()->CGRect{
        return UIApplication.shared.statusBarFrame
    }
    class var thisDateString:String{
        get{
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            
            return dateFormatter.string(from: date)
        }
    }
    open class func getFirstLinkInString(text:String)->String?{
        let pattern = "((?:http|https)://)?(?:www\\.)?([a-zA-Z0-9./]+[.][a-zA-Z0-9/]{2,3})+([a-zA-Z0-9./-]+)?((\\?)+[a-zA-Z0-9./-_&]*)*"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = text as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var matches = [String]()
            regex.enumerateMatches(in: text, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: all, using: { (result, flags, _) in
                matches.append(nsstr.substring(with: result!.range))
            })
            if matches.count > 0 {
                return matches[0]
            }else{
                return nil
            }
        } catch {
            return nil
        }
    }
    
    open class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension Date {
    var isToday:Bool{
        get{
            if Calendar.current.isDateInToday(self){
                return true
            }
            return false
        }
    }
    var isYesterday:Bool{
        get{
            if Calendar.current.isDateInYesterday(self){
                return true
            }
            return false
        }
    }
    func offsetFromInSecond(date:Date) -> Int{
        let differerence = Calendar.current.dateComponents([.second], from: date, to: self)
        if let secondDiff = differerence.second{
            return secondDiff
        }else{
            return 0
        }
    }
    func offsetFromInMinutes(date:Date) -> Int{
        let differerence = Calendar.current.dateComponents([.minute], from: date, to: self)
        if let minuteDiff = differerence.minute{
            return minuteDiff
        }else{
            return 0
        }
    }
    
    func offsetFromInDay(date:Date)->Int{
        let differerence = Calendar.current.dateComponents([.day], from: self, to: date)
        if let dayDiff = differerence.day{
            return dayDiff
        }else{
            return 0
        }
    }
    
    
}
