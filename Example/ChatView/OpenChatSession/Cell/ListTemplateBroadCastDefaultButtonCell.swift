//
//  ListTemplateBroadCastDefaultButtonCell.swift
//  Example
//
//  Created by arief nur putranto on 15/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class ListTemplateBroadCastDefaultButtonCell: UITableViewCell {

    @IBOutlet weak var viewBacground: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBacground.layer.cornerRadius = 4
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(title : String){
        self.lbTitle.text = title
    }
    
}
