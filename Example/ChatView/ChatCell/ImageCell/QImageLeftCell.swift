//
//  QImageLeftCell.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import UIKit
import QiscusCore
import QiscusUI
import Alamofire
import SimpleImageViewer
import SDWebImage

class QImageLeftCell: QUIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var ivComment: UIImageView!
    
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var statusWidth: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressHeight: NSLayoutConstraint!
    var isPublic: Bool = false
    var menuConfig = enableMenuConfig()
    var colorName : UIColor = UIColor.black
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu(forward: menuConfig.forward, info: menuConfig.info)
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
        self.ivComment.backgroundColor = UIColor.black
        self.ivComment.isUserInteractionEnabled = true
        self.progressContainer.layer.cornerRadius = 20
        self.progressContainer.clipsToBounds = true
        self.progressContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65).cgColor
        self.progressContainer.layer.borderWidth = 2
        self.progressView.backgroundColor = UIColor.green
        let imgTouchEvent = UITapGestureRecognizer(target: self, action: #selector(QImageLeftCell.imageDidTap))
        self.ivComment.addGestureRecognizer(imgTouchEvent)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu()
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.setupBalon()
        
        // get image
        self.lbTime.text = self.hour(date: message.date())
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        self.tvContent.text = caption
        self.tvContent.textColor = ColorConfiguration.leftBaloonTextColor
        if let url = payload["url"] as? String {
            ivComment.sd_setShowActivityIndicatorView(true)
            ivComment.sd_setIndicatorStyle(.whiteLarge)
            ivComment.sd_setImage(with: URL(string: url)!)
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
    
    @objc func imageDidTap() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = ivComment
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        self.currentViewController()?.navigationController?.present(ImageViewerController(configuration: configuration), animated: true)
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
        self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        self.ivBaloonLeft.tintColor = ColorConfiguration.leftBaloonColor
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
