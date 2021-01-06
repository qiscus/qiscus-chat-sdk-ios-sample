//
//  AdditionalInformationVC.swift
//  Example
//
//  Created by Qiscus on 03/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import QiscusCore

class AdditionalInformationVC: UIViewController {
    @IBOutlet weak var bgBottom: UIView!
    @IBOutlet weak var viewBGAdditional: UIView!
    @IBOutlet weak var viewEditAdditional: UIView!
    @IBOutlet weak var btSave: UIButton!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var btAddNewInformation: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var lbEmptyAdditionalInformation: UILabel!
    
    @IBOutlet weak var btAlertOK: UIButton!
    @IBOutlet weak var bgViewAlert: UIView!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lbAlertText: UILabel!
    var dataAddtionalInformation = [AdditionalInformationModel]()
    var roomID = ""
    var lastIndexPath : IndexPath? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataAddtionalInformation.count == 0 {
            self.lbEmptyAdditionalInformation.alpha = 1
        } else {
            self.lbEmptyAdditionalInformation.alpha = 0
        }
        
    }

    func setupUI(){
        //setup navigationBar
        self.title = "Additional Information"
        let backButton = self.backButton(self, action: #selector(AdditionalInformationVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
         self.btAddNewInformation.layer.cornerRadius = self.btAddNewInformation.frame.height / 2
        
        //table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "DetailAdditionalInformationCell", bundle: nil), forCellReuseIdentifier: "DetailAdditionalInformationCellIdentifire")
       
        self.tableView.tableFooterView = UIView()
        
        //To apply border
        bgBottom.layer.borderWidth = 0.25
        bgBottom.layer.borderColor = UIColor.lightGray.cgColor
        
        //To apply Shadow
        bgBottom.layer.shadowRadius = 0.5
        bgBottom.layer.shadowOffset = CGSize.zero // Use any CGSize
        bgBottom.layer.shadowColor = UIColor.lightText.cgColor
        
        
        self.btSave.layer.cornerRadius = self.btSave.frame.height / 2
        self.btCancel.layer.cornerRadius = self.btCancel.frame.height / 2
        
        self.btCancel.layer.borderWidth = 2
        self.btCancel.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        
        self.viewBGAdditional.layer.cornerRadius = 8
        
        //alert
        self.bgViewAlert.layer.cornerRadius = 8
        self.btAlertOK.layer.cornerRadius = self.btAlertOK.frame.height / 2

    }
    
    @IBAction func alertActionOk(_ sender: Any) {
        self.viewAlert.alpha = 0
        self.viewEditAdditional.alpha = 1
    }
    
    @IBAction func createNewAddInformation(_ sender: Any) {
        self.lbEmptyAdditionalInformation.alpha = 0
        self.viewEditAdditional.alpha = 1
        self.tfTitle.text = ""
        self.tfDescription.text = ""
    }
    
    @IBAction func actionSave(_ sender: Any) {
        self.viewEditAdditional.alpha = 0
        self.view.endEditing(true)
        
        
        let textTitle = self.tfTitle.text ?? ""
        let textDescription = self.tfDescription.text ?? ""
        
        //call api
        if !textTitle.isEmpty && !textDescription.isEmpty {
            if let index = lastIndexPath {
                //edit
                var data = self.dataAddtionalInformation[index.row]
                
                
                //first check
                if data.titleInformation == self.tfTitle.text ?? "" && data.descriptionInformation == self.tfDescription.text ?? "" {
                    //data is same
                    self.tfTitle.text = ""
                    self.tfDescription.text = ""
                    self.lastIndexPath = nil
                } else {
                    
                    //check title same or not
                    var sameTitle = false
                    for (indexData, dataAddtional) in self.dataAddtionalInformation.enumerated() {
                        if indexData != index.row {
                            if dataAddtional.titleInformation.contains(textTitle) {
                                sameTitle = true
                            }
                        }
                    }
                    
                    if sameTitle == false {
                        data.titleInformation           = self.tfTitle.text ?? ""
                        data.descriptionInformation     = self.tfDescription.text ?? ""
                        
                        self.dataAddtionalInformation[index.row] = data
                        
                        self.addOrUpdateAdditional()
                    } else {
                        //show alert title same
                        self.viewAlert.alpha = 1
                        self.lbAlertText.text = "Additional Information already exists"
                        self.lbEmptyAdditionalInformation.alpha = 0
                    }
                }
            }else{
                 //create new
                if self.dataAddtionalInformation.count == 0 {
                   
                    var data = AdditionalInformationModel()
                    data.titleInformation           = self.tfTitle.text ?? ""
                    data.descriptionInformation     = self.tfDescription.text ?? ""
                    
                    self.dataAddtionalInformation.append(data)
                    
                    self.addOrUpdateAdditional()
                } else {
                    //check title same or not
                    var sameTitle = false
                    for (indexData, dataAddtional) in self.dataAddtionalInformation.enumerated() {
                        if dataAddtional.titleInformation.contains(textTitle) {
                            sameTitle = true
                        }
                    }
                    
                    if sameTitle == false {
                        var data = AdditionalInformationModel()
                        data.titleInformation           = self.tfTitle.text ?? ""
                        data.descriptionInformation     = self.tfDescription.text ?? ""
                        
                        self.dataAddtionalInformation.append(data)
                        
                        self.addOrUpdateAdditional()
                    } else {
                        //show alert title same
                        self.viewAlert.alpha = 1
                        self.lbAlertText.text = "Additional Information already exists"
                        self.lbEmptyAdditionalInformation.alpha = 0
                    }
                }
            }
        } else {
            //show alert empty
            self.lbEmptyAdditionalInformation.alpha = 0
            self.viewAlert.alpha = 1
            self.lbAlertText.text = "Title and Description must not empty"
        }
    }
    
    func addOrUpdateAdditional(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: [Any]] = [
            "user_properties": []
        ]
        
        for index in self.dataAddtionalInformation.enumerated() {
            let item: [String: String] = [
                "value" : index.element.descriptionInformation,
                "key": index.element.titleInformation
            ]
            param["user_properties"]?.append(item)
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/qiscus/room/\(self.roomID)/user_info", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.addOrUpdateAdditional()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    if self.dataAddtionalInformation.count == 0 {
                        self.lbEmptyAdditionalInformation.alpha = 1
                    } else {
                        self.lbEmptyAdditionalInformation.alpha = 0
                    }
                    //success
                    self.tfTitle.text = ""
                    self.tfDescription.text = ""
                    self.lastIndexPath = nil
                    self.tableView.reloadData()
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.lastIndexPath = nil
            } else {
                //failed
                self.lastIndexPath = nil
            }
        }
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        if self.dataAddtionalInformation.count == 0 {
            self.lbEmptyAdditionalInformation.alpha = 1
        } else {
            self.lbEmptyAdditionalInformation.alpha = 0
        }
        self.viewEditAdditional.alpha = 0
        self.view.endEditing(true)
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor.white
        
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
}

extension AdditionalInformationVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAddtionalInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "DetailAdditionalInformationCellIdentifire", for: indexPath) as! DetailAdditionalInformationCell
       
        let data = self.dataAddtionalInformation[indexPath.row]
        
        cell.lbTitle.text = data.titleInformation
        cell.lbDescription.text = data.descriptionInformation
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            tableView.isEditing = false
            
            // your action
            self.lastIndexPath = indexPath
            let data = self.dataAddtionalInformation[indexPath.row]
            self.tfTitle.text = data.titleInformation
            self.tfDescription.text = data.descriptionInformation
            
            self.viewEditAdditional.alpha = 1
        }
        
        editAction.backgroundColor = ColorConfiguration.defaultColorTosca
        
        
        var deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            tableView.isEditing = false
            // your delete action
        
            self.dataAddtionalInformation.remove(at: indexPath.row)
            
            self.addOrUpdateAdditional()
        }
        
        return [editAction, deleteAction]
    }
}
