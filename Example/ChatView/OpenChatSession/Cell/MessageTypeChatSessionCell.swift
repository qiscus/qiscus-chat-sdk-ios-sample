//
//  MessageTypeChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 02/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class MessageTypeChatSessionCell: UITableViewCell {

    @IBOutlet weak var viewTableView: UIView!
    @IBOutlet weak var viewTF: UIView!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfMessageType: UITextField!
    var vc : NewOpenChatSessionWAVC? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewTF.layer.shadowColor = UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 0.15).cgColor
        self.viewTF.layer.shadowOffset = CGSize(width: -3, height: 5)
        self.viewTF.layer.shadowOpacity = 1
        self.viewTF.layer.shadowRadius = 14
        self.viewTF.layer.cornerRadius = 8
        
        self.viewTableView.layer.shadowColor = UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 0.15).cgColor
        self.viewTableView.layer.shadowOffset = CGSize(width: -3, height: 5)
        self.viewTableView.layer.shadowOpacity = 1
        self.viewTableView.layer.shadowRadius = 14
        self.viewTableView.layer.cornerRadius = 8
        
        self.tfMessageType.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 40, height: 20))
        let image = UIImage(named: "ic_drop_down")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = UIColor.lightGray
        self.tfMessageType.rightView = imageView
        
         //tableView
        self.viewTableView.layer.cornerRadius = 8
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "OpenSessionWACell", bundle: nil), forCellReuseIdentifier: "OpenSessionWACellIdentifire")
        self.tableView.reloadData()
        
        self.tableViewHeightCons.constant = 0
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectMessageTypeAction(_ sender: Any) {
        self.updateTableView()
    }
    
    func updateTableView(){
        if self.tableViewHeightCons.constant == 100 {
            self.tableViewHeightCons.constant = 0
        }else{
            self.tableViewHeightCons.constant = 100
        }
        
        //reload master tableView
        self.vc?.reloadTableView()
    }
    
}

extension MessageTypeChatSessionCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSessionWACellIdentifire", for: indexPath) as! OpenSessionWACell
        if indexPath.row == 0 {
            cell.lbMessage.text = "24 Hours Message Template"
        }else{
            cell.lbMessage.text = "Broadcast Template Message"
        }
       
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.tfMessageType.text = "24 Hours Message Template"
            self.vc?.messageTypeID = 1
            self.vc?.isSearchTemplateActive = false
            self.vc?.dataHSMBroadCastTemplateFromSearch.removeAll()
            self.vc?.dataHSMBroadCastTemplate.removeAll()
            self.vc?.dataBroadcastTemplateSelected = ""
            self.vc?.resetTemplate = true
            self.vc?.isReloadTableViewFromHeaderBodyButton = true
            self.vc?.isFirstTimeLoadListHeaderBodyButton = true
            self.vc?.isReloadTableViewFromTemplatePreview = true
            self.vc?.dataBroadCastLanguageSelected = ""
            self.vc?.showErrorAlert = false
            self.vc?.getTemplateHSM(channelID: self.vc?.channelID ?? 0)
        }else{
            self.tfMessageType.text = "Broadcast Template Message"
            self.vc?.messageTypeID = 2
            self.vc?.getTemplateHSMBroadcasts()
        }
        self.updateTableView()
        
    }
    
}


