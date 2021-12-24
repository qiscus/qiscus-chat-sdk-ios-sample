//
//  ContactCustomerInfoCell.swift
//  Example
//
//  Created by arief nur putranto on 06/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

class ContactCustomerInfoCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var buttonContactDetail: UIButton!
    var viewController : ChatAndCustomerInfoVC? = nil
    var contactID = 0
    var channelID = 0
    var channelName = ""
    var channelType = ""
    var channelTypeString = ""
    var room : RoomModel? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonContactDetail.addTarget(self, action:#selector(self.buttonContactDetail(sender:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected == true {
            let vc = ContactDetailCustomerInfoVC()
            vc.contactID = self.contactID
            vc.channelName = self.channelName
            vc.channelID = self.channelID
            vc.channelTypeString = self.channelTypeString
            vc.room = self.room
            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    @objc func buttonContactDetail(sender: UIButton){
        let vc = ContactDetailCustomerInfoVC()
        vc.contactID = self.contactID
        vc.channelName = self.channelName
        vc.channelID = self.channelID
        vc.channelType = self.channelType
        vc.channelTypeString = self.channelTypeString
        vc.room = self.room
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
