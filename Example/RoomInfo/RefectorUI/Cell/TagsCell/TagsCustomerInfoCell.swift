//
//  TagsCustomerInfoCell.swift
//  Example
//
//  Created by Qiscus on 02/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TagsCustomerInfoCell: UITableViewCell {
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var btAddTags: UIButton!
    @IBOutlet weak var tvAddNewTags: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableViewCons: NSLayoutConstraint!
    @IBOutlet weak var heightTVAddNewTagsCons: NSLayoutConstraint!
    
    var viewController : ChatAndCustomerInfoVC? = nil
    var roomID : String = ""
    var tagsSuggestion : [TagsModel] = [TagsModel]()
    var tagsData : [TagsModel] = [TagsModel]()
    var isCreateTags = true
    var firstLoad = false
    var indexPath: IndexPath? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        if tagsData.count == 0 && !roomID.isEmpty {
            getListTags()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        //tag
        tagListView.textFont = .systemFont(ofSize: 17)
        tagListView.shadowRadius = 2
        tagListView.shadowOpacity = 0.4
        tagListView.shadowColor = UIColor.black
        tagListView.shadowOffset = CGSize(width: 1, height: 1)
        tagListView.alignment = .center
        tagListView.enableRemoveButton = true
        tagListView.delegate = self
        
        //tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TagsSuggestionCell.nib, forCellReuseIdentifier: TagsSuggestionCell.identifier)
        self.tableView.tableFooterView = UIView()
        
        
        //textField
        tvAddNewTags.delegate = self
        btAddTags.tintColor = ColorConfiguration.defaultColorTosca
        btAddTags.setImage(UIImage(named: "ic_sending")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        
        //To apply corner radius
        tvAddNewTags.layer.cornerRadius = 8

        //To apply border
        tvAddNewTags.layer.borderWidth = 0.25
        tvAddNewTags.layer.borderColor = UIColor.lightGray.cgColor

        //To apply Shadow
       // tvAddNewTags.layer.shadowOpacity = 0.5
        tvAddNewTags.layer.shadowRadius = 0.5
        tvAddNewTags.layer.shadowOffset = CGSize.zero // Use any CGSize
        tvAddNewTags.layer.shadowColor = UIColor.lightText.cgColor

        //To apply padding
        let paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: tvAddNewTags.frame.height))
        tvAddNewTags.leftView = paddingView
        tvAddNewTags.leftViewMode = UITextField.ViewMode.always
        
        if isCreateTags == false {
            self.heightTVAddNewTagsCons.constant = 0
            self.btAddTags.isHidden = true
        }
    }
    
    @IBAction func addTagsAction(_ sender: Any) {
        self.tableView.isHidden = true
        self.submitTags()
    }
    
    func submitTags(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        guard let text = tvAddNewTags.text else {
            return
        }
        
        if text.isEmpty == true {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        let param = ["tag": "\(tvAddNewTags.text!)"
            ] as [String : Any]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/room_tags/\(self.roomID)", method: .post, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.submitTags()
                            } else {
                                return
                            }
                        }
                    } else if response.response?.statusCode == 400 {
                        let payload = JSON(response.result.value)
                        let errorMessage = payload["errors"]["message"].string ?? "Tag already exist"
                        // create the alert
                        let alert = UIAlertController(title: "Failed", message: "\(errorMessage)", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                            
                        }
                        ))
                        
                        // show the alert
                        self.viewController?.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    //success
                    self.tvAddNewTags.text = ""
                    self.endEditing(true)
                    self.getListTags()
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    @objc func getListTagsSuggestion(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        let param = ["page": 1,
                     "limit": 100,
                     "name" : self.tvAddNewTags.text ?? ""
            ] as [String : Any]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/tags", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListTags()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let tags = payload["data"].array {
                        var results = [TagsModel]()
                        for tag in tags {
                            let data = TagsModel(json: tag)
                            results.append(data)
                        }
                        self.tagsSuggestion = results
                        
                     
                        for i in self.tagsData.enumerated() {
                            self.tagsSuggestion = self.tagsSuggestion.filter { $0.name.lowercased() != i.element.name.lowercased() }
                        }
                        
                        if tags.count == 0 {
                            self.heightTableViewCons.constant = 0
                        }else{
                            self.heightTableViewCons.constant = 150
                        }
                        self.tableView.reloadData()
                        
                        self.viewController?.tableView.beginUpdates()
                        self.viewController?.tableView.endUpdates()
                        
                    }else{
                        self.heightTableViewCons.constant = 0
                        self.viewController?.tableView.beginUpdates()
                        self.viewController?.tableView.endUpdates()
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getListTags(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/room_tags/\(self.roomID)", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListTags()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let tags = payload["data"].array {
                        var results = [TagsModel]()
                        for tag in tags {
                            let data = TagsModel(json: tag)
                            results.append(data)
                        }
                        self.tagsData = results
                        
                        if self.tagsData.count != 0 {
                            self.tagListView.removeAllTags()
                            for tagData in self.tagsData {
                                self.tagListView.addTag(tagData.name)
                            }
                        }
                    }
                    
                    if ((self.viewController?.tableView.dataHasChanged) == true) {
                        self.viewController?.tableView.reloadData()
                    }else{
                        self.viewController?.tableView.beginUpdates()
                        self.viewController?.tableView.endUpdates()
                    }
                    
                    
                    if self.firstLoad == false {
                        self.firstLoad = true
                         self.viewController?.tableView.reloadData()
                    }
                   
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func removeTags(id : Int, tagView: TagView, sender: TagListView ){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/room_tags/\(self.roomID)/\(id)", method: .delete, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.removeTags(id: id, tagView: tagView, sender: sender)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    sender.removeTagView(tagView)
                    
                    for (index, tags) in self.tagsData.enumerated() {
                        if tags.id == id {
                            if index >= self.tagsData.startIndex && index < self.tagsData.endIndex {
                                self.tagsData.remove(at: index)
                            }
                            
                        }
                    }
                    
                    
                    self.viewController?.tableView.beginUpdates()
                    self.viewController?.tableView.endUpdates()
                    
                    // create the alert
                    let alert = UIAlertController(title: "Success", message: "Success remove tag", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        //no action
                    }
                    ))
                    
                    // show the alert
                    if self.viewController != nil {
                        self.viewController!.present(alert, animated: true, completion: nil)
                    }
                   
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func searchTags() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.getListTagsSuggestion),
                                               object: nil)
        
        perform(#selector(self.getListTagsSuggestion),
                with: nil, afterDelay: 0.5)
        
    }
    
}

extension TagsCustomerInfoCell : TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        
        let wantRemove = self.tagsData.filter { $0.name.lowercased() == title.lowercased() }
        
        if wantRemove.count != 0 {
            removeTags(id : wantRemove.first!.id, tagView: tagView, sender: sender)
        }
        
    }
}

extension TagsCustomerInfoCell : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tagsSuggestion.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.tagsSuggestion[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TagsSuggestionCell.identifier, for: indexPath) as! TagsSuggestionCell
        cell.setupUI(name: data.name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.tagsSuggestion[indexPath.row]
        self.tvAddNewTags.text = data.name
        self.tableView.isHidden = true
        self.endEditing(true)
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

extension TagsCustomerInfoCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.heightTableViewCons.constant = 150
        self.viewController?.tableView.beginUpdates()
        self.viewController?.tableView.endUpdates()
        self.getListTagsSuggestion()
        
        self.tableView.isHidden = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.heightTableViewCons.constant = 0
        self.viewController?.tableView.beginUpdates()
        self.viewController?.tableView.endUpdates()
        self.tableView.isHidden = true
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
        self.searchTags()
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}
