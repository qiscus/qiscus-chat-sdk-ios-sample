//
//  AgentCell.swift
//  Example
//
//  Created by Qiscus on 12/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit

class AgentCell: UITableViewCell {
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
  
    static var identifier: String {
        return String(describing: self)
    }
    @IBOutlet weak var avatarAgent: UIImageView!
    @IBOutlet weak var lbAgentName: UILabel!
    @IBOutlet weak var btCheck: UIButton!
    @IBOutlet weak var lbCustomerCount: UILabel!
    @IBOutlet weak var lbAgentRole: UILabel!
    @IBOutlet weak var lbAgentEmail: UILabel!
    @IBOutlet weak var avatarOnlineOffline: UIImageView!
    
    var dataAgent : AgentModel? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarAgent.layer.cornerRadius = avatarAgent.frame.width/2
        avatarAgent.clipsToBounds = true
        avatarOnlineOffline.layer.cornerRadius = avatarOnlineOffline.frame.width/2
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        if selected == true {
//            btCheck.isHidden = false
//        } else {
//            btCheck.isHidden = true
//        }
    }
    
    
    public func setupUIAgent(data : AgentModel){
        self.dataAgent = data
        if let avatar = data.avatarUrl {
            self.avatarAgent.af_setImage(withURL: URL(string : avatar) ?? URL(string:"https://")!)
        }else{
            self.avatarAgent.af_setImage(withURL: URL(string:"https://")!)
        }
        
        lbAgentName.text = data.name
        lbCustomerCount.text = "\(data.currentCustomerCount) Customer"
        lbAgentEmail.text = data.email
        
        var roles = [String]()
        
        for i in data.userRoles {
            roles.append(i.name)
        }
        
        let joined = roles.joined(separator: ", ")
        lbAgentRole.text = joined
        
        if data.isAvailable == true {
            avatarOnlineOffline.backgroundColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        } else {
            avatarOnlineOffline.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        
        
        
    }
    
}
