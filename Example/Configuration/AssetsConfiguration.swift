//
//  QiscusAssetsConfiguration.swift
//  Example
//
//  Created by Ahmad Athaullah on 5/9/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit


class AssetsConfiguration: NSObject {
    
    var emptyChat:UIImage = UIImage(named: "empty-chat")!.withRenderingMode(.alwaysTemplate)
    
    // MARK: - Chat balloon
    static var leftBallonLast:UIImage? = UIImage(named: "ic_buble_left")
    static var leftBallonNormal:UIImage? = UIImage(named: "ic_buble_left")
    static var rightBallonLast:UIImage? = UIImage(named: "ic_buble_right")
    static var rightBallonNormal:UIImage? = UIImage(named: "ic_buble_right")
    static var backgroundChat:UIImage? = UIImage(named: "chat_bg")
}

