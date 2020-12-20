//
//  BroadcastHistoryCell.swift
//  Example
//
//  Created by Qiscus on 12/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class BroadcastHistoryCell: UITableViewCell {
    @IBOutlet weak var btArrow: UIButton!
    @IBOutlet weak var lbCountBroadcastHistory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    func setupUI(){
        btArrow.tintColor = ColorConfiguration.defaultColorTosca
        btArrow.setImage(UIImage(named: "ic_arrow_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
