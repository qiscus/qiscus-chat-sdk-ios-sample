//
//  QBallon.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import Foundation

import QiscusCore
import SwiftyJSON
import UIKit

extension UIBaseChatCell {
    
    func getBallon()->UIImage?{
        var balloonImage:UIImage? = nil
        var edgeInset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 28)
        
        if (self.comment?.isMyComment() == true){
            balloonImage = AssetsConfiguration.rightBallonLast
        }else{
            edgeInset = UIEdgeInsets(top: 13, left: 28, bottom: 13, right: 13)
            balloonImage = AssetsConfiguration.leftBallonLast
        }
        
        return balloonImage?.resizableImage(withCapInsets: edgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
}
