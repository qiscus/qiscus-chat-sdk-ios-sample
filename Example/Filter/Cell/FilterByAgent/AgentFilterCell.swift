//
//  AgentFilterCell.swift
//  Example
//
//  Created by Qiscus on 07/05/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol AgentFilterCellDelegate{
    func updateSelectUnSelect(agent: AgentModel)
}

class AgentFilterCell: UITableViewCell {

    @IBOutlet weak var lbAgentName: UILabel!
    @IBOutlet weak var btCheck: UIButton!
    @IBOutlet weak var lbAgentEmail: UILabel!
    @IBOutlet weak var lbAgentRole: UILabel!
    var dataAgent : AgentModel? = nil
    var delegate: AgentFilterCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupUIAgent(data : AgentModel){
        self.dataAgent = data
        
        lbAgentName.text = data.name
        lbAgentEmail.text = data.email
        
        var roles = [String]()
        
        for i in data.userRoles {
            roles.append(i.name)
        }
        
        let joined = roles.joined(separator: ", ")
        lbAgentRole.text = joined
        
        if data.isSelected == false {
            if let dataAgent = self.dataAgent {
                dataAgent.isSelected = false
            }
            self.btCheck.isSelected = false
            self.btCheck.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        }else{
            if let dataAgent = self.dataAgent {
                dataAgent.isSelected = true
            }
            self.btCheck.isSelected = true
            self.btCheck.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .selected)
        }
        
        if let delegate = self.delegate {
            if let dataAgent = self.dataAgent {
                delegate.updateSelectUnSelect(agent: dataAgent)
            }
        }
    }
    
    @IBAction func checkUnCheck(_ sender: Any) {
        if self.btCheck.isSelected == true {
            self.btCheck.isSelected = false
            self.btCheck.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
            if let dataAgent = self.dataAgent {
                dataAgent.isSelected = false
            }
        }else{
            self.btCheck.isSelected = true
            self.btCheck.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .selected)
            if let dataAgent = self.dataAgent {
                dataAgent.isSelected = true
            }
        }
        
        if let delegate = self.delegate {
            if let dataAgent = self.dataAgent {
                delegate.updateSelectUnSelect(agent: dataAgent)
            }
        }
    }
}
