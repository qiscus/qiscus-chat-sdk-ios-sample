//
//  PreviewTemplateChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 15/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageWebPCoder
import SwiftyJSON
import QiscusCore

class PreviewTemplateChatSessionCell: UITableViewCell {

    @IBOutlet weak var btPlayVideo: UIButton!
    @IBOutlet weak var heightOfLbFooterTop: NSLayoutConstraint! //default 8
    @IBOutlet weak var heightOfLbFooter: NSLayoutConstraint!
    @IBOutlet weak var heightOfLbHeader: NSLayoutConstraint!
    @IBOutlet weak var heightOfLbHeaderTop: NSLayoutConstraint! //default 12
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var heightOfTableViewPreView: NSLayoutConstraint!
    @IBOutlet weak var tableViewPreview: UITableView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbFooter: UILabel!
    @IBOutlet weak var lbHeader: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var ivPreview: UIImageView!
    @IBOutlet weak var heightOfIvPreview: NSLayoutConstraint!
    
    var data : HSMDetails? = nil
    var vc : NewOpenChatSessionWAVC? = nil
    var isTypeURLandPhoneNumber = false
    var hideTableView = true
    var urlDocVideo = "https://"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewBackground.layer.cornerRadius = 4
        self.ivPreview.layer.cornerRadius = 4
        
        //tableView
       self.tableViewPreview.dataSource = self
       self.tableViewPreview.delegate = self
       self.tableViewPreview.tableFooterView = UIView()
       self.tableViewPreview.register(UINib(nibName: "ListTemplateBroadCastDefaultButtonCell", bundle: nil), forCellReuseIdentifier: "ListTemplateBroadCastDefaultButtonCellIdentifire")
        
        self.tableViewPreview.register(UINib(nibName: "ListTemplateBroadCastURLPhoneNumberButtonCell", bundle: nil), forCellReuseIdentifier: "ListTemplateBroadCastURLPhoneNumberButtonCellIdentifire")
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(data: HSMDetails? = nil){
        self.btPlayVideo.isHidden = true
        if let data = data{
            self.data = data
            if (self.vc?.isSearchTemplateActive == true && self.vc?.dataHSMBroadCastTemplateFromSearch.count == 0) {
                
                //show time
                self.lbTime.text = self.getTimestamp()
                
                //hide image preview
                self.heightOfIvPreview.constant = 0
               
                //hide header
                self.lbHeader.isHidden = true
                self.lbHeader.alpha = 0
                self.heightOfLbHeaderTop.constant = 0
                self.heightOfLbHeader.constant = 0
                
                //hide footer
                self.lbFooter.isHidden = true
                self.lbFooter.alpha = 0
                self.heightOfLbFooter.constant = 0
                self.heightOfLbFooterTop.constant = 0
                
                //show content -
                self.lbContent.text = "-"
                
                //hide tableView
                self.hideTableView = true
                self.tableViewPreview.isHidden = true
                self.heightOfTableViewPreView.constant = 0
                
                self.btPlayVideo.isHidden = true
            }else{
                self.setupUIText()
                
                if data.headerType == "text" {
                    self.heightOfIvPreview.constant = 0
                } else if (data.headerType == "image"){
                    self.heightOfIvPreview.constant = 128
                    self.setupImageVideoDocOther()
                } else if (data.headerType == "video"){
                    self.heightOfIvPreview.constant = 128
                    self.setupImageVideoDocOther(isVideo: true)
                } else if (data.headerType == "document") {
                    self.heightOfIvPreview.constant = 128
                    self.setupImageVideoDocOther()
                } else {
                    //text biasa
                    self.heightOfIvPreview.constant = 0
                }
                
                self.setupTableView()
            }
            
        }
        
       
    }
    
