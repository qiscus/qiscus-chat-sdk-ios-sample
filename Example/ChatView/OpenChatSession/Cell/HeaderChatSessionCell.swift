//
//  HeaderChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 02/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class HeaderChatSessionCell: UITableViewCell {

    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var viewMessage: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMessage.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
