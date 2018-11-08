//
//  QiscusUIConfiguration.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 8/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit


/// Qiscus ui style configuration
open class QiscusUIConfiguration: NSObject {
    static var sharedInstance = QiscusUIConfiguration()
    
    open var color = ColorConfiguration
    open var copyright = QiscusTextConfiguration.sharedInstance
    public var assets = QiscusAssetsConfiguration.shared
    
    open var chatFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body){
        didSet{
            if chatFont.pointSize != UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).pointSize{
                if chatFont.fontName != UIFont.preferredFont(forTextStyle: UIFontTextStyle.body).fontName {
                    rewriteChatFont = true
                }
            }
        }
    }
    
    public var rewriteChatFont = false
    
    
    /// To set read only or not, Default value : false
    open var readOnly = false
    
    static var chatTextMaxWidth:CGFloat = 0.7 * QiscusHelper.screenWidth()
    open var topicId:Int = 0
    open var chatUsers:[String] = [String]()
    open var baseColor:UIColor{
        get{
            return self.color.topColor
        }
    }
    fileprivate override init() {}
    
    /// Class function to set default style
    open func defaultStyle(){
        let defaultUIStyle = QiscusUIConfiguration()
        QiscusUIConfiguration.sharedInstance = defaultUIStyle
    }
}
