//
//  HSMCell.swift
//  Example
//
//  Created by Qiscus on 07/01/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class HSMCell: UITableViewCell {

    @IBOutlet weak var btShowAlertInfo: UIButton!
    @IBOutlet weak var btSendMessageTemplate: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btSendMessageTemplate.layer.cornerRadius = self.btSendMessageTemplate.frame.height / 2
        
        self.btSendMessageTemplate.layer.borderWidth = 2
        self.btSendMessageTemplate.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        self.btShowAlertInfo.setImage(UIImage(named: "ic_warning_alert")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        self.btShowAlertInfo.tintColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
