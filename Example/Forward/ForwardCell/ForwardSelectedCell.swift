//
//  ForwardSelectedCell.swift
//  Example
//
//  Created by Qiscus on 04/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

class ForwardSelectedCell: UICollectionViewCell {
    
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var data : RoomModel? {
        didSet {
            if data != nil {
                self.setupUI()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.width/2
    }
    
    private func setupUI() {
        if let contact = data {
            ivAvatar.af.setImage(withURL: (contact.avatarUrl ?? URL(string: "http://"))!)
            self.lblName.text = contact.name
        }
    }
    
}
