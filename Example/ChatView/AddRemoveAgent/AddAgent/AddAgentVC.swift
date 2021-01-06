//
//  AddAgentVC.swift
//  Example
//
//  Created by Qiscus on 12/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddAgentVC: UIViewController {

    @IBOutlet weak var btAssign: UIButton!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var btCheckBox: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbReplaceExistingAgent: UILabel!
    @IBOutlet weak var lbNoAgentTitle: UILabel!
    @IBOutlet weak var lbNoAgentSubtitle: UILabel!
    
    var agentData : [AgentModel] = [AgentModel]()
    var roomName : String = ""
    var roomID : String = ""
    var selectedIndexPath : IndexPath?
    var isAssignFromAgent = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getList()
    }

    @IBAction func radioButtonClick(_ sender: Any) {
        if (btCheckBox.isSelected == true){
            btCheckBox.setBackgroundImage(UIImage(named: "ic_uncheck"), for: UIControl.State.normal)
            btCheckBox.isSelected = false;
        } else {
            btCheckBox.setBackgroundImage(UIImage(named: "ic_check_button"), for: UIControl.State.normal)
            btCheckBox.isSelected = true;
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
       goBack()
    }
    
    @IBAction func assignAction(_ sender: Any) {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                if isAssignFromAgent == true {
                     assignAgent()
                }else{
                     addAgent()
                }
               
            } else {
                assignAgent()
            }
        }
      
    }
    
    
    func setupUI(){
        self.title = "Assign \(roomName) to ...."
        let backButton = self.backButton(self, action: #selector(AddAgentVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(AgentCell.nib, forCellReuseIdentifier: AgentCell.identifier)
        self.tableView.tableFooterView = UIView()
        
        self.btCancel.layer.cornerRadius = 16
        self.btAssign.layer.cornerRadius = 16
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                self.lbReplaceExistingAgent.isHidden = true
                self.btCheckBox.isHidden = true
            }
        }
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor.white//UIColor(red: 39/255, green: 182/255, blue: 157/255, alpha: 1)
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getList(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        var adminOrAgent = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                adminOrAgent = "agent"
            } else if userType == 3 {
                adminOrAgent = "spv"
            }
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["room_id": roomID,
                     "limit": "100",
                    ] as [String : String]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(adminOrAgent)/service/other_agents", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getList()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let agentsData = payload["data"]["agents"].array {
                        var results = [AgentModel]()
                        for agentData in agentsData {
                            let data = AgentModel(json: agentData)
                            results.append(data)
                        }
                        self.agentData = results
                    }
                    
                    self.tableView.reloadData()
                    
                    self.showHideLbNoAgent()
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.showHideLbNoAgent()
            } else {
                //failed
                self.showHideLbNoAgent()
            }
        }
    }
    
    func showHideLbNoAgent() {
        if self.agentData.count == 0 {
            self.lbNoAgentTitle.isHidden = false
            self.lbNoAgentSubtitle.isHidden = false
        } else {
            self.lbNoAgentTitle.isHidden = true
            self.lbNoAgentSubtitle.isHidden = true
        }
    }
    
    func assignAgent(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        guard let indexPath = selectedIndexPath else {
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        var param = ["room_id": roomID,
                     "agent_id" : self.agentData[indexPath.row].id
            ] as [String : Any]
        
        var adminOrAgent = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                adminOrAgent = "agent"
            } else {
                param["replace_latest_agent"] =  self.btCheckBox.isSelected
            }
            //else if userType == 3 {
            //                adminOrAgent = "spv"
            //            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/\(adminOrAgent)/service/assign_agent", method: .post, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getList()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    // create the alert
                    let alert = UIAlertController(title: "Success", message: "Assign to agent has been succeeded.", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        //success
                        self.goBack()
                    }
                    ))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    //for agent
    func addAgent(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        guard let indexPath = selectedIndexPath else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["room_id": roomID,
                     "agent_id" : self.agentData[indexPath.row].id
            ] as [String : Any]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/agent/service/add_agent", method: .post, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getList()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    // create the alert
                    let alert = UIAlertController(title: "Success", message: "Assign to agent has been succeeded.", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        //success
                        self.goBack()
                    }
                    ))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }

}

extension AddAgentVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.agentData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.agentData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AgentCell.identifier, for: indexPath) as! AgentCell
        cell.setupUIAgent(data: data)
        if indexPath == selectedIndexPath {
            cell.btCheck.isHidden = false
        }else{
             cell.btCheck.isHidden = true
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var pathsToReload = [indexPath]
        if let selectedPath = selectedIndexPath {
            if indexPath == selectedPath { // deselect current row
                selectedIndexPath = nil
            } else { // deselect previous row, select current row
                pathsToReload.append(selectedPath)
                selectedIndexPath = indexPath
            }
        } else { // select current row
            selectedIndexPath = indexPath
        }
        tableView.reloadRows(at: pathsToReload, with: .automatic)
        
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

