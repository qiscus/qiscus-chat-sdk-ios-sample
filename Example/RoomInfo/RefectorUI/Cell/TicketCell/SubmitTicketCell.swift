//
//  SubmitTicketCell.swift
//  Example
//
//  Created by Qiscus on 18/10/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SubmitTicketCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var buttonSubmitTicket: UIButton!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
  
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupData(data : SubmitTicketModel){
        self.label.text = data.label
        self.buttonSubmitTicket.setTitle(data.nameButton, for: .normal)
        self.buttonSubmitTicket.tag = data.id
    }
    
}
