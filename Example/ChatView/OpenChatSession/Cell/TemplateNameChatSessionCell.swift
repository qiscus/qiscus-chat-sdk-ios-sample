//
//  TemplateNameChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 09/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class TemplateNameChatSessionCell: UITableViewCell {

    @IBOutlet weak var viewOfTemplateName: UIView!
    @IBOutlet weak var viewSearchAndTableView: UIView!
    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    @IBOutlet weak var heightOfViewSearchAndList: NSLayoutConstraint!
    @IBOutlet weak var tableViewTemplateName: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tfSelectTemplateName: UITextField!
    var data = [BroadcastTemplateModel]()
    var vc : NewOpenChatSessionWAVC? = nil
    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewOfTemplateName.layer.shadowColor = UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 0.15).cgColor
        self.viewOfTemplateName.layer.shadowOffset = CGSize(width: -3, height: 5)
        self.viewOfTemplateName.layer.shadowOpacity = 1
        self.viewOfTemplateName.layer.shadowRadius = 14
        self.viewOfTemplateName.layer.cornerRadius = 8
        
        
        self.viewSearchAndTableView.layer.shadowColor = UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 0.15).cgColor
        self.viewSearchAndTableView.layer.shadowOffset = CGSize(width: -3, height: 5)
        self.viewSearchAndTableView.layer.shadowOpacity = 1
        self.viewSearchAndTableView.layer.shadowRadius = 14
        self.viewSearchAndTableView.layer.cornerRadius = 8
        
        self.tfSelectTemplateName.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 40, height: 20))
        let image = UIImage(named: "ic_drop_down")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = UIColor.lightGray
        self.tfSelectTemplateName.rightView = imageView
        
        self.viewSearch.layer.borderWidth = 1
        self.viewSearch.layer.borderColor = UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha:1.0).cgColor
        self.viewSearch.layer.cornerRadius = 4
        
        //textField
        self.tfSearch.delegate = self
        
        //tableView
       self.tableViewTemplateName.dataSource = self
       self.tableViewTemplateName.delegate = self
       self.tableViewTemplateName.tableFooterView = UIView()
       self.tableViewTemplateName.register(UINib(nibName: "OpenSessionWAListCell", bundle: nil), forCellReuseIdentifier: "OpenSessionWAListCellIdentifire")
    }

    @IBAction func actionSelectTemplateName(_ sender: Any) {
        
        self.showHideTableView()
        self.tableViewTemplateName.reloadData()
        self.vc?.reloadTableView()
    }
    
    func showHideTableView(){
        if self.heightOfViewSearchAndList.constant == 0 {
            var count = self.data.count
            if self.data.count >= 5 {
                count = 5
            }
            self.heightOfTableView.constant = CGFloat((count * 48))
            self.heightOfViewSearchAndList.constant = CGFloat((80 + (count * 48)))
            self.viewSearch.alpha = 1
            self.tableViewTemplateName.alpha = 1
        }else{
            self.heightOfTableView.constant = 0
            self.heightOfViewSearchAndList.constant = 0
            self.viewSearch.alpha = 0
            self.tableViewTemplateName.alpha = 0
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(data : [BroadcastTemplateModel]? = nil, selectedTemplate : String = ""){
        if let data = data{
            self.data = data
            
            if self.vc?.isSearchTemplateActive == true{
                if self.tableViewTemplateName.alpha == 1{
                    var count = self.data.count
                    if count >= 5 {
                        count = 5
                    }else if count == 0 {
                        count = 1
                    }
                    
                    self.heightOfTableView.constant = CGFloat((count * 48))
                    self.heightOfViewSearchAndList.constant = CGFloat((80 + (count * 48)))
                }
                
            }else{
                self.tfSearch.text = ""
                if selectedTemplate.isEmpty == true{
                    self.tfSelectTemplateName.text = data.first?.name
                    self.vc?.dataBroadcastTemplateSelected = data.first?.name ?? ""
                }else{
                    self.tfSelectTemplateName.text = selectedTemplate
                }
                
                if data.count >= 1 &&  self.tableViewTemplateName.alpha == 1{
                    var count = self.data.count
                    if self.data.count >= 5 {
                        count = 5
                    }
                    self.heightOfTableView.constant = CGFloat((count * 48))
                    self.heightOfViewSearchAndList.constant = CGFloat((80 + (count * 48)))
                }
            }
            
            self.tableViewTemplateName.reloadData()
            
            
        }
    }
    
    func resetTemplate(){
        self.heightOfTableView.constant = 0
        self.heightOfViewSearchAndList.constant = 0
        self.viewSearch.alpha = 0
        self.tableViewTemplateName.alpha = 0
        
        self.vc?.dataBody.removeAll()
        self.vc?.dataHeader.removeAll()
        self.vc?.dataButton.removeAll()
        self.vc?.isReloadTableViewFromHeaderBodyButton = true
        self.vc?.isFirstTimeLoadListHeaderBodyButton = true
        self.vc?.isReloadTableViewFromTemplatePreview = true
        self.vc?.dataBroadCastLanguageSelected = ""
    }
    
}


extension TemplateNameChatSessionCell : UITextFieldDelegate {
    
    func throttleGetList(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getList), object: nil)
        perform(#selector(self.getList), with: nil, afterDelay: 1)

    }
    
    @objc func getList(){
        
        if self.tfSearch.text?.isEmpty == true{
            self.vc?.isSearchTemplateActive = false
            self.vc?.reloadTableView()
        }else{
            self.vc?.isSearchTemplateActive = true
            self.vc?.getTemplateHSMBroadcasts(search: self.tfSearch.text ?? "")
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
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
        
        if textField.text != nil {
            self.throttleGetList()
        }
        
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}

extension TemplateNameChatSessionCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.data.count == 0 && self.vc?.isSearchTemplateActive == true {
            return 1
        }else{
            return self.data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSessionWAListCellIdentifire", for: indexPath) as! OpenSessionWAListCell
        
        if self.data.count == 0 {
            cell.lbMessage.text = "No result for this keyword"
            cell.lbMessage.font = UIFont.italicSystemFont(ofSize: 14)
        }else{
            cell.lbMessage.text = self.data[indexPath.row].name
        }
        
        
        
        return cell
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.data.count == 0 && self.vc?.isSearchTemplateActive == true {
            
        }else{
            self.vc?.dataBroadcastTemplateSelected = self.data[indexPath.row].name
            self.tfSelectTemplateName.text = self.data[indexPath.row].name
            
            self.resetTemplate()
            
            self.tableViewTemplateName.reloadData()
            self.vc?.reloadTableView()
        }
      
    }
    
}

