//
//  DetailConversationCell.swift
//  Example
//
//  Created by arief nur putranto on 07/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class DetailConversationCell: UITableViewCell {

    @IBOutlet weak var lbReplymessage: UILabel!
    @IBOutlet weak var lbReplySender: UILabel!
    @IBOutlet weak var heightReplyViewCons: NSLayoutConstraint! // default 40
    @IBOutlet weak var viewReply: UIView!
    @IBOutlet weak var viewBackgroundMessage: UIView!
//    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbMessage: UITextView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.ivAvatar.layer.cornerRadius = ivAvatar.layer.frame.size.height / 2
        self.viewBackgroundMessage.layer.cornerRadius = 8
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
