//
//  HDCIContactChannelCell.swift
//  Example
//
//  Created by arief nur putranto on 09/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class HDCIContactChannelCell: UITableViewCell {

    @IBOutlet weak var ivBadgeChannel: UIImageView!
    @IBOutlet weak var lbChannelName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivBadgeChannel.layer.cornerRadius = ivBadgeChannel.layer.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
