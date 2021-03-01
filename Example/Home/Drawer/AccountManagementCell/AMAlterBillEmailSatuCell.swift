//
//  AMAlterBillEmailSatuCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMAlterBillEmailSatuCell: UITableViewCell {

    @IBOutlet weak var lbNotifEmptyAlterBillEmail: UILabel!
    @IBOutlet weak var tfAlterBillEmail: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tfAlterBillEmail.frame.height - 1, width: tfAlterBillEmail.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        tfAlterBillEmail.borderStyle = UITextField.BorderStyle.none
        tfAlterBillEmail.layer.addSublayer(bottomLine)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(alternatifBillingEmailSatu : String = ""){
        self.tfAlterBillEmail.text = alternatifBillingEmailSatu
    }
    
}
