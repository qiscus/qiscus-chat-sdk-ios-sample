//
//  CustomChatNavigation.swift
//  Example
//
//  Created by Qiscus on 26/11/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import QiscusUI
import QiscusCore

class CustomChatNavigation : UIChatNavigation {
    
    @IBOutlet weak var _labelSubtitle: UILabel!
    @IBOutlet weak var _labelTitle: UILabel!
    
    override func commonInit(nib: UINib) {
        let nib = UINib(nibName: "CustomChatNavigation", bundle: nil)
        super.commonInit(nib: nib)
    }
    
    override func present(room: RoomModel) {
        self._labelTitle.text = room.name
        self._labelSubtitle.text    = ""
    }
}
