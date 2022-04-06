//
//  ListTemplateBroadCastURLPhoneNumberButtonCell.swift
//  Example
//
//  Created by arief nur putranto on 15/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class ListTemplateBroadCastURLPhoneNumberButtonCell: UITableViewCell {
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var viewLine: UIView!
    var hideLine = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if hideLine == true {
            viewLine.isHidden = true
        }else{
            viewLine.isHidden = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(isTypeUrl : Bool, title : String){
        if isTypeUrl == true{
            self.ivImage.image = UIImage(named: "ic_template_url")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.ivImage.tintColor = UIColor(red: 0/255.0, green: 165/255.0, blue: 224/255.0, alpha:1.0)
        }else{
            self.ivImage.image = UIImage(named: "ic_template_call")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            self.ivImage.tintColor = UIColor(red: 0/255.0, green: 165/255.0, blue: 224/255.0, alpha:1.0)
        }
        
        self.lbTitle.text = title
    }
    
}
