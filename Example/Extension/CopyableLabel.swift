//
//  CopyableLabel.swift
//  Example
//
//  Created by arief nur putranto on 01/11/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import Foundation
import UIKit

class CopyableLabel: UILabel {

    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        if #available(iOS 13.0, *) {
            UIMenuController.shared.hideMenu(from: self)
        } else {
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
    }

    @objc func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            if #available(iOS 13.0, *) {
                UIMenuController.shared.showMenu(from: self, rect: bounds)
            } else {
                menu.setTargetRect(bounds, in: self)
                menu.setMenuVisible(true, animated: true)
            }
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }

        return false
    }
}
