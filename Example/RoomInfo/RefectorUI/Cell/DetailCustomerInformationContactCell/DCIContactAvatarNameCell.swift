//
//  DCIContactAvatarNameCell.swift
//  Example
//
//  Created by arief nur putranto on 09/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class DCIContactAvatarNameCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivAvatarName: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        ivAvatarName.layer.cornerRadius = ivAvatarName.layer.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
