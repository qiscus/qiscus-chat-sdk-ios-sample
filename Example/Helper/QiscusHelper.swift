//
//  QiscusHelper.swift
//  QiscusSDK
//
//  Created by Qiscus on 7/22/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

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
}
