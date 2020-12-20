//
//  DetailBroadcastHistoryCell.swift
//  Example
//
//  Created by Qiscus on 13/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class DetailBroadcastHistoryCell: UITableViewCell {

    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(data : BroadCastHistoryModel){
        lbMessage.text = data.message
        lbTime.text = data.hour(date: data.getDate())
        lbDate.text = data.dateString(date: data.getDate())
    }
    
}
