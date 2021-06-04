//
//  FilterByAgentCell.swift
//  Example
//
//  Created by Qiscus on 07/05/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol FilterByAgentCellDelegate{
    func updateSelectAgent(agentsData: [AgentModel])
}

class FilterByAgentCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
  
    @IBOutlet weak var tfSearchAgent: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var lbNoData: UILabel!
    
    var delegate: FilterByAgentCellDelegate?
    var viewController : FilterVC? = nil
    var agentsSugestionData: [AgentModel] = [AgentModel]()
    var agentsSelectedData: [AgentModel] = [AgentModel]()
    var defaults = UserDefaults.standard
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        if let userType = UserDefaults.standard.getUserType(){
            if userType != 2  {
                self.getListAgentsSuggestion()
            }
        }
       
    }
    
    func setupUI(){
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUIAgent"), object: nil)
        
        //tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "AgentFilterCell", bundle: nil), forCellReuseIdentifier: "AgentFilterCellIdentifire")
        self.tableView.tableFooterView = UIView()
        
        
        //textField
        tfSearchAgent.delegate = self
        
        
        //To apply corner radius
        tfSearchAgent.layer.cornerRadius = 8
        
        //To apply border
        tfSearchAgent.layer.borderWidth = 0.25
        tfSearchAgent.layer.borderColor = UIColor.lightGray.cgColor
        
        //To apply Shadow
        // tvAddNewTags.layer.shadowOpacity = 0.5
        tfSearchAgent.layer.shadowRadius = 0.5
        tfSearchAgent.layer.shadowOffset = CGSize.zero // Use any CGSize
        tfSearchAgent.layer.shadowColor = UIColor.lightText.cgColor
        
        //To apply padding
        let paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: tfSearchAgent.frame.height))
        tfSearchAgent.leftView = paddingView
        tfSearchAgent.leftViewMode = UITextField.ViewMode.always
    }
    
    @objc func resetUI(_ notification: Notification){
        self.agentsSugestionData.removeAll()
        self.agentsSelectedData.removeAll()
        self.tableView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func searchAgents() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.getListAgentsSuggestion),
                                               object: nil)
        
        perform(#selector(self.getListAgentsSuggestion),
                with: nil, afterDelay: 0.5)
        
    }
    
    @objc func getListAgentsSuggestion(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        let param = ["page": 1,
                     "limit": 50,
                     "search" : self.tfSearchAgent.text ?? "",
                     "scope" : "name",
                     "user_type_scope" : "agent"
        ] as [String : Any]
        
        var isAdminOrSPV = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
               //admin
                isAdminOrSPV = "admin"
            }else if userType == 2{
                //agent
                isAdminOrSPV = "admin"
            }else{
                //spv
                isAdminOrSPV = "spv"
            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(isAdminOrSPV)/agents", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListAgentsSuggestion()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let agents = payload["data"]["agents"].array {
                        var results = [AgentModel]()
                        for agent in agents {
                            let data = AgentModel(json: agent)
                            results.append(data)
                        }
                        
                        self.agentsSugestionData = results
                        
                        //TODO filter selected user from local
                        
                        if let hasFilterAgent = self.defaults.array(forKey: "filterAgent"){
                            for sugestion in self.agentsSugestionData {
                                for local in hasFilterAgent {
                                    if sugestion.id == local as! Int {
                                        sugestion.isSelected = true
                                    }
                                }
                            }
                        }
                        
                        self.tableViewHeightCons.constant = CGFloat((84 * self.agentsSugestionData.count))
                        
                        if self.agentsSugestionData.count == 0 {
                            self.lbNoData.isHidden = false
                        }else{
                            self.lbNoData.isHidden = true
                        }
                        self.tableView.reloadData()
                        
                        self.viewController?.tableViewAgent.beginUpdates()
                        self.viewController?.tableViewAgent.endUpdates()
                        
                    }else{
                        self.lbNoData.isHidden = false
                        self.tableViewHeightCons.constant = 0
                        self.viewController?.tableViewAgent.beginUpdates()
                        self.viewController?.tableViewAgent.endUpdates()
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    //tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.agentsSugestionData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.agentsSugestionData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgentFilterCellIdentifire", for: indexPath) as! AgentFilterCell
        cell.delegate = self
        cell.setupUIAgent(data: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension FilterByAgentCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.viewController?.tableViewAgent.beginUpdates()
        self.viewController?.tableViewAgent.endUpdates()
        self.getListAgentsSuggestion()
        
        self.tableView.isHidden = false
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
        
        self.tableView.isHidden = false
        self.searchAgents()
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}

extension FilterByAgentCell : AgentFilterCellDelegate {
    func updateSelectUnSelect(agent: AgentModel){
        if agent.isSelected == true {
            self.agentsSelectedData.append(agent)
        }else{
            for (index, element) in self.agentsSelectedData.enumerated() {
                if element.id == agent.id {
                    if let checkData = self.agentsSelectedData[safe: index]{
                        self.agentsSelectedData.remove(at: index)
                    }
                   
                }
            }
        }
        
        if let delegate = self.delegate {
            delegate.updateSelectAgent(agentsData: self.agentsSelectedData)
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

