//
//  CustomerInfoCell.swift
//  Example
//
//  Created by Qiscus on 02/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class CustomerInfoCell: UITableViewCell {
    @IBOutlet weak var lbChannelName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivAvatarCusomer: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ivAvatarCusomer.layer.cornerRadius = self.ivAvatarCusomer.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
