//
//  EmptyCell.swift
//  MyChat
//
//  Created by Qiscus on 30/11/18.
//

import UIKit
import QiscusCore

class EmptyCell: UIBaseChatCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
    }
    
    override func update(message: CommentModel) {
        
    }
    
}
