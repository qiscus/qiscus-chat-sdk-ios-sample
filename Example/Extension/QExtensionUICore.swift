//
//  QBallon.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import Foundation

import QiscusCore
import SwiftyJSON

enum QReplyType:Int{
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
    
    func getBallon()->UIImage?{
        var balloonImage:UIImage? = nil
        var edgeInset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)

        if (self.comment?.isMyComment() == true){
            balloonImage = AssetsConfiguration.rightBallonLast
        }else{
            edgeInset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
            balloonImage = AssetsConfiguration.rightBallonLast
        }
        
        return balloonImage?.resizableImage(withCapInsets: edgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
}

extension StringProtocol {
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}
