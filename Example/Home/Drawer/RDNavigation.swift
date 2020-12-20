//
//  RDNavigation.swift
//  Full Scale
//
//  Created by Randolf Dini-ay on 15/03/2019.
//  Copyright © 2019 Randolf Dini-ay. All rights reserved.
//

import UIKit

public protocol RDNavigation { 
    
    static var isOpen:Bool { get }
    
    static func right(target: Any?, view: UIView, percentage: CGFloat, isTopMost: Bool)
    
    static func left(target: Any?, view: UIView, percentage: CGFloat, isTopMost: Bool)
    
    static func sideToggle()
    
    static func sideToggleWithPercentage(_ percentage: CGFloat)
    
    static func requireGestureRecognizerToFail(_ gesture: UIGestureRecognizer?)
    
    static func allowGestures(_ value: Bool)
    
    static func allowOpeningGesture(_ value: Bool)
    
    static func allowClosingGesture(_ value: Bool)
    
    static func enable(_ value: Bool)
    
    static func topMost()
}
