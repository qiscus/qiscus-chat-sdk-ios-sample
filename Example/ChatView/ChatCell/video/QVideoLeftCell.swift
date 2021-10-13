//
//  QVideoLeftCell.swift
//  Example
//
//  Created by Qiscus on 12/01/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import AlamofireImage
import Alamofire
import SimpleImageViewer
import SDWebImage
import SDWebImageWebPCoder
import SwiftyJSON
import AVKit

class QVideoLeftCell: UIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var ivComment: UIImageView!
    @IBOutlet weak var ivPlay: UIImageView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ivAvatarUser: UIImageView!
    var isPublic: Bool = false
    var menuConfig = enableMenuConfig()
    var colorName : UIColor = UIColor.black
    var isQiscus : Bool = false
    var vc : UIChatViewController? = nil
    var message: CommentModel? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu(isQiscus: isQiscus)
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
         self.ivComment.layer.cornerRadius = 8
        self.ivComment.backgroundColor = UIColor.black
        self.ivComment.isUserInteractionEnabled = true
        let imgTouchEvent = UITapGestureRecognizer(target: self, action: #selector(QVideoLeftCell.playDidTap))
        self.ivComment.addGestureRecognizer(imgTouchEvent)
        
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
        self.setMenu(isQiscus: isQiscus)
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivComment.image = nil // or place holder image
    }
    
    func bindData(message: CommentModel){
        self.message = message
        self.contentView.backgroundColor = UIColor.clear
        self.setupBalon(message : message)
        
        // get image
        self.lbTime.text = self.hour(date: message.date())
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        if let caption = caption {
            if caption.contains("This message was sent on previous session") == true {
                
                let messageALL = caption
                let messageALLArr = messageALL.components(separatedBy: "This message was sent on previous session")
                
                if  messageALLArr.count >= 2 {
                    let message1 = messageALLArr[0] + "&#x2015;&#x2015;&#x2015;<br/><br/><small>"
                    let message1Replace = message1.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                    
                    let message2 =  "This message was sent on previous session" + messageALLArr[1]
                    let message2Replace = message2.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                    let allMesage = message1Replace + message2Replace
                    
                    let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.white];
                    // create the attributed string
                    let attributedString = NSMutableAttributedString(string: allMesage.htmlToString, attributes: attributedStringColor)
                    
                    if let distance = attributedString.string.distance(of: "This message was sent on previous session") {
                        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 10), range: NSRange(location: distance , length: attributedString.string.count - distance - 1))
                    }
                    
                    self.tvContent.attributedText = attributedString
                }else{
                    self.tvContent.text = caption
                }
            }else{
                self.tvContent.text = caption
            }
            
        }else{
            self.tvContent.text = ""
        }
        
        self.tvContent.textColor = ColorConfiguration.leftBaloonTextColor
        
        if let url = payload["url"] as? String {
            var fileImage = url
            if fileImage.isEmpty {
                fileImage = "https://"
            }
            
            self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
            
            QiscusCore.shared.getThumbnailURL(url: fileImage) { (thumbURL) in
                self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.ivComment.sd_setImage(with: URL(string: thumbURL) ?? URL(string: "https://"), placeholderImage: UIImage(named: "ic_image"), options: .highPriority) { (uiImage, error, cache, urlPath) in
                    if urlPath != nil && uiImage != nil{
                        self.ivComment.af_setImage(withURL: urlPath!)
                    }
                }
            } onError: { (error) in
                self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.ivComment.sd_setImage(with: URL(string: url) ?? URL(string: "https://"), placeholderImage: UIImage(named: "ic_image"), options: .highPriority) { (uiImage, error, cache, urlPath) in
                    if urlPath != nil && uiImage != nil{
                        self.ivComment.af_setImage(withURL: urlPath!)
                    }
                }
            }
        }else{
            var fileImage = message.getAttachmentURL(message: message.message)
            
            if fileImage.isEmpty {
                fileImage = "https://"
            }
            
            QiscusCore.shared.getThumbnailURL(url: fileImage) { (thumbURL) in
                self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
                self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.ivComment.sd_setImage(with: URL(string: thumbURL) ?? URL(string: "https://"), placeholderImage: UIImage(named: "ic_image"), options: .highPriority) { (uiImage, error, cache, urlPath) in
                    if urlPath != nil && uiImage != nil{
                        self.ivComment.af_setImage(withURL: urlPath!)
                    }
                }
            } onError: { (error) in
                self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
                self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.ivComment.sd_setImage(with: URL(string: fileImage) ?? URL(string: "https://"), placeholderImage: UIImage(named: "ic_image"), options: .highPriority) { (uiImage, error, cache, urlPath) in
                    if urlPath != nil && uiImage != nil{
                        self.ivComment.af_setImage(withURL: urlPath!)
                    }
                }
            }
        }
        
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
            self.lbName.text = message.username
            self.lbName.textColor = colorName
            lbNameHeight.constant = 21
        }else{
            self.lbName.text = ""
            lbNameHeight.constant = 0
        }
        
    }
    
    private func createVideoThumbnail(from url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSize(width: frame.width, height: frame.height)
        
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    @objc func playDidTap() {
        guard let payload = self.comment?.payload else { return }
        if let fileName = payload["file_name"] as? String{
            if let url = payload["url"] as? String {
                if let vc = self.vc {
                    vc.view.endEditing(true)
                }
                
                let preview = ChatPreviewDocVC()
                preview.fileName = fileName
                preview.url = url
                preview.roomName = "Video Preview"
                let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                backButton.tintColor = UIColor.white
                self.currentViewController()?.navigationItem.backBarButtonItem = backButton
                self.currentViewController()?.navigationController?.pushViewController(preview, animated: true)
            }
        }
       
    }
   
    
    func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
    
    func setupBalon(message: CommentModel){
        //self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        guard let payload = message.payload else {
            self.ivBaloonLeft.tintColor = ColorConfiguration.leftBaloonColor
            return
        }
        let caption = payload["caption"] as? String
        
        var dataCaption = ""
        if let caption = caption {
            dataCaption = caption
        }
        
        if dataCaption.contains("This message was sent on previous session") == true {
            self.ivBaloonLeft.tintColor = ColorConfiguration.rightLeftBaloonGreyColor
        } else {
            self.ivBaloonLeft.tintColor = ColorConfiguration.leftBaloonColor
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