    func setupTableView(){
        if let data = self.data {
            if data.buttons.count != 0 {
                self.hideTableView = false
                self.tableViewPreview.isHidden = false
                
                for i in data.buttons.enumerated() {
                    if i.element.type.lowercased() == "URL".lowercased() || i.element.type.lowercased() == "PHONE_NUMBER".lowercased() {
                        self.heightOfTableViewPreView.constant = CGFloat(data.buttons.count * 44)
                        self.isTypeURLandPhoneNumber = true
                        
                        self.tableViewPreview.layer.cornerRadius = 4
                    }else{
                        self.heightOfTableViewPreView.constant = CGFloat(data.buttons.count * 38)
                        self.isTypeURLandPhoneNumber = false
                    }
                }
            }else{
                self.hideTableView = true
                self.tableViewPreview.isHidden = true
                self.heightOfTableViewPreView.constant = 0
            }
        }
        
        
        
        self.tableViewPreview.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.vc?.isReloadTableViewFromTemplatePreview == true {
                self.vc?.isReloadTableViewFromTemplatePreview = false
                
                self.vc?.reloadTableView()
            }
            
        }
        
    }
    
    func setupUIText(){
        self.lbTime.text = self.getTimestamp()
        
        if let data = self.data {
            let content = data.content
            let header = data.headerContent
            let footer = data.footer
            
            if !content.isEmpty{
                self.lbContent.text = content
            }
            
            if !header.isEmpty{
                //handle header
                self.lbHeader.isHidden = false
                self.lbHeader.alpha = 1
                self.lbHeader.text = header
                self.heightOfLbHeaderTop.constant = 12
                
                self.heightOfLbHeader.constant = header.heightWithConstrainedWidth(width: lbHeader.frame.width, font: UIFont.systemFont(ofSize: 14))
            }else{
                self.lbHeader.isHidden = true
                self.lbHeader.alpha = 0
                self.heightOfLbHeaderTop.constant = 0
                self.heightOfLbHeader.constant = 0
            }
            
            if !footer.isEmpty{
                self.lbFooter.isHidden = false
                self.lbFooter.alpha = 1
                self.lbFooter.text = footer
                
                self.heightOfLbFooter.constant = footer.heightWithConstrainedWidth(width: lbHeader.frame.width, font: UIFont.systemFont(ofSize: 11))
                self.heightOfLbFooterTop.constant = 8
            }else{
                //hide
                self.lbFooter.isHidden = true
                self.lbFooter.alpha = 0
                self.heightOfLbFooter.constant = 0
                self.heightOfLbFooterTop.constant = 0
            }
        }
    }
    
    func setupImageVideoDocOther(isVideo : Bool = false){
        if let data = self.data {
            
            if !data.headerDefaultValue.isEmpty{
                let jsonString = data.headerDefaultValue
                
                let json = JSON(parseJSON: jsonString)
                let type = json["type"].string ?? "video"
                let url = json["\(type)"]["link"].string ?? "https://"
                
                self.heightOfIvPreview.constant = 128
                
                if type.lowercased() == "video".lowercased() || type.lowercased() == "document".lowercased() {
                    self.urlDocVideo = url
                    QiscusCore.shared.getThumbnailURL(url: url) { urlNow in
                        self.ivPreview.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                        self.ivPreview.sd_setImage(with: URL(string: urlNow) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                            if urlPath != nil && uiImage != nil{
                                self.heightOfIvPreview.constant = 128
                                self.ivPreview.af_setImage(withURL: urlPath!)
                            }else{
                                self.heightOfIvPreview.constant = 0
                            }
                        }
                    } onError: { error in
                        self.heightOfIvPreview.constant = 0
                    }
                }else{
                    self.ivPreview.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                    self.ivPreview.sd_setImage(with: URL(string: url) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                        if urlPath != nil && uiImage != nil{
                            self.heightOfIvPreview.constant = 128
                            self.ivPreview.af_setImage(withURL: urlPath!)
                        }else{
                            self.heightOfIvPreview.constant = 0
                        }
                    }
                }
                
               

            }
            
            
        }
        
        if isVideo {
            //show button click video
            self.btPlayVideo.isHidden = false
        }else{
            self.btPlayVideo.isHidden = true
        }
        
    }
    
    func getTimestamp() -> String {
        let date = Date()
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "HH:mm a"
        df.amSymbol = "AM"
        df.pmSymbol = "PM"
        return df.string(from: date)
    }
    
    @IBAction func playVideoAction(_ sender: Any) {
        if let vc = self.vc {
            vc.view.endEditing(true)
            
            let preview = ChatPreviewDocVC()
            preview.fileName = "Template Broadcast Doc Video"
            preview.url = urlDocVideo
            preview.roomName = "Doc & Video Preview"
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            backButton.tintColor = UIColor.white
            
            vc.navigationItem.backBarButtonItem = backButton
            vc.navigationController?.pushViewController(preview, animated: true)
        }
        
        
    }
    
    
}

extension PreviewTemplateChatSessionCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hideTableView == true{
            return 0
        }else{
            return self.data?.buttons.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDefault = tableView.dequeueReusableCell(withIdentifier: "ListTemplateBroadCastDefaultButtonCellIdentifire", for: indexPath) as! ListTemplateBroadCastDefaultButtonCell
        
        let cellURLPhoneNumber = tableView.dequeueReusableCell(withIdentifier: "ListTemplateBroadCastURLPhoneNumberButtonCellIdentifire", for: indexPath) as! ListTemplateBroadCastURLPhoneNumberButtonCell
        
        if self.isTypeURLandPhoneNumber == true {
            if indexPath.row == 0 {
                cellURLPhoneNumber.hideLine = false
                cellURLPhoneNumber.viewLine.isHidden = false
            }else{
                cellURLPhoneNumber.hideLine = true
                cellURLPhoneNumber.viewLine.isHidden = true
            }
            
            let data = self.data?.buttons[indexPath.row]
            
            if data?.type.lowercased() == "URL".lowercased() {
                cellURLPhoneNumber.setup(isTypeUrl: true, title: data?.text ?? "Default")
            }else{
                cellURLPhoneNumber.setup(isTypeUrl: false, title: data?.text ?? "Default")
            }
           
            return cellURLPhoneNumber
        }else{
            cellDefault.setup(title: self.data?.buttons[indexPath.row].text ?? "Default")
            return cellDefault
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
    }
    
}
