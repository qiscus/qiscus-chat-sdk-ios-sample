//
//  DetailConversationChatRoomVC.swift
//  Example
//
//  Created by arief nur putranto on 07/12/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage
import QiscusCore

class DetailConversationChatRoomVC: UIViewController {
    @IBOutlet weak var lbHeader: UILabel!
    @IBOutlet weak var lbNameChannel: UILabel!
    @IBOutlet weak var ivChannel: UIImageView!
    @IBOutlet weak var heightHeaderConst: NSLayoutConstraint! //default 40
    @IBOutlet weak var heightBottomConst: NSLayoutConstraint! //default 20
    @IBOutlet weak var tableView: UITableView!
    var titleText = ""
    var isOngoing : Bool = true
    var channelName = ""
    var avatarChannel = UIImage()
    var customerRoom : CustomerRoom? = nil
    var contactID = 0
    var qComment = [QCommentContact]()
    var loadMore = true
    var stillLoading = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupAPIChatRoom()
    }


    func setupUI(){
        self.title = self.titleText
        let backButton = self.backButton(self, action: #selector(DetailConversationChatRoomVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        //tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "DetailConversationCell", bundle: nil), forCellReuseIdentifier: "DetailConversationCellIdentifire")
        self.tableView.register(UINib(nibName: "LoadMoreDetailConversationCell", bundle: nil), forCellReuseIdentifier: "LoadMoreDetailConversationCellIdentifier")
        
        if isOngoing == true {
            self.heightHeaderConst.constant = 40
            self.heightBottomConst.constant = 20
        } else {
            self.heightHeaderConst.constant = 0
            self.heightBottomConst.constant = 0
            
            let customView = UIView(frame: CGRect(x: 24, y: 25, width: tableView.frame.width - 100, height: 80))
            customView.backgroundColor = UIColor.clear
            let titleLabel = UILabel(frame: CGRect(x:10,y: 25 ,width:customView.frame.width, height:40))
            titleLabel.numberOfLines = 1
            titleLabel.backgroundColor = UIColor(red: 228/255, green: 248/255, blue: 244/255, alpha: 1)
            titleLabel.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.text  = "End of conversation"
            titleLabel.textAlignment = .center
            customView.layer.cornerRadius = 8
            titleLabel.layer.cornerRadius = 8
            customView.addSubview(titleLabel)
            
            self.tableView.tableFooterView = customView
        }
        
        self.lbNameChannel.text = self.channelName
        self.ivChannel.image = self.avatarChannel
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
    
    func setupAPIChatRoom(lastCommentID : String = ""){
        self.stillLoading = true
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        guard let roomID = self.customerRoom?.roomId else {
            return
        }
        
        var url = "\(QiscusHelper.getBaseURL())/api/v2/contacts/\(self.contactID)/conversations/\(roomID)?token=\(token)"
        
        if !lastCommentID.isEmpty {
            url = "\(QiscusHelper.getBaseURL())/api/v2/contacts/\(self.contactID)/conversations/\(roomID)?token=\(token)?&last_comment_id=\(lastCommentID)"
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    self.stillLoading = false
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.setupAPIChatRoom()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let comments = payload["results"]["comments"].array {
                        for comment in comments {
                            let data = QCommentContact(json: comment)
                            if data.type != "system_event" {
                                self.qComment.append(data)
                            }
                        }
                        
                        let allObjs = self.qComment.sorted { (k1, k2) in
                            return k1.id < k2.id
                        }
                        self.qComment = allObjs
                        if comments.count == 20 {
                            self.loadMore = true
                        }else{
                            self.loadMore = false
                        }
                    }else{
                        self.loadMore = false
                    }
                    self.stillLoading = false
                    self.tableView.reloadData()
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.stillLoading = false
            } else {
                //failed
                self.stillLoading = false
            }
        }
    }
    
    @objc func handleLoadMore(sender: UIButton){
        if self.loadMore == true{
            if self.stillLoading == true {
                return
            }else{
                self.setupAPIChatRoom(lastCommentID: self.qComment.first!.id)
            }
        }
    }
   
}

extension DetailConversationChatRoomVC: UITableViewDataSource, UITableViewDelegate {
    @objc func actionVideoImageAudio(_ recognizer: UITapGestureRecognizer) {
        var check = 0
        if loadMore == true {
            check = 1
        }
        let data = self.qComment[recognizer.view!.tag - check]
        
        guard let payload = data.payload else { return }
        if let fileName = payload["file_name"] as? String{
            if let url = payload["url"] as? String {
                
                let preview = ChatPreviewDocVC()
                preview.fileName = fileName
                preview.url = url
                preview.roomName = "File Preview"
                let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                backButton.tintColor = UIColor.white
                
                self.navigationController?.navigationItem.backBarButtonItem = backButton
                self.navigationController?.pushViewController(preview, animated: true)
            }
        }
    }
    
