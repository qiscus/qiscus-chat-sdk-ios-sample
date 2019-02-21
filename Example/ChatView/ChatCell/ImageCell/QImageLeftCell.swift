//
//  QImageLeftCell.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import UIKit
import QiscusCore

import Alamofire
import SimpleImageViewer
import SDWebImage

class QImageLeftCell: UIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var ivComment: UIImageView!
    @IBOutlet weak var ivLoading: UIImageView!
    @IBOutlet weak var lbLoading: UILabel!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    var isPublic: Bool = false
    var menuConfig = enableMenuConfig()
    var colorName : UIColor = UIColor.black
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
         self.ivComment.layer.cornerRadius = 8
        self.ivComment.backgroundColor = UIColor.black
        self.ivComment.isUserInteractionEnabled = true
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
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        self.tvContent.text = caption
        self.tvContent.textColor = ColorConfiguration.leftBaloonTextColor
        if let url = payload["url"] as? String {
            if let url = payload["url"] as? String {
                
                if self.ivComment.image == nil {
                    self.showLoading()
                    self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
                    QiscusCore.shared.download(url: URL(string: url)!, onSuccess: { (urlFile) in
                        self.hideLoading()
                        
                        let data = NSData(contentsOf: urlFile)
                        self.ivComment.image = UIImage(data: data as! Data)
                        
                    }, onProgress: { (progress) in
                        
                    })
                }
            }
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
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        //active this code for detail image
//        let configuration = ImageViewerConfiguration { config in
//            config.imageView = ivComment
//        }
//
//        let imageViewerController = ImageViewerController(configuration: configuration)
//        self.currentViewController()?.navigationController?.present(ImageViewerController(configuration: configuration), animated: true)
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
