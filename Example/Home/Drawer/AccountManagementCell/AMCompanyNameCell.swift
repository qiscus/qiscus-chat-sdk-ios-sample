//
//  AMCompanyNameCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMCompanyNameCell: UITableViewCell {

    @IBOutlet weak var lbNotifEmptyCompanyName: UILabel!
    @IBOutlet weak var tfCompanyname: UITextField!
    var dataCompany = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tfCompanyname.frame.height - 1, width: tfCompanyname.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        tfCompanyname.borderStyle = UITextField.BorderStyle.none
        tfCompanyname.layer.addSublayer(bottomLine)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateUI), name: Notification.Name("AMCompanyNameChanged"), object: nil)
        
        self.tfCompanyname.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(companyName : String = ""){
        if dataCompany.isEmpty == true {
            self.dataCompany = companyName
            self.tfCompanyname.text = companyName
        }
    }
    
    @objc func updateUI(){
        if self.tfCompanyname.text?.isEmpty == true {
            self.lbNotifEmptyCompanyName.isHidden = false
        } else {
            self.lbNotifEmptyCompanyName.isHidden = true
        }
    }
    
}

extension AMCompanyNameCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { () -> Void in
            if self.tfCompanyname.text?.isEmpty == false {
                self.lbNotifEmptyCompanyName.isHidden = true
            }
        }
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}