    @objc func actionTextVideoImage(_ recognizer: UITapGestureRecognizer) {
        var check = 0
        if loadMore == true {
            check = 1
        }
        let data = self.qComment[recognizer.view!.tag - check]
        if data.message.contains("[sticker]"){
            var fileImage = data.getStickerURL(message: data.message)
            
            if fileImage.isEmpty == true {
                fileImage = "https://"
            }
            
            let preview = ChatPreviewDocVC()
            preview.fileName = fileImage
            preview.url = fileImage
            preview.roomName = "Sticker Preview"
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            backButton.tintColor = UIColor.white
            self.navigationController?.navigationItem.backBarButtonItem = backButton
            self.navigationController?.pushViewController(preview, animated: true)
        }else{
            var fileImage = data.getAttachmentURL(message: data.message)
            
            if fileImage.isEmpty {
                fileImage = "https://"
            }
            
            let preview = ChatPreviewDocVC()
            preview.fileName = fileImage
            preview.url = fileImage
            preview.roomName = "URL Preview"
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            backButton.tintColor = UIColor.white
            self.navigationController?.navigationItem.backBarButtonItem = backButton
            self.navigationController?.pushViewController(preview, animated: true)
            
            
        }
    }
    
    @objc func actionDirectURL(_ recognizer: UITapGestureRecognizer) {
        var check = 0
        if loadMore == true {
            check = 1
        }
        let data = self.qComment[recognizer.view!.tag - check]
        
        let webView = ChatPreviewDocVC()
        webView.accountLinking = true
        webView.roomName = "URL Preview"
        webView.accountData = JSON(data.payload)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backButton.tintColor = UIColor.white
        
        self.navigationController?.navigationItem.backBarButtonItem = backButton
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    @objc func actionDocument(_ recognizer: UITapGestureRecognizer) {
        var check = 0
        if loadMore == true {
            check = 1
        }
        let data = self.qComment[recognizer.view!.tag - check]
        guard let payload = data.payload else { return }
        if let fileName = payload["file_name"] as? String{
            if let url = payload["url"] as? String {
                if url.contains(".oga") == true {
                    let preview = PlayOgaVC()
                    preview.mediaURL = url
                    let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    backButton.tintColor = UIColor.white
                    self.navigationController?.navigationItem.backBarButtonItem = backButton
                    self.navigationController?.pushViewController(preview, animated: true)
                } else {
                    let preview = ChatPreviewDocVC()
                    preview.fileName = fileName
                    preview.url = url
                    let urlCheck = URL(string:url) ?? URL(string: "https://")
                    if (urlCheck!.containsAudio == true){
                        preview.roomName = "Audio Preview"
                    }else{
                        preview.roomName = "Document Preview"
                    }
                   
                    let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    backButton.tintColor = UIColor.white
                    self.navigationController?.navigationItem.backBarButtonItem = backButton
                    self.navigationController?.pushViewController(preview, animated: true)
                }
                
               
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        var count = qComment.count
        if loadMore == true {
            count = count + 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if loadMore == true {
            if indexPath.row == 0 {
                let headerCell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreDetailConversationCellIdentifier") as! LoadMoreDetailConversationCell

                headerCell.btLoadMore.addTarget(self, action:#selector(self.handleLoadMore(sender:)), for: .touchUpInside)
                
                return headerCell
            }else{
                return detailConversationCell(indexPath: indexPath, loadMore : true)
            }
        }else{
            return detailConversationCell(indexPath: indexPath, loadMore : false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    private func detailConversationCell(indexPath: IndexPath, loadMore : Bool = false)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailConversationCellIdentifire", for: indexPath) as! DetailConversationCell
        
        var check = 0
        if loadMore == true {
            check = 1
        }
        let data = self.qComment[indexPath.row - check]
        cell.dataMessage = data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: data.timestamp) {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "dd/MM/yy"
            let dateString = dateFormatter2.string(from: date)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: date)
            
            if Calendar.current.isDateInToday(date){
                cell.lbDate.text = "Today"
            }else if Calendar.current.isDateInYesterday(date) {
                cell.lbDate.text = "Yesterday"
            }else{
                cell.lbDate.text = "\(dateString)"
            }
            
            cell.lbTime.text = "\(timeString)"
        }else{
            cell.lbDate.text = ""
            cell.lbTime.text = ""
        }
        
        let attributedString = NSMutableAttributedString(string: data.message)
        attributedString.setAttributes([:], range: NSRange(0..<data.message.count))
        
        cell.lbMessage.attributedText = attributedString
        cell.lbMessage.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
        cell.lbMessage.text = data.message
        cell.lbMessage.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)]
        
        
        
       
        cell.lbMessage.tag = indexPath.row
        cell.lbMessage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: nil)
        tap.numberOfTapsRequired = 1
        cell.lbMessage.addGestureRecognizer(tap)
        
        cell.lbName.text = data.username
        
        cell.viewReply.isHidden = true
        cell.heightReplyViewCons.constant = 0
        
        if let avatar = data.userAvatarUrl {
            if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true || avatar.absoluteString.contains("https://latest-multichannel.qiscus.com/img/default_avatar.svg"){
                cell.ivAvatar.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
               
            }else if avatar.absoluteString.contains(".png") == true || avatar.absoluteString.contains(".jpg") == true || avatar.absoluteString.contains(".jpeg") == true{
                cell.ivAvatar.af_setImage(withURL: avatar)
            }else{
                cell.ivAvatar.af_setImage(withURL: avatar)
            }
        }else{
            cell.ivAvatar.af_setImage(withURL: URL(string:"https://")!)
        }
        
        if let userExtras = data.userExtras {
            let json = JSON(userExtras)
            let isCustomer = json["is_customer"].bool ?? true
            
            let type = json["type"].string ?? ""
            
            if type == "agent" || type == "admin" || type == "spv" {
                cell.viewBackgroundMessage.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            } else if isCustomer == true || type == "customer"{
                cell.viewBackgroundMessage.backgroundColor = UIColor.clear
                cell.viewBackgroundMessage.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
                cell.viewBackgroundMessage.layer.cornerRadius = 8
                cell.viewBackgroundMessage.layer.borderWidth = 1
                cell.viewBackgroundMessage.layer.borderColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1).cgColor
            } else {
                cell.viewBackgroundMessage.backgroundColor = UIColor.clear
                cell.viewBackgroundMessage.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
                cell.viewBackgroundMessage.layer.cornerRadius = 8
                cell.viewBackgroundMessage.layer.borderWidth = 1
                cell.viewBackgroundMessage.layer.borderColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1).cgColor
            }

        }
        
        if data.type == "text"{
            if data.message.contains("[/file]") == true{
                var ext = data.getAttachmentURL(message: data.message)
                if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                    
                    cell.lbMessage.attributedText = NSAttributedString(string: "Sent an picture", attributes:[ NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionTextVideoImage(_:)))
                    tap.numberOfTapsRequired = 1
                    cell.lbMessage.tag = indexPath.row
                    cell.lbMessage.isUserInteractionEnabled = true
                    cell.lbMessage.addGestureRecognizer(tap)
                }
            } else if data.message.contains("[/sticker]") == true{
                cell.lbMessage.attributedText = NSAttributedString(string: "Sent a stiker", attributes:[ NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionTextVideoImage(_:)))
                tap.numberOfTapsRequired = 1
                cell.lbMessage.tag = indexPath.row
                cell.lbMessage.isUserInteractionEnabled = true
                cell.lbMessage.addGestureRecognizer(tap)
            }else{
                
            }
        } else if data.type == "location"{
            cell.lbMessage.text = "Sent a location"
            cell.lbMessage.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
        } else if data.type == "card"{
            cell.lbMessage.text = "Sent a predefined text"
            cell.lbMessage.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
        } else if data.type == "carousel"{
            cell.lbMessage.text = "Sent a carousel text"
            cell.lbMessage.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
        } else if data.type == "buttons"{
            cell.lbMessage.text = "Sent a button text"
            cell.lbMessage.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
        } else if data.type == "button_postback_response"{
            cell.lbMessage.attributedText = NSAttributedString(string: "Sent a document", attributes:[ NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionDirectURL(_:)))
            tap.numberOfTapsRequired = 1
            cell.lbMessage.tag = indexPath.row
            cell.lbMessage.isUserInteractionEnabled = true
            cell.lbMessage.addGestureRecognizer(tap)
            
        } else if data.type == "reply"{
            //TODO
            if let payload = data.payload {
                cell.viewReply.isHidden = false
                cell.heightReplyViewCons.constant = 40
                
                
                var text = payload["replied_comment_message"] as? String
                if text == ""{
                    text = "this message has been deleted"
                }
                var replyType = data.replyType(message: text!)
                var stringReplyType = ""
                if replyType == .text  {
                    switch payload["replied_comment_type"] as? String {
                    case "location":
                        replyType = .location
                        break
                    case "contact_person":
                        replyType = .contact
                        break
                    case "button_postback_response":
                        replyType = .other
                        stringReplyType = "button_postback_response"
                        break
                    case "buttons":
                        replyType = .other
                        stringReplyType = "buttons"
                        break
                    case "card":
                        replyType = .other
                        stringReplyType = "card"
                        break
                    case "carousel":
                        replyType = .other
                        stringReplyType = "carousel"
                        break
                    default:
                        break
                    }
                }
                var username = payload["replied_comment_sender_username"] as? String
                let repliedEmail = payload["replied_comment_sender_email"] as? String
                
                switch replyType {
                case .text:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = text
                    cell.lbMessage.text = data.message
                case .image:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent an image"
                    cell.lbMessage.text = data.message
                case .video:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent a video"
                    cell.lbMessage.text = data.message
                case .audio:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent an audio"
                    cell.lbMessage.text = data.message
                case .document:
                    //pdf
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent a document"
                    cell.lbMessage.text = data.message
                case .location:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent a location"
                    cell.lbMessage.text = data.message
                case .contact:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent a contact"
                    cell.lbMessage.text = data.message
                case .file:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent a file"
                    cell.lbMessage.text = data.message
                case .other:
                    cell.lbReplySender.text = username
                    cell.lbReplymessage.text = "Sent a document"
                    if stringReplyType == "buttons"{
                        cell.lbReplymessage.text = "Sent a button text"
                    }else if stringReplyType == "card"{
                        cell.lbReplymessage.text = "Sent a predefined text"
                    }else if stringReplyType == "carousel"{
                        cell.lbReplymessage.text = "Sent a carousel text"
                    }
                    
                    cell.lbMessage.text = data.message
                }
            }
            
        } else if  data.type == "file_attachment" {
            if let payload = data.payload {
                if let url = payload["url"] as? String {
                    var caption = ""
                    if let captionData = payload["caption"] as? String {
                        caption = captionData
                    }
                    let ext = data.fileExtension(fromURL:url)
                    let urlFile = URL(string: url) ?? URL(string: "https://")
                    var isImage = false
                    var isVideo = false
                    
                    if ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif"){
                        isImage = true
                    }
                    
                    if let messageExtras = data.extras {
                        let dataJson = JSON(messageExtras)
                        let type = dataJson["type"].string ?? ""
                        
                        if !type.isEmpty{
                            if type.lowercased() ==  "image_story_reply" ||  type.lowercased() == "image" {
                                isImage = true
                            }else if (type.lowercased() == "video_story_reply"){
                                isImage = false
                            }else if (type.lowercased() == "story_mention"){
                                isImage = false
                            }else if (type.lowercased() == "share"){
                                isImage = false
                            }else if (type.lowercased() == "video"){
                                isVideo = true
                            }
                        }
                    }
                    
                    
                    if(isImage == true) {
                        //image
                        cell.lbMessage.attributedText = NSAttributedString(string: "Sent an picture", attributes:[ NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                        
                      
                        cell.lbMessage.tag = indexPath.row
                        cell.lbMessage.isUserInteractionEnabled = true
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionVideoImageAudio(_:)))
                        tap.numberOfTapsRequired = 1
                        cell.lbMessage.addGestureRecognizer(tap)
                    }else if(urlFile?.containsVideo == true || isVideo == true ) {
                        //video
                        cell.lbMessage.attributedText = NSAttributedString(string: "Sent a video", attributes:[ NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                        
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionVideoImageAudio(_:)))
                        tap.numberOfTapsRequired = 1
                        cell.lbMessage.tag = indexPath.row
                        cell.lbMessage.isUserInteractionEnabled = true
                        cell.lbMessage.addGestureRecognizer(tap)
                    }else if (urlFile?.containsAudio == true){
                        //file
                        cell.lbMessage.attributedText = NSAttributedString(string: "Sent an audio", attributes:[ NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                        
                       
                        cell.lbMessage.tag = indexPath.row
                        cell.lbMessage.isUserInteractionEnabled = true
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionDocument(_:)))
                        tap.numberOfTapsRequired = 1
                        cell.lbMessage.addGestureRecognizer(tap)
                    }else{
                        //file
                        cell.lbMessage.attributedText = NSAttributedString(string: "Sent a document", attributes:[ NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineColor: ColorConfiguration.defaultColorTosca,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                        
                        
                        cell.lbMessage.tag = indexPath.row
                        cell.lbMessage.isUserInteractionEnabled = true
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.actionDocument(_:)))
                        tap.numberOfTapsRequired = 1
                        cell.lbMessage.addGestureRecognizer(tap)
                    }
                }else{
                    //other text
                    cell.lbMessage.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
                    cell.lbMessage.text = data.message
                }
            }else{
                //text
                cell.lbMessage.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
                cell.lbMessage.text = data.message
            }
            
        }
        
        return cell
    }
    
}
