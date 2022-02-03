//
//  ListRoomContactCell.swift
//  Example
//
//  Created by arief nur putranto on 07/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class ListRoomContactCell: UITableViewCell {
    @IBOutlet weak var lbRoomName: UILabel!
    @IBOutlet weak var ivRoom: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbLastMessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
