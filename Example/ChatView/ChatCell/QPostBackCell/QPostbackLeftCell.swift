//
//  QPostbackLeftCell.swift
//  Pods
//
//  Created by asharijuang on 18/10/18.
//

import UIKit
import QiscusCore
import SwiftyJSON
import AlamofireImage

class QPostbackLeftCell: UIBaseChatCell {
    let maxWidth:CGFloat = 0.7 * QiscusHelper.screenWidth()
    let minWidth:CGFloat = 0.7 * QiscusHelper.screenWidth()
    let buttonWidth:CGFloat = 0.7 * QiscusHelper.screenWidth() + 10
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonsView: UIStackView!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var ivAvatarUser: UIImageView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    var delegateChat : UIChatViewController? = nil
    var isQiscus : Bool = false
    var message: CommentModel? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setMenu(isQiscus: false)
       textView.contentInset = UIEdgeInsets.zero
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMassage(_:)),
                                               name: Notification.Name("selectedCell"),
                                               object: nil)
    }
    
    @objc func handleMassage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            let commentId = json["commentId"].string ?? "0"
            if let message = self.message {
                if message.id == commentId {
                    self.contentView.backgroundColor = UIColor(red:39/255, green:177/255, blue:153/255, alpha: 0.1)
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu(isQiscus: false)
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.message = message
        self.contentView.backgroundColor = UIColor.clear
        self.setupBalon()
        
       self.userNameLabel.text = message.username
        
        self.ivAvatarUser.layer.cornerRadius = self.ivAvatarUser.frame.size.width / 2
        self.ivAvatarUser.clipsToBounds = true
        
        if let avatar = message.userAvatarUrl {
            if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true || avatar.absoluteString.contains("https://latest-multichannel.qiscus.com/img/default_avatar.svg"){
               self.ivAvatarUser.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
            }else{
                self.ivAvatarUser.af_setImage(withURL: message.userAvatarUrl ?? URL(string: "http://")!)
            }
        }else{
            self.ivAvatarUser.af_setImage(withURL: message.userAvatarUrl ?? URL(string: "http://")!)
        }
        
        balloonView.image = getBallon()
        
        for view in buttonsView.subviews{
            view.removeFromSuperview()
        }
        
        dateLabel.text = self.hour(date: message.date())
        balloonView.tintColor = ColorConfiguration.leftBaloonTextColor

        if self.comment!.type == "buttons" {
            var i = 0
            
            guard let dataPayload = message.payload else {
                return
            }
            let data = JSON(dataPayload)
            
            let message = data["text"].string ?? ""
            
            var textAttribute:[NSAttributedString.Key: Any]{
                get{
                    var foregroundColorAttributeName = ColorConfiguration.leftBaloonTextColor
                    return [
                        NSAttributedString.Key.foregroundColor: foregroundColorAttributeName,
                        NSAttributedString.Key.font: ChatConfig.chatFont
                    ]
                }
            }
            
            var attributedText = NSMutableAttributedString(string: message)
            let allRange = (message as NSString).range(of: message)
            attributedText.addAttributes(textAttribute, range: allRange)
            
            self.textView.attributedText = attributedText
            self.textView.linkTextAttributes = self.linkTextAttributes
            
            let buttonsPayload = data["buttons"].arrayValue
            self.buttonsViewHeight.constant = CGFloat(buttonsPayload.count * 35)
            self.layoutIfNeeded()
            for buttonsData in buttonsPayload{
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.buttonsView.frame.size.width, height: 32))
                button.backgroundColor = ColorConfiguration.defaultColorTosca
                button.setTitle(buttonsData["label"].stringValue, for: .normal)
                button.setTitleColor(ColorConfiguration.leftBaloonTextColor, for: .normal)
                button.tag = i
                button.addTarget(self, action:#selector(self.postback(sender:)), for: .touchUpInside)
                self.buttonsView.addArrangedSubview(button)
                i += 1
            }
        }else{
            guard let dataPayload = message.payload else {
                return
            }
            
            let data = JSON(dataPayload)
            let paramData = data["params"]

            self.buttonsViewHeight.constant = CGFloat(35)
            self.layoutIfNeeded()

            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.buttonsView.frame.size.width, height: 32))
            button.backgroundColor = ColorConfiguration.defaultColorTosca
            button.setTitle(paramData["button_text"].stringValue, for: .normal)
            button.setTitleColor(ColorConfiguration.leftBaloonTextColor, for: .normal)
            button.tag = 2222
            button.addTarget(self, action:#selector(self.accountLinking(sender:)), for: .touchUpInside)

            self.buttonsView.addArrangedSubview(button)
        }
    }
    
    func setupBalon(){
        
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
    
    @objc func postback(sender:UIButton){
        guard let dataPayload = self.comment?.payload else {
            return
        }
        let data = JSON(dataPayload)
        let allData =  data["buttons"].arrayValue
        if allData.count > sender.tag {
            self.didTapActionButton(withData: allData[sender.tag])
            
        }
    }
    
    @objc func accountLinking(sender:UIButton){
        guard let dataPayload = self.comment?.payload else {
            return
        }
        let data = JSON(dataPayload)
        self.didTapAccountLinking(data: data)
    }
    
    func didTapActionButton(withData data:JSON){
        let postbackType = data["type"].stringValue
        let payload = data["payload"]
        switch postbackType {
        case "link":
            let urlString = payload["url"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let urlArray = urlString.components(separatedBy: "/")
            func openInBrowser(){
                if let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
            }
            
            if urlArray.count > 2 {
                if urlArray[2].lowercased().contains("instagram.com") {
                    var instagram = "instagram://app"
                    if urlArray.count == 4 || (urlArray.count == 5 && urlArray[4] == ""){
                        let usernameIG = urlArray[3]
                        instagram = "instagram://user?username=\(usernameIG)"
                    }
                    if let instagramURL =  URL(string: instagram) {
                        if UIApplication.shared.canOpenURL(instagramURL) {
                            UIApplication.shared.openURL(instagramURL)
                        }else{
                            openInBrowser()
                        }
                    }
                }else{
                    openInBrowser()
                }
            }else{
                openInBrowser()
            }
            
            
            break
        default:
            let text = data["label"].stringValue
            let type = "text"
            if let room = self.delegateChat?.room {
                
                let comment = CommentModel()
                comment.type = type
                comment.message = text
                comment.payload = payload.dictionaryObject
                
                QiscusCore.shared.sendMessage(roomID: room.id, comment: comment, onSuccess: { (commentModel) in
                    //success
                }, onError: { (error) in
                    
                })
                
            }
            break
        }
        
    }
    
    func didTapAccountLinking(data:JSON){
        let webView = ChatPreviewDocVC()
        webView.accountLinking = true
        webView.accountData = data
        
        if let vc = delegateChat {
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            backButton.tintColor = UIColor.white
            
            vc.navigationItem.backBarButtonItem = backButton
            vc.navigationController?.pushViewController(webView, animated: true)
        }
       
    }
    
}
