//
//  ChatTemplateCell.swift
//  Example
//
//  Created by Qiscus on 17/07/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class ChatTemplateCell: UITableViewCell {
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var lbMessageTemplate: UILabel!
    @IBOutlet weak var lbCommand: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
