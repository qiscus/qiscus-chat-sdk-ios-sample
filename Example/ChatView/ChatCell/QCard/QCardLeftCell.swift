//
//  QCardLeftCell.swift
//  Pods
//
//  Created by asharijuang on 27/11/18.
//

import UIKit
import QiscusCore
import SwiftyJSON
import SDWebImage
import AlamofireImage

class QCardLeftCell: UIBaseChatCell {
    
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
    
    @IBOutlet weak var ivAvatarUser: UIImageView!
    
    
    var buttons = [UIButton]()
    var delegateChat : UIChatViewController? = nil
    var isPublic: Bool = false
    var colorName : UIColor = UIColor.black
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerArea.layer.cornerRadius = 10.0
        self.containerArea.layer.borderWidth = 0.5
        self.containerArea.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1).cgColor
        self.containerArea.clipsToBounds = true
        self.containerArea.layer.zPosition = 999
        self.displayImageView.contentMode = .scaleAspectFill
        self.displayImageView.clipsToBounds = true
        self.cardWidth.constant = QiscusHelper.screenWidth() * 0.70
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(QCardRightCell.cardTapped))
        self.containerArea.addGestureRecognizer(tapRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func setupBalon(){
        self.containerArea.backgroundColor = UIColor.clear
    }
    
    func bindData(message: CommentModel){
        self.setupBalon()
        
        self.ivAvatarUser.layer.cornerRadius = self.ivAvatarUser.frame.size.width / 2
        self.ivAvatarUser.clipsToBounds = true
        
        if let avatar = message.userAvatarUrl {
            if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
                 self.ivAvatarUser.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
            }else{
                self.ivAvatarUser.af_setImage(withURL: message.userAvatarUrl ?? URL(string: "http://")!)
            }
        }else{
            self.ivAvatarUser.af_setImage(withURL: message.userAvatarUrl ?? URL(string: "http://")!)
        }
        
        if(isPublic == true){
            self.userNameLabel.text = message.username
            self.userNameLabel.textColor = colorName
            self.userNameHeightCons.constant = 21
        }else{
            self.userNameLabel.text = ""
            self.userNameHeightCons.constant = 0
        }
        
        
        let payload = JSON(message.payload)
        let title = payload["title"].string ?? ""
        let description = payload["description"].string ?? ""
        let imageURL = payload["image"].string ?? ""
        
        if imageURL != "" {
           
            self.displayImageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            self.displayImageView.sd_setImage(with: URL(string: imageURL)!)
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
        let titleColor = UIColor(red: 101/255, green: 119/255, blue: 183/255, alpha: 1)
        var i = 0
        let buttonWidth = QiscusHelper.screenWidth() * 0.70
        for action in buttonsData{
            let buttonFrame = CGRect(x: 0, y: yPos, width: buttonWidth, height: 45)
            let button = UIButton(frame: buttonFrame)
            button.setTitle(action["label"].stringValue, for: .normal)
            button.tag = i
            
            let borderFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: 0.5)
            let buttonBorder = UIView(frame: borderFrame)
            buttonBorder.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
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
    
}
