//
//  TagsVC.swift
//  Example
//
//  Created by Qiscus on 12/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TagsVC: UIViewController, TagListViewDelegate {
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var btAddTags: UIButton!
    @IBOutlet weak var tvAddNewTags: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var roomName : String = ""
    var roomID : String = ""
    var tagsSuggestion : [TagsModel] = [TagsModel]()
    var tagsData : [TagsModel] = [TagsModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getListTags()
    }
    
    @IBAction func addTagsAction(_ sender: Any) {
        self.tableView.isHidden = true
        self.submitTags()
    }
    
    // MARK: TagListViewDelegate
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
    
    func setupUI(){
        self.title = "Tags"
        let backButton = self.backButton(self, action: #selector(TagsVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)]
        
        //tag
        tagListView.textFont = .systemFont(ofSize: 20)
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
    
    func searchTags() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.getListTagsSuggestion),
                                               object: nil)
        
        perform(#selector(self.getListTagsSuggestion),
                with: nil, afterDelay: 0.5)
        
    }
    
    func submitTags(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        guard let text = tvAddNewTags.text else {
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
                        // create the alert
                        let alert = UIAlertController(title: "Failed", message: "Tag already exist", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                            
                        }
                        ))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    //success
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
                        
                        self.tableView.reloadData()
                        
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
                    // create the alert
                    let alert = UIAlertController(title: "Success", message: "Success remove tag", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        //no action
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

extension TagsVC : UITableViewDelegate, UITableViewDataSource {
    
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

extension TagsVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.getListTagsSuggestion()
        
        self.tableView.isHidden = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
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

