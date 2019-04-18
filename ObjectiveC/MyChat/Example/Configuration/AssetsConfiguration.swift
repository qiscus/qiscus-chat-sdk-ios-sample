//
//  QiscusAssetsConfiguration.swift
//  Example
//
//  Created by Ahmad Athaullah on 5/9/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit


class AssetsConfiguration: NSObject {
    
    var emptyChat:UIImage = UIImage().image(named: "empty-chat")!.withRenderingMode(.alwaysTemplate)
    
    // MARK: - Chat balloon
    static var leftBallonLast:UIImage? = UIImage().image(named: "text_balloon_last_l")
    static var leftBallonNormal:UIImage? = UIImage().image(named: "text_balloon_left")
    static var rightBallonLast:UIImage? = UIImage().image(named: "text_balloon_last_r")
    static var rightBallonNormal:UIImage? = UIImage().image(named: "text_balloon_right")
    static var backgroundChat:UIImage? = UIImage().image(named: "chat_bg")
}

