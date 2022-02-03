//
//  HSMCreditFreeSessionQuota.swift
//  Example
//
//  Created by arief nur putranto on 24/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class HSMCreditFreeSessionQuota: UITableViewCell {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lbQuota: UILabel!
    @IBOutlet weak var lbFreeSession: UILabel!
    @IBOutlet weak var lbCredit: UILabel!
    
    @IBOutlet weak var heightQuotaDua: NSLayoutConstraint!
    @IBOutlet weak var heightQuotaSatu: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewAlert.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
