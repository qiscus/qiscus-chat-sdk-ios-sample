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
    
    class func getBaseURL()->String{
        return getBaseURLProd()
    }
    
    private class func getBaseURLStag()->String{
        return "https://qismo-stag.qiscus.com"
    }
    
    private class func getBaseURLProd()->String{
        return "https://multichannel.qiscus.com"
    }
    private class func getBaseURLQismoProd()->String{
        return "https://qismo.qiscus.com"
    }
}
