//
//  QCardRightCell.swift
//  Pods
//
//  Created by arief nur putranto on 27/11/18.
//

import UIKit
import QiscusCore
import SwiftyJSON
import SDWebImage

class QCardRightCell: UIBaseChatCell {
    
    @IBOutlet weak var ivBot: UIImageView!
    @IBOutlet weak var userNameHeightCons: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var containerArea: UIView!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var buttonContainer: UIStackView!
    
    @IBOutlet weak var buttonAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var cardHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var cardWidth: NSLayoutConstraint!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    var buttons = [UIButton]()
    var delegateChat : UIChatViewController? = nil
    var message: CommentModel? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        self.containerArea.layer.cornerRadius = 10.0
        //self.containerArea.layer.borderWidth = 0.5
        //self.containerArea.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1).cgColor
        self.containerArea.clipsToBounds = true
        self.containerArea.layer.zPosition = 999
        self.displayImageView.contentMode = .scaleAspectFill
        self.displayImageView.clipsToBounds = true
        self.cardWidth.constant = UIScreen.main.bounds.size.width * 0.70
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(QCardRightCell.cardTapped))
        self.containerArea.addGestureRecognizer(tapRecognizer)
        
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
        self.setMenu()
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func setupBalon(message : CommentModel){
        
        self.userNameHeightCons.constant = 0
        self.containerArea.backgroundColor = ColorConfiguration.rightBaloonColor
        
        self.ivBot.alpha = 0
        self.ivBot.isHidden = true
        if let extras = message.extras{
            if !extras.isEmpty{
                let json = JSON.init(extras)
                let action = json["action"]["bot_reply"].bool ?? false
                let actionString = json["action"].string ?? ""
                if action == true || actionString.lowercased() == "bot_reply".lowercased(){
                    self.ivBot.alpha = 1
                    self.ivBot.isHidden = false
                }
            }
        }
    }
    
    func bindData(message: CommentModel){
        self.message = message
        self.contentView.backgroundColor = UIColor.clear
        self.setupBalon(message: message)
        self.status(message: message)
        self.lbTime.text = self.hour(date: message.date())
        let payload = JSON(message.payload)
        let title = payload["title"].string ?? ""
        let description = payload["description"].string ?? ""
        let imageURL = payload["image"].string ?? ""
        
        if imageURL != "" {
            self.displayImageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            self.displayImageView.sd_setImage(with: URL(string: imageURL) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                if urlPath != nil && uiImage != nil{
                    self.displayImageView.af_setImage(withURL: urlPath!)
                }
            }
        }else{
            self.displayImageView.image = nil
        }
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        let buttonsData = payload["buttons"].arrayValue
        
        for currentButton in self.buttons {
            self.buttonContainer.removeArrangedSubview(currentButton)
            currentButton.removeFromSuperview()
        }
        self.buttons = [UIButton]()
        var yPos = CGFloat(0)
        let titleColor = UIColor.white//UIColor(red: 101/255, green: 119/255, blue: 183/255, alpha: 1)
        var i = 0
        let buttonWidth = UIScreen.main.bounds.size.width * 0.70
        for action in buttonsData{
            let buttonFrame = CGRect(x: 0, y: yPos, width: buttonWidth, height: 45)
            let button = UIButton(frame: buttonFrame)
            button.setTitle(action["label"].stringValue, for: .normal)
            button.tag = i
            
            let borderFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: 0.5)
            let buttonBorder = UIView(frame: borderFrame)
            buttonBorder.backgroundColor = UIColor.white
            button.setTitleColor(titleColor, for: .normal)
            button.addSubview(buttonBorder)
            self.buttons.append(button)
            self.buttonContainer.addArrangedSubview(button)
            button.addTarget(self, action: #selector(cardButtonTapped(_:)), for: .touchUpInside)
            
            yPos += 45
            i += 1
        }
        self.buttonAreaHeight.constant = yPos
        self.cardHeight.constant = 90 + yPos
        self.containerArea.layoutIfNeeded()
    }
    
    @objc func cardTapped(){
        let data = self.comment!.payload
        let payload = JSON(data)
        let urlString = payload["url"].string ?? ""
        if urlString != "" {
            if let url = URL(string: urlString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func cardButtonTapped(_ sender: UIButton) {
        let data = self.comment!.payload
        let payload = JSON(data)
        let buttonsData = payload["buttons"].arrayValue
        if buttonsData.count > sender.tag {
            let data = buttonsData[sender.tag]
            self.didTapActionButton(withData: data)
        }
    }
    
    func didTapActionButton(withData data:JSON){
        let postbackType = data["type"]
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
            let type = "button_postback_response"
            
            let message = CommentModel()
            message.message = text
            message.type = type
            message.payload = payload.dictionaryObject
            
            if let room = self.delegateChat?.room {
                QiscusCore.shared.sendMessage(roomID: room.id, comment: message, onSuccess: { (commentModel) in
                    //success
                }, onError: { (error) in
                    
                })
            }
            
            break
        }
    }
    
    func status(message: CommentModel){
        
        switch message.status {
        case .deleted:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            lbTime.text = TextConfiguration.sharedInstance.sendingText
            ivStatus.image = UIImage(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            lbTime.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        }
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
    
    
}
