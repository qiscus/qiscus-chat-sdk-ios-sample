//
//  HDCIContactEmailAndPhoneCell.swift
//  Example
//
//  Created by arief nur putranto on 09/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class HDCIContactEmailAndPhoneCell: UITableViewCell {

    @IBOutlet weak var lbPhoneNumber: UILabel!
    @IBOutlet weak var lbEMail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
