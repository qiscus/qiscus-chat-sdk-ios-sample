//
//  FilterByTagCell.swift
//  Example
//
//  Created by Qiscus on 04/05/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON

protocol FilterByTagCellDelegate{
    func updateDataTag(tagsData: [TagsModel])
}

class FilterByTagCell: UITableViewCell {
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var btAddTags: UIButton!
    @IBOutlet weak var tvAddNewTags: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableViewCons: NSLayoutConstraint!
    @IBOutlet weak var heightTVAddNewTagsCons: NSLayoutConstraint!
    @IBOutlet weak var viewNoTag: UIView!
    @IBOutlet weak var lbSearchNoTag: UILabel!
    @IBOutlet weak var heightViewNoTagCons: NSLayoutConstraint!
    var delegate: FilterByTagCellDelegate?
    var viewController : FilterVC? = nil
    var tagsSuggestion : [TagsModel] = [TagsModel]()
    var tagsData : [TagsModel] = [TagsModel]()
    var indexPath: IndexPath? = nil
    var tagSuggestionSelected : TagsModel? = nil
    var defaults = UserDefaults.standard
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        getListFilterTagLocal()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupUI(){
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUITag"), object: nil)
        
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
        
    }
    
    @objc func resetUI(_ notification: Notification){
        self.tagListView.removeAllTags()
        self.tagsData.removeAll()
    }
    
    @IBAction func addTagsAction(_ sender: Any) {
        
    }
    
    func convertToDictionary(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getListFilterTagLocal(){
        //getLocalFilter
        
        if let hasFilterTag = defaults.string(forKey: "filterTag"){
            if let dict = convertToDictionary(text: hasFilterTag){
                var array = [Int]()
                if dict.count != 0 {
                    for i in dict{
                        let json = JSON(i)
                        let tag = TagsModel.init(json: json)
                        self.tagsData.append(tag)
                    }
                    
                    if self.tagsData.count != 0 {
                        self.tagListView.removeAllTags()
                        for tagData in self.tagsData {
                            self.tagListView.addTag(tagData.name)
                        }
                    }
                    
                    self.viewController?.tableViewTag.beginUpdates()
                    self.viewController?.tableViewTag.endUpdates()
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { () -> Void in
                        if let delegate = self.delegate {
                            delegate.updateDataTag(tagsData: self.tagsData)
                        }
                    }
                }
            }
        }
    }
    
    @objc func getListTagsSuggestion(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        let param = ["page": 1,
                     "limit": 5,
                     "name" : self.tvAddNewTags.text ?? ""
        ] as [String : Any]
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/tags", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListTagsSuggestion()
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
                            self.viewNoTag.isHidden = false
                            self.lbSearchNoTag.text = "\"\(self.tvAddNewTags.text ?? "")\""
                            self.heightViewNoTagCons.constant = 40
                        }else{
                            self.viewNoTag.isHidden = true
                            self.heightViewNoTagCons.constant = 0
                            self.heightTableViewCons.constant = 150
                        }
                        self.tableView.reloadData()
                        
                        self.viewController?.tableViewTag.beginUpdates()
                        self.viewController?.tableViewTag.endUpdates()
                        
                    }else{
                        self.heightTableViewCons.constant = 0
                        self.viewController?.tableViewTag.beginUpdates()
                        self.viewController?.tableViewTag.endUpdates()
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
        //success
        sender.removeTagView(tagView)
        
        for (index, tags) in self.tagsData.enumerated() {
            if tags.id == id {
                self.tagsData.remove(at: index)
            }
        }
        
        self.viewController?.tableViewTag.beginUpdates()
        self.viewController?.tableViewTag.endUpdates()
        
        if let delegate = self.delegate{
            delegate.updateDataTag(tagsData: self.tagsData)
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

extension FilterByTagCell : TagListViewDelegate {
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

extension FilterByTagCell : UITableViewDelegate, UITableViewDataSource {
    
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
        
        let tag = TagsModel(id: data.id, name: data.name)
        
         self.tagsData.append(tag)
         self.tagListView.addTag(tag.name)
         
         self.viewController?.tableViewTag.beginUpdates()
         self.viewController?.tableViewTag.endUpdates()
        
        self.tableView.isHidden = true
        self.tvAddNewTags.text = ""
        self.endEditing(true)
        
        if let delegate = self.delegate{
            delegate.updateDataTag(tagsData: self.tagsData)
        }
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

extension FilterByTagCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.heightTableViewCons.constant = 150
        self.viewController?.tableViewTag.beginUpdates()
        self.viewController?.tableViewTag.endUpdates()
        self.getListTagsSuggestion()
        
        self.tableView.isHidden = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.heightTableViewCons.constant = 0
        self.viewController?.tableViewTag.beginUpdates()
        self.viewController?.tableViewTag.endUpdates()
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
