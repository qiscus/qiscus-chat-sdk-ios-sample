//
//  AMIndustryCell.swift
//  Example
//
//  Created by Qiscus on 09/02/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class AMIndustryCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var lbNotifEmptyIndustry: UILabel!
    @IBOutlet weak var tfIndustry: UITextField!
    var dataIndustry : [String] = ["Automotive", "Banking & Finance", "Consumer Goods", "Pharmaceutical", "Energy", "Mining", "Government", "Healthcare", "Insurance", "Manufacturing", "Media & Entertainment", "Retail", "Property", "Transportation", "Telecomunications", "Other"]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: tfIndustry.frame.height - 1, width: tfIndustry.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        tfIndustry.borderStyle = UITextField.BorderStyle.none
        tfIndustry.layer.addSublayer(bottomLine)
        
        tfIndustry.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "ic_drop_down")
        imageView.image = image
        tfIndustry.rightView = imageView
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        tfIndustry.inputView = pickerView
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateUI), name: Notification.Name("AMIndustryChanged"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(industry : String = ""){
        self.tfIndustry.text = industry
    }
    
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return dataIndustry.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataIndustry[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfIndustry.text = dataIndustry[row]
        self.lbNotifEmptyIndustry.isHidden = true
    
    }
    
    @objc func updateUI(){
        if self.tfIndustry.text?.isEmpty == true {
            self.lbNotifEmptyIndustry.isHidden = false
        } else {
            self.lbNotifEmptyIndustry.isHidden = true
        }
    }
    
}
