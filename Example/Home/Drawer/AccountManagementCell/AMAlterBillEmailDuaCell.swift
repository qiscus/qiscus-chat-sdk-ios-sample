//
//  AMAlterBillEmailDuaCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMAlterBillEmailDuaCell: UITableViewCell {

    @IBOutlet weak var lbNotifEmptyAlterBillEmail: UILabel!
    @IBOutlet weak var tfAlterBillEmailDua: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tfAlterBillEmailDua.frame.height - 1, width: tfAlterBillEmailDua.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        tfAlterBillEmailDua.borderStyle = UITextField.BorderStyle.none
        tfAlterBillEmailDua.layer.addSublayer(bottomLine)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(alternatifBillingEmailDua : String = ""){
        self.tfAlterBillEmailDua.text = alternatifBillingEmailDua
    }
    
}
