//
//  AgentCustomerInfoCell.swift
//  Example
//
//  Created by Qiscus on 03/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

class AgentCustomerInfoCell: UITableViewCell {
    @IBOutlet weak var tableViewAgents: UITableView!
    @IBOutlet weak var tableViewHeightConst: NSLayoutConstraint!
    var viewController : ChatAndCustomerInfoVC? = nil
    var participants : [AgentModel]? = nil
    var firstLoad = false
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupUI(){
        //table view
        self.tableViewAgents.dataSource = self
        self.tableViewAgents.tableFooterView = UIView()
        self.tableViewAgents.register(AgentCell.nib, forCellReuseIdentifier: AgentCell.identifier)
        self.tableViewAgents.register(UINib(nibName: "NoAgentsCell", bundle: nil), forCellReuseIdentifier: "NoAgentsCellIdentifire")
    }
    
    func setupData(participants : [AgentModel]? = nil){
        self.participants = participants
        if let agents = participants {
            if agents.count == 0 {
                tableViewHeightConst.constant = 85
            }else{
                tableViewHeightConst.constant = CGFloat(agents.count * 85)
                self.firstLoad = true
                self.tableViewAgents.reloadData()
//                self.viewController?.tableView.beginUpdates()
//                self.viewController?.tableView.endUpdates()
                
            }
        } else {
            tableViewHeightConst.constant = 85
        }
    }
    
}

extension AgentCustomerInfoCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let agents = self.participants {
            return agents.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let agents = self.participants {
            if agents.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoAgentsCellIdentifire", for: indexPath) as! NoAgentsCell
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                return cell
            } else {
                let data = agents[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: AgentCell.identifier, for: indexPath) as! AgentCell
                cell.setupUIAgent(data: data)
                cell.btCheck.isHidden = true
                cell.avatarOnlineOffline.isHidden = true
                cell.lbCustomerCount.isHidden = true
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoAgentsCellIdentifire", for: indexPath) as! NoAgentsCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        }
        
        return UITableViewCell()
    }
}
