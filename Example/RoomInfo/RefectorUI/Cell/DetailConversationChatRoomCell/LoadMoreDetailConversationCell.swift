//
//  LoadMoreDetailConversationCell.swift
//  Example
//
//  Created by arief nur putranto on 13/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class LoadMoreDetailConversationCell: UITableViewCell {

    @IBOutlet weak var btLoadMore: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        btLoadMore.backgroundColor = .clear
        btLoadMore.layer.cornerRadius = btLoadMore.frame.size.height / 2
        btLoadMore.layer.borderWidth = 1
        btLoadMore.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
