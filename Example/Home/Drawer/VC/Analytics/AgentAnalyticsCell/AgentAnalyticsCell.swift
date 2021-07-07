//
//  AgentAnalyticsCell.swift
//  Example
//
//  Created by Qiscus on 01/07/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AgentAnalyticsCell: UITableViewCell {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lbRole: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var viewAgent: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivAvatar.layer.cornerRadius = ivAvatar.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setupUIAgent(data : AgentModel){
        
        lbName.text = data.name
        lbEmail.text = data.email
        
        var roles = [String]()
        
        for i in data.userRoles {
            roles.append(i.name)
        }
        
        let joined = roles.joined(separator: ", ")
        lbRole.text = joined
        
        if let avatarUrl = data.avatarUrl{
            self.ivAvatar.isHidden = false
            self.ivAvatar.af_setImage(withURL: (URL(string: avatarUrl) ?? URL(string: "https://"))!)
        }else{
            self.ivAvatar.isHidden = true
        }
        
    }
    
}
