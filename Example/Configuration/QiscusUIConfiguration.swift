//
//  UIConfiguration.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 8/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit


/// Qiscus ui style configuration
class UIConfiguration: NSObject {
    var copyright = QiscusTextConfiguration.sharedInstance

    static var chatFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body){
        didSet{
            if chatFont.pointSize != UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).pointSize{
                if chatFont.fontName != UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).fontName {
                    
                }
            }
        }
    }

    static var chatTextMaxWidth:CGFloat = 0.7 * QiscusHelper.screenWidth()
    static var baseColor:UIColor{
        get{
            return ColorConfiguration.topColor
        }
    }
    fileprivate override init() {}
}
