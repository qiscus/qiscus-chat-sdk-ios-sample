//
//  QImageRightCell.swift
//  Qiscus
//
//  Created by asharijuang on 05/09/18.
//

import UIKit
import QiscusCore
import SDWebImage
import SDWebImageWebPCoder
import AlamofireImage
import Alamofire
import SimpleImageViewer

class QImageRightCell: UIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var ivComment: UIImageView!
    
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    var menuConfig = enableMenuConfig()
    @IBOutlet weak var ivLoading: UIImageView!
    @IBOutlet weak var lbLoading: UILabel!
    var gifCheck : Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
        self.ivComment.backgroundColor = UIColor.black
        self.ivComment.layer.cornerRadius = 8
        self.ivComment.isUserInteractionEnabled = true
        let imgTouchEvent = UITapGestureRecognizer(target: self, action: #selector(QImageLeftCell.imageDidTap))
        self.ivComment.addGestureRecognizer(imgTouchEvent)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu()
    }
    
    override func present(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivComment.image = nil
    }
    
    func bindData(message: CommentModel){
        self.setupBalon()
        self.status(message: message)
        // get image
        self.lbName.text = "You"
        self.lbTime.text = self.hour(date: message.date())
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        self.tvContent.text = caption
        self.tvContent.textColor = ColorConfiguration.rightBaloonTextColor
        if let url = payload["url"] as? String {
            if let url = payload["url"] as? String {
                
                var fileImage = url
                if fileImage.isEmpty {
                    fileImage = "https://"
                }
                
                self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
                if url.fileExtension(fromURL: url) == "gif"{
                    self.gifCheck = true
                    self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                    
                    QiscusCore.shared.getThumbnailURL(url: fileImage) { url in
                        self.ivComment.sd_setImage(with: URL(string: url) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                            if urlPath != nil && uiImage != nil{
                                self.ivComment.af_setImage(withURL: urlPath!)
                                
                            }
                        }
                    } onError: { error in
                        self.ivComment.sd_setImage(with: URL(string: url) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                            if urlPath != nil && uiImage != nil{
                                self.ivComment.af_setImage(withURL: urlPath!)
                            }
                        }
                    }
                }else{
                    self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                    self.ivComment.sd_setImage(with: URL(string: fileImage) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                        if urlPath != nil && uiImage != nil{
                            self.ivComment.af_setImage(withURL: urlPath!)
                        }
                    }
                }
            }
        }
        
    }
    
    func hideLoading(){
        self.lbLoading.isHidden = true
        self.ivLoading.isHidden = true
    }
    
    func showLoading(){
        self.lbLoading.isHidden = false
        self.ivLoading.isHidden = false
    }
    
    @objc func imageDidTap() {
        guard let selectedImage = self.ivComment.image else {
            print("Image not found!")
            return
        }
        
        if gifCheck == true{
            if (self.comment?.message.contains("[/file]") == true){
                
                var url = self.comment?.message.getAttachmentURL(message: self.comment?.message ?? "https://") ?? "https://"
                
                let preview = ChatPreviewDocVC()
                preview.fileName = url
                preview.url = url
                preview.roomName = "Gif Preview"
                let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                backButton.tintColor = UIColor.white
                
                self.currentViewController()?.navigationController?.navigationItem.backBarButtonItem = backButton
                self.currentViewController()?.navigationController?.pushViewController(preview, animated: true)
            }else{
                guard let payload = self.comment?.payload else { return }
                if let fileName = payload["file_name"] as? String{
                    if let url = payload["url"] as? String {
                        
                        let preview = ChatPreviewDocVC()
                        preview.fileName = fileName
                        preview.url = url
                        preview.roomName = "Gif Preview"
                        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                        backButton.tintColor = UIColor.white
                        self.currentViewController()?.navigationItem.backBarButtonItem = backButton
                        self.currentViewController()?.navigationController?.pushViewController(preview, animated: true)
                    }
                }
            }
            
        }else{
            
            DispatchQueue.global(qos: .background).sync {
                //active this code for detail image
                let configuration = ImageViewerConfiguration { config in
                    config.imageView = self.ivComment
                }

                
                let vc = ImageViewerController(configuration: configuration)
                vc.modalPresentationStyle = .overFullScreen
                
                DispatchQueue.main.async {
                    self.currentViewController()?.navigationController?.present(vc, animated: false, completion: {
                        
                    })
                }
            }
            
           
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.currentViewController()?.navigationController?.present(ac, animated: true, completion: {
            //success
        })
        
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
    
    func setupBalon(){
        //self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        self.ivBaloonLeft.tintColor = ColorConfiguration.rightBaloonColor
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
            ivStatus.tintColor = ColorConfiguration.readMessageColor
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
