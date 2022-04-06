//
//  Content24HSMChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 04/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class Content24HSMChatSessionCell: UITableViewCell {

    @IBOutlet weak var heightTvContent: NSLayoutConstraint!
    @IBOutlet weak var tvContent: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tvContent.isEditable = false
    }
    
    func setupData(message : String){
        tvContent.text = message
        
        let height = message.heightWithConstrainedWidth(width: tvContent.frame.width, font: UIFont.systemFont(ofSize: 14))
        
        self.heightTvContent.constant = height + 50
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
