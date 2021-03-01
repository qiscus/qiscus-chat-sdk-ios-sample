//
//  AMAlterBillEmailTigaCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMAlterBillEmailTigaCell: UITableViewCell {

    @IBOutlet weak var lbNotifEmptyAlterBillEmail: UILabel!
    @IBOutlet weak var tfAlterBillEmailTiga: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tfAlterBillEmailTiga.frame.height - 1, width: tfAlterBillEmailTiga.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        tfAlterBillEmailTiga.borderStyle = UITextField.BorderStyle.none
        tfAlterBillEmailTiga.layer.addSublayer(bottomLine)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(alternatifBillingEmailTiga : String = ""){
        self.tfAlterBillEmailTiga.text = alternatifBillingEmailTiga
    }
    
}
