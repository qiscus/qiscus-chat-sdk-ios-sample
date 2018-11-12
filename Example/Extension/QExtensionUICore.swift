//
//  QBallon.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import Foundation
import QiscusUI
import QiscusCore
import SwiftyJSON

public enum QReplyType:Int{
    case text
    case image
    case video
    case audio
    case document
    case location
    case contact
    case file
    case other
}

extension UIBaseChatCell {
    
    open func getBallon()->UIImage?{
        var balloonImage:UIImage? = nil
        var edgeInset = UIEdgeInsetsMake(13, 13, 13, 28)
        
        if (self.comment?.isMyComment() == true){
            balloonImage = AssetsConfiguration.rightBallonLast
        }else{
            edgeInset = UIEdgeInsetsMake(13, 28, 13, 13)
            balloonImage = AssetsConfiguration.leftBallonLast
        }
        
        return balloonImage?.resizableImage(withCapInsets: edgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
}
