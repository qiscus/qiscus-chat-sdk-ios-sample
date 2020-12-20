//
//  QPopUpView.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 10/31/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit
import QiscusCore

class QPopUpView: UIViewController {
    
    static let sharedInstance = QPopUpView()
    
    var text:String = ""
    var image:UIImage?
    var isVideo:Bool = false
    var attributedText:NSMutableAttributedString?
    
    var firstAction:(()->Void) = {}
    var secondAction:(()->Void) = {}
    var singleAction:(()->Void) = {}
    var oneButton:Bool = false
    
    let fixedWidth:CGFloat = 240
    var isPresent:Bool = false
    
    var topColor = ChatConfig.baseColor
    var bottomColor = ChatConfig.baseColor
    
    @IBOutlet weak var ivFileAttachment: UIImageView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var videoOverlay: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lbProgress: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var heightProgressViewCons: NSLayoutConstraint!
    let maxProgressHeight:Double = 40.0
    var hiddenIconFileAttachment = true
    
    fileprivate init() {
        super.init(nibName: "QPopUpView", bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true , animated: false)
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFill
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let parentView = self.view
        parentView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        self.topColor = ColorConfiguration.topColor
        self.bottomColor = ColorConfiguration.bottomColor
        
        if self.image != nil {
            self.imageView.image = self.image
            self.imageViewHeight.constant = 120
        }else{
            self.imageView.image = nil
            if hiddenIconFileAttachment == false {
                self.ivFileAttachment.alpha = 1
            } else {
                self.ivFileAttachment.alpha = 0
            }
            
            self.imageViewHeight.constant = 120
            self.ivFileAttachment.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(.alwaysTemplate)
            self.ivFileAttachment.tintColor = ColorConfiguration.defaultColorTosca
        }
        self.containerView.layer.cornerRadius = 10
        
        
        self.imageView.clipsToBounds = true
        if self.attributedText == nil{
            self.textView.text = self.text
        }else{
            self.textView.attributedText = self.attributedText
        }
        
        let newSize = self.textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        //var height = 55
        if newSize.height > 55 {
            self.textViewHeight.constant = newSize.height + 5
            self.containerHeight.constant = newSize.height + 50
        }
        
        self.firstButton.backgroundColor = ColorConfiguration.defaultColorTosca
        self.secondButton.backgroundColor = ColorConfiguration.defaultColorTosca
        self.singleButton.backgroundColor = ColorConfiguration.defaultColorTosca
        
        if oneButton {
            self.firstButton.isHidden = true
            self.secondButton.isHidden = true
            self.singleButton.isHidden = false
        }else{
            self.firstButton.isHidden = false
            self.secondButton.isHidden = false
            self.singleButton.isHidden = true
        }
        self.containerView.layoutIfNeeded()
        self.videoOverlay.isHidden = !isVideo
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isPresent = false
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func firstButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.isPresent = false
        self.secondAction()
    }
    
    @IBAction func secondButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.isPresent = false
        self.firstAction()
    }
    @IBAction func singleButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
        self.isPresent = false
        self.singleAction()
    }
    
    // MARK: - Class methode to show popUp
    class func showAlert(withTarget target:UIViewController,image:UIImage? = nil,message:String = "", attributedText:NSMutableAttributedString? = nil, firstActionTitle:String = "OK", secondActionTitle:String = "CANCEL",isVideoImage:Bool = false, hiddenIconFileAttachment : Bool = true, doneAction:@escaping ()->Void = { }, cancelAction:@escaping ()->Void = {}){
        let alert = QPopUpView.sharedInstance
        if alert.isPresent{
            alert.dismiss(animated: false, completion: nil)
            alert.isPresent = true
        }else{
            alert.isPresent = true
        }
        
        alert.secondAction = cancelAction
        
        alert.firstAction = doneAction
        alert.image = image
        alert.isVideo = isVideoImage
        if attributedText != nil{
            alert.attributedText = attributedText
        }else{
            alert.text = message
        }
        alert.oneButton = false
        alert.hiddenIconFileAttachment = hiddenIconFileAttachment
        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .overCurrentContext
        alert.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: {})
    }

    func hiddenProgress(){
        self.lbProgress.isHidden = true
        self.progressView.isHidden = true
        self.secondButton.isEnabled = true
    }
    
    func showProgress(progress: Double){
        self.progressView.layer.cornerRadius =  self.progressView.frame.height / 2
        self.secondButton.isEnabled = false
        self.lbProgress.isHidden = false
        self.progressView.isHidden = false
        self.lbProgress.text = "\(Int(progress * 100)) %"
    }
}
