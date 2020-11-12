//
//  RemoveAgentVC.swift
//  Example
//
//  Created by Qiscus on 12/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RemoveAgentVC: UIViewController {
    
    @IBOutlet weak var btRemove: UIButton!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var agentData : [AgentModel] = [AgentModel]()
    var roomName : String = ""
    var roomID : String = ""
    var selectedIndexPath : IndexPath?
    var page = 1
    var stopLoad : Bool = false
    var isLoading : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getList()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        goBack()
    }
    
    @IBAction func removeAction(_ sender: Any) {
        removeAgent()
    }
    
    
    func setupUI(){
        self.title = "Choose agent to remove"
        let backButton = self.backButton(self, action: #selector(RemoveAgentVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)]
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(AgentCell.nib, forCellReuseIdentifier: AgentCell.identifier)
        self.tableView.tableFooterView = UIView()
        
        self.btCancel.layer.cornerRadius = 16
        self.btRemove.layer.cornerRadius = 16
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor(red: 39/255, green: 182/255, blue: 157/255, alpha: 1)
        
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
        
        if stopLoad == true {
            return
        }
        
        if isLoading == true {
            return
        }
        
        isLoading = true
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["room_id": roomID,
                     "limit": 100,
                     "page" : self.page,
                     "is_available_in_room" : true
            ] as [String : Any]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/admin/service/available_agents", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    self.isLoading = false
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getList()
                            } else {
                                self.stopLoad = true
                                return
                            }
                        }
                    }
                    
                } else {
                    self.isLoading = false
                    //success
                    let payload = JSON(response.result.value)
                    if let agentsData = payload["data"].array {
                        let count = agentsData.count
                        if count == 0 {
                            self.stopLoad = true
                        } else {
                            var results = [AgentModel]()
                            for agentData in agentsData {
                                let data = AgentModel(json: agentData)
                                results.append(data)
                            }
                            self.agentData.append(contentsOf: results)
                            self.page += 1
                            self.tableView.reloadData()
                        }
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.isLoading = false
                self.stopLoad = true
            } else {
                //failed
                self.isLoading = false
                self.stopLoad = true
            }
        }
    }
    
    func removeAgent(){
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
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/admin/service/remove_agent", method: .post, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
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
                    let alert = UIAlertController(title: "Success", message: "Successfully remove agent.", preferredStyle: UIAlertController.Style.alert)
                    
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

extension RemoveAgentVC : UITableViewDelegate, UITableViewDataSource {
    
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
        
        if self.agentData.count - 1 == indexPath.row {
            getList()
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

