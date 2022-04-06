//
//  AlertMessageChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 02/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class AlertMessageChatSessionCell: UITableViewCell {

    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var lbMessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewMessage.layer.cornerRadius = 8
    }
    
    func setup(message : String){
        self.lbMessage.text = message
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
