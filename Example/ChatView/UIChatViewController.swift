//
//  QChatVC.swift
//  Qiscus
//
//  Created by Qiscus on 07/05/18.
//

import UIKit
import ContactsUI
import SwiftyJSON
import QiscusCore
import Alamofire
import iRecordView
import AVFoundation

// Chat view blue print or function
protocol UIChatView {
    func uiChat(viewController : UIChatViewController, didSelectMessage message: CommentModel)
    func uiChat(viewController : UIChatViewController, performAction action: Selector, forRowAt message: CommentModel, withSender sender: Any?)
    func uiChat(viewController : UIChatViewController, canPerformAction action: Selector, forRowAtmessage: CommentModel, withSender sender: Any?) -> Bool
    func uiChat(viewController : UIChatViewController, firstMessage message: CommentModel, viewForHeaderInSection section: Int) -> UIView?
}

class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.3555911001, green: 0.7599821354, blue: 1, alpha: 0.7924068921)
        textColor = .darkGray
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
        font = UIFont.boldSystemFont(ofSize: 9.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 15, height: height)
    }
    
}

class UIChatViewController: UIViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var tableViewConversation: UITableView!
    @IBOutlet weak var viewChatInput: UIView!
    @IBOutlet weak var constraintViewInputBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintViewInputHeight: NSLayoutConstraint!
    @IBOutlet weak var emptyMessageView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var heightProgressBar: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewResolved: UIScrollView!
    @IBOutlet weak var viewPopupResolvedBottomConst: NSLayoutConstraint!
    @IBOutlet weak var viewResolved: UIView!
    @IBOutlet weak var lbNameResolved: UILabel!
    @IBOutlet weak var ivAvatarResolved: UIImageView!
    @IBOutlet weak var viewResloved: UIView!
    @IBOutlet weak var tvNotes: UITextView!
    @IBOutlet weak var btCheckBox: UIButton!
    @IBOutlet weak var btCheckBoxSendNote: UIButton!
    @IBOutlet weak var heightBtCheckBoxSendNote: NSLayoutConstraint!
    @IBOutlet weak var heightBtCheckboxCons: NSLayoutConstraint!
    @IBOutlet weak var topHeightSubmitNoteCons: NSLayoutConstraint!
    @IBOutlet weak var lbSendNoteToCustomer: UILabel!
    @IBOutlet weak var lbSendChatHistoryToCustomer: UILabel!
    
    @IBOutlet weak var btSubmitResolved: UIButton!
    @IBOutlet weak var btCancelSubmit: UIButton!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var tableViewChatTemplate: UITableView!
    @IBOutlet weak var topProgressBar: NSLayoutConstraint!
    
    @IBOutlet weak var bottomUIPopupBGResolved: NSLayoutConstraint!
    
    
    var chatTitleView : UIChatNavigation = UIChatNavigation()
    var chatInput : CustomChatInput = CustomChatInput()
    private var presenter: UIChatPresenter = UIChatPresenter()
    
    var heightAtIndexPath: [String: CGFloat] = [:]
    var roomId: String = ""
    var chatDelegate : UIChatView? = nil
    
    // UI Config
    var usersColor : [String:UIColor] = [String:UIColor]()
    var currentNavbarTint = UINavigationBar.appearance().tintColor
    var latestNavbarTint = UINavigationBar.appearance().tintColor
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    var UTIs:[String]{
        get{
            return ["public.jpeg", "public.png","com.compuserve.gif","public.text", "public.archive", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.​ppt", "com.adobe.pdf","public.mpeg-4"]
        }
    }
    var room : RoomModel? {
        set(newValue) {
            self.presenter.room = newValue
            self.refreshUI()
        }
        get {
            return self.presenter.room
        }
    }
    
    var chatTemplates = [ChatTemplate]()
    var chatTemplatesKeyword = ""
    var isQiscus : Bool = false
    
    var recordButton:RecordButton = RecordButton()
    var recordView:RecordView = RecordView()
    
    //24 HSM template
    @IBOutlet weak var viewAlertHSMTemplate: UIView!
    @IBOutlet weak var btAlertInfoHSM: UIButton!
    @IBOutlet weak var btCloseAlertHSM: UIButton!
    @IBOutlet weak var btSendHSM: UIButton!
    @IBOutlet weak var lbAlertCreditCountHSM: UILabel!
    var dataHSMTemplate = [HSMTemplateModel]()
    
    @IBOutlet weak var viewBGTemplateHSM: UIView!
    @IBOutlet weak var viewTemplateHSM: UIView!
    @IBOutlet weak var textViewContentTemplateHSM: UITextView!
    @IBOutlet weak var tfSelectTemplateLanguage: UITextField!
    @IBOutlet weak var btSendTemplateHSM: UIButton!
    @IBOutlet weak var btCancelTemplateHSM: UIButton!
    
    @IBOutlet weak var tvAlertMessageHSMDisable: UITextView!
    @IBOutlet weak var tvAlertMessageHSMQuota0: UITextView!
    @IBOutlet weak var viewExpiredQuota0: UIView!
    @IBOutlet weak var viewExpiredHSMDisable: UIView!
    var dataLanguage = [String]()
    
    var actionButton = UIBarButtonItem()
    
    //feature block
    @IBOutlet weak var bgViewBlockContact: UIView!
    @IBOutlet weak var alertViewBlockContact: UIView!
    @IBOutlet weak var btCancelBlockContact: UIButton!
    @IBOutlet weak var btBlockContact: UIButton!
    var userID = ""
    var isWaBlocked = false
    
    //feature unblock
    @IBOutlet weak var bgViewUnBlockContact: UIView!
    @IBOutlet weak var alertViewUnBlockContact: UIView!
    @IBOutlet weak var btCancelUnBlockContact: UIButton!
    @IBOutlet weak var btUnBlockContact: UIButton!
    
    //alert success block unblock
    //feature unblock
    @IBOutlet weak var bgViewSuccessBlockUnBlockContact: UIView!
    @IBOutlet weak var alertViewSuccessBlockUnBlockContact: UIView!
    @IBOutlet weak var btOKSuccessBlockUnBlockContact: UIButton!
    @IBOutlet weak var lbAlertMessageSuccessBlockUnblockContact: UILabel!
    
    //UnStableConnection
    @IBOutlet weak var viewUnstableConnection: UIView!
    @IBOutlet weak var heightViewUnstableConnectionConst: NSLayoutConstraint!
    
    //scroll to commentId
    var scrollToComment : CommentModel? = nil
    
    open func getProgressBar() -> UIProgressView {
        return progressBar
    }
    
    open func getProgressBarHeight() ->  NSLayoutConstraint{
        return heightProgressBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCustomerUser()
        self.setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.attachView(view: self)
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(UIChatViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(UIChatViewController.keyboardChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        center.addObserver(self,selector: #selector(reSubscribeRoom(_:)), name: Notification.Name(rawValue: "reSubscribeRoom"),object: nil)
        center.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)

        center.addObserver(self, selector: #selector(hideUnstableConnection(_:)), name: NSNotification.Name(rawValue: "stableConnection"), object: nil)
        center.addObserver(self, selector: #selector(showUnstableConnection(_:)), name: NSNotification.Name(rawValue: "unStableConnection"), object: nil)
        view.endEditing(true)

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        self.tableViewChatTemplate.isHidden = true
        
        self.checkIFTypeWAExpired()
        self.setupReachability()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "reSubscribeRoom"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

        view.endEditing(true)
    }
    
    func setupReachability(){
        let defaults = UserDefaults.standard
        let hasInternet = defaults.bool(forKey: "hasInternet")
        if hasInternet == true {
            self.stableConnection()
        }else{
            self.unStableConnection()
        }
        
    }
    
    @objc func applicationDidBecomeActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.presenter.attachView(view: self)
        }
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.presenter.detachView()
    }
    
    @objc func reSubscribeRoom(_ notification: Notification)
    {
        self.presenter.attachView(view: self)
    }

    @objc func showUnstableConnection(_ notification: Notification){
        self.unStableConnection()
    }
    
    func unStableConnection(){
        self.viewUnstableConnection.alpha = 1
        self.heightViewUnstableConnectionConst.constant = 45
    }
    
    @objc func hideUnstableConnection(_ notification: Notification){
        self.stableConnection()
    }
    
    func stableConnection(){
        self.viewUnstableConnection.alpha = 0
        self.heightViewUnstableConnectionConst.constant = 0
    }
    
    func setupToolbarHandle(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        self.chatTitleView.isUserInteractionEnabled = true
        self.chatTitleView.addGestureRecognizer(tap)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if let room = self.room {
            var channelTypeString = ""
            let vc = ChatAndCustomerInfoVC()
            vc.isWaBlocked = self.isWaBlocked
            vc.room = room
            
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                let channelType = json["channel"].string ?? "qiscus"
                if channelType.lowercased() == "qiscus"{
                    channelTypeString = "Qiscus Widget"
                }else if channelType.lowercased() == "telegram"{
                    channelTypeString = "Telegram"
                }else if channelType.lowercased() == "line"{
                    channelTypeString = "Line"
                }else if channelType.lowercased() == "fb"{
                    channelTypeString = "Facebook"
                }else if channelType.lowercased() == "wa"{
                    channelTypeString = "WhatsApp"
                }else if channelType.lowercased() == "twitter" {
                    channelTypeString = "Custom Channel"
                }else if channelType.lowercased() == "custom" {
                    channelTypeString = "Custom Channel"
                }else{
                    channelTypeString = "Custom Channel"
                }
                
                if channelTypeString == "WhatsApp" {
                     vc.isTypeWA = true
                } else {
                     vc.isTypeWA = false
                }
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func refreshUI() {
        if self.isViewLoaded {
            self.presenter.attachView(view: self)
            self.setupUI()
        }
    }
    
    // MARK: View Event Listener
    private func setupUI() {
        // config navBar
        self.setupNavigationTitle()
        self.setupToolbarHandle()
        self.qiscusAutoHideKeyboard()
        self.setupTableView()
        self.chatInput.chatInputDelegate = self
        self.setupInputBar(self.chatInput)
        self.setupPopupResolved()
        self.setupIsQiscus()
        self.setupRecordAudio()
        self.setupHSM()
        self.setupHSMAlertMessage()
        self.setupBlockContact()
        self.setupUnBlockContact()
        self.chatInput.hidePreviewReply()
        

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            
            self.topProgressBar.constant = 0
        }else {
            self.topProgressBar.constant = 65
        }
    }
    
    func setupHSM(){
        //setup template HSM
        self.btSendHSM.layer.cornerRadius = self.btSendTemplateHSM.frame.height / 2
        self.btAlertInfoHSM.setImage(UIImage(named: "ic_warning_alert")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        self.btAlertInfoHSM.tintColor = UIColor.red
        self.btSendTemplateHSM.layer.cornerRadius = self.btSendTemplateHSM.frame.height / 2
        self.btCancelTemplateHSM.layer.cornerRadius = self.btCancelTemplateHSM.frame.height / 2
        
        self.btCancelTemplateHSM.layer.borderWidth = 2
        self.btCancelTemplateHSM.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        
        self.viewTemplateHSM.layer.cornerRadius = 8
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        tfSelectTemplateLanguage.inputView = pickerView
    }
    
    func setupBlockContact(){
        self.btBlockContact.layer.cornerRadius = self.btBlockContact.frame.height / 2
        self.btCancelBlockContact.layer.cornerRadius = self.btCancelBlockContact.frame.height / 2
        self.alertViewBlockContact.layer.cornerRadius = 8
    }
    
    func setupUnBlockContact(){
        self.btUnBlockContact.layer.cornerRadius = self.btUnBlockContact.frame.height / 2
        self.btCancelUnBlockContact.layer.cornerRadius = self.btCancelUnBlockContact.frame.height / 2
        self.alertViewUnBlockContact.layer.cornerRadius = 8
    }
    
    func setupAlertSuccessBlockUnblockContact(message: String){
        self.bgViewSuccessBlockUnBlockContact.isHidden = false
        self.btOKSuccessBlockUnBlockContact.layer.cornerRadius = self.btOKSuccessBlockUnBlockContact.frame.height / 2
        self.alertViewSuccessBlockUnBlockContact.layer.cornerRadius = 8
        self.lbAlertMessageSuccessBlockUnblockContact.text = message
    }
    
    func setupHSMAlertMessage(){
        let messageHSMQuota0Admin = "and your Message Template credit already empty. If you want add some Message Template Credit, please contact us."
        let messageHSMQuota0Agent = "and your Message Template credit already empty. If you want add some Message Template Credit, please contact Your Admin."
        let messageHSMQuota0SPV = "and your Message Template credit already empty. If you want add some Message Template Credit, please contact Your Admin."
        
        var messageHSMDisable = "Please enable 24 Hours Message Template first in WhatsApp integration and learn more in this documentation."
        let messageHSMDisableAgent = "24 Hours Message Template is disabled. Please contact Your Admin"
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.alignment = .center
        let attributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : ColorConfiguration.alertTextColorHSM]
        
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                
                //HSMDisable
                let attributedStringHSMDisable = NSMutableAttributedString(string: messageHSMDisableAgent, attributes: attributes)

                //HSMQuota0
                let attributedStringHSMQuota0 = NSMutableAttributedString(string: messageHSMQuota0Agent, attributes: attributes)
               
                // textView is a UITextView HSM Quota0
                tvAlertMessageHSMQuota0.attributedText = attributedStringHSMQuota0

                // textView is a UITextView
                tvAlertMessageHSMDisable.attributedText = attributedStringHSMDisable
            } else if userType == 1 {
                //admin
                
                //HSMDisable
                let attributedStringHSMDisable = NSMutableAttributedString(string: messageHSMDisable, attributes: attributes)
                let linkRange = (attributedStringHSMDisable.string as NSString).range(of: "documentation.")
                attributedStringHSMDisable.addAttribute(NSAttributedString.Key.link, value: "https://documentation.qiscus.com/multichannel-customer-service/channel-integration#hsm-template-after-24-hours-in-whatsapp", range: linkRange)
                let linkAttributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,
                ]
                
                //HSMQuota0
                let attributedStringHSMQuota0 = NSMutableAttributedString(string: messageHSMQuota0Admin, attributes: attributes)
                let linkRangeHSMQuota0 = (attributedStringHSMQuota0.string as NSString).range(of: "contact us.")
                attributedStringHSMQuota0.addAttribute(NSAttributedString.Key.link, value: "https://www.qiscus.com/contact", range: linkRangeHSMQuota0)
                let linkAttributesHSMQuota0: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,
                ]

                // textView is a UITextView HSM Quota0
                tvAlertMessageHSMQuota0.linkTextAttributes = linkAttributesHSMQuota0
                tvAlertMessageHSMQuota0.attributedText = attributedStringHSMQuota0
                

                // textView is a UITextView HSM Disable
                tvAlertMessageHSMDisable.linkTextAttributes = linkAttributes
                tvAlertMessageHSMDisable.attributedText = attributedStringHSMDisable
            } else {
                //spv
                messageHSMDisable = "24 Hours Message Template is disabled. Please contact Your Admin"
                let attributedStringHSMDisable = NSMutableAttributedString(string: messageHSMDisable, attributes: attributes)
                
                //HSMQuota0
                let attributedStringHSMQuota0 = NSMutableAttributedString(string: messageHSMQuota0SPV, attributes: attributes)
               
                // textView is a UITextView HSM Quota0
                tvAlertMessageHSMQuota0.attributedText = attributedStringHSMQuota0
                tvAlertMessageHSMDisable.attributedText = attributedStringHSMDisable
            }
        }
        
        tvAlertMessageHSMDisable.font = .systemFont(ofSize: 14)
    }
    
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.dataLanguage.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataLanguage[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tfSelectTemplateLanguage.text = dataLanguage[row]
        
        let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == tfSelectTemplateLanguage.text?.lowercased() }
        
        if let data = filterData.first{
            self.textViewContentTemplateHSM.text = data.content
        }else{
            self.textViewContentTemplateHSM.text = ""
        }
    }
    
    //alert ok success block unbloc contact
    @IBAction func btOKSuccessBlockUnBlockContact(_ sender: Any) {
        self.bgViewSuccessBlockUnBlockContact.isHidden = true
        if self.chatInput.textView.text.isEmpty || self.chatInput.textView.text.contains("Send a message...") == true{
            self.recordButton.isHidden = false
        }else{
            self.recordButton.isHidden = true
        }
    }
    
    //alert block contact
    @IBAction func btCancelBlockContact(_ sender: Any) {
        self.bgViewBlockContact.isHidden = true
        if self.chatInput.textView.text.isEmpty || self.chatInput.textView.text.contains("Send a message...") == true {
            self.recordButton.isHidden = false
        }else{
            self.recordButton.isHidden = true
        }
    }
    
    @IBAction func btBlockContact(_ sender: Any) {
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        if userID.isEmpty == true {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: Any] = [
            "room_id": self.room?.id,
            "source" : "wa",
            "user_id" : userID
        ]
        
        var dataRole = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                dataRole = "agent"
            } else if userType == 1 {
                 dataRole = "admin"
            } else {
                dataRole = "admin"
            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(dataRole)/customer/block", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.btBlockContact(sender)
                            } else {
                                return
                            }
                        }
                    }else{
                        self.bgViewBlockContact.isHidden = true
                    }
                    
                } else {
                    //success
                    self.bgViewBlockContact.isHidden = true
                    self.setupAlertSuccessBlockUnblockContact(message: "Room chat has been successfully blocked")
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.bgViewBlockContact.isHidden = true
            } else {
                //failed
                self.bgViewBlockContact.isHidden = true
            }
        }
        
    }
    
    //alert unblock contact
    @IBAction func btCancelUnBlockContact(_ sender: Any) {
        self.bgViewUnBlockContact.isHidden = true
        if self.chatInput.textView.text.isEmpty || self.chatInput.textView.text.contains("Send a message...") == true {
            self.recordButton.isHidden = false
        }else{
            self.recordButton.isHidden = true
        }
    }
    
    @IBAction func btUnBlockContact(_ sender: Any) {
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        if userID.isEmpty == true {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: Any] = [
            "room_id": self.room?.id,
            "source" : "wa",
            "user_id" : userID
        ]
        
        var dataRole = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                dataRole = "agent"
            } else if userType == 1 {
                 dataRole = "admin"
            } else {
                dataRole = "admin"
            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(dataRole)/customer/unblock", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.btUnBlockContact(sender)
                            } else {
                                return
                            }
                        }
                    }else{
                        self.bgViewUnBlockContact.isHidden = true
                    }
                    
                } else {
                    //success
                    self.bgViewUnBlockContact.isHidden = true
                    self.setupAlertSuccessBlockUnblockContact(message: "Room chat has been successfully unblocked")
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.bgViewUnBlockContact.isHidden = true
            } else {
                //failed
                self.bgViewUnBlockContact.isHidden = true
            }
        }
        
    }
    
    //Alert template hsm
    
    @IBAction func btActionAlertHSMInfo(_ sender: Any) {
        let popupVC = BottomAlertInfoHSM()
        popupVC.isExpired = true
        popupVC.width = self.view.frame.size.width
        popupVC.topCornerRadius = 15
        popupVC.presentDuration = 0.30
        popupVC.dismissDuration = 0.30
        popupVC.shouldDismissInteractivelty = true
        self.present(popupVC, animated: true, completion: nil)
    }
    @IBAction func btActionAlertHSMClose(_ sender: Any) {
        self.settingTableViewNormal()
        self.hideUIRecord(isHidden: false)
        self.viewAlertHSMTemplate.alpha = 0
    }
    @IBAction func btActionSendHSM(_ sender: Any) {
        self.viewAlertHSMTemplate.alpha = 0
        self.viewBGTemplateHSM.alpha = 1
    }
    
    @IBAction func sendTemplateHSM(_ sender: Any) {
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == tfSelectTemplateLanguage.text?.lowercased() }
        
        var templateID = 0
        if let data = filterData.first{
            templateID = data.id
        }else{
            return
        }
        
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        
        var param: [String: Any] = [
            "room_id": self.room?.id,
            "template_detail_id" : templateID
        ]
        
        var dataRole = "admin"
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                //agent
                dataRole = "agent"
            } else if userType == 1 {
                 dataRole = "admin"
            } else {
                dataRole = "admin"
            }
        }
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/\(dataRole)/broadcast/send_hsm24", method: .post, parameters: param, encoding: JSONEncoding.default, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.sendTemplateHSM(sender)
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    self.viewBGTemplateHSM.alpha = 0
                    self.settingTableViewNormal()
                    self.hideUIRecord(isHidden: false)
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.viewBGTemplateHSM.alpha = 0
            } else {
                //failed
                self.viewBGTemplateHSM.alpha = 0
            }
        }
    }
    
    @IBAction func cancelTemplateHSM(_ sender: Any) {
        self.viewBGTemplateHSM.alpha = 0
        self.settingTableViewNormal()
        self.hideUIRecord(isHidden: false)
    }
    
    func hasTopNotch()-> Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 24.0 on iPad Pro 12.9" 3rd generation, 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }
    
    func setupRecordAudio(){
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordView.translatesAutoresizingMaskIntoConstraints = false
        recordButton.tintColor = ColorConfiguration.defaultColorTosca
        recordButton.setImage(UIImage(named: "ic_rec_black")?.withRenderingMode(.alwaysTemplate), for: .normal)
        view.addSubview(recordButton)
        view.addSubview(recordView)

        recordButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 35).isActive = true

        recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -15).isActive = true
        

        recordView.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -50).isActive = true
        recordView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        recordView.bottomAnchor.constraint(equalTo: recordButton.bottomAnchor).isActive = true
        recordButton.recordView = recordView
        
        //record
        recordView.delegate = self
        //IMPORTANT
        recordButton.recordView = recordView
    }
    
    func setupIsQiscus(){
        if let option = self.room?.options {
            if !option.isEmpty{
                let json = JSON.init(parseJSON: option)
                let channelType = json["channel"].string ?? "qiscus"
               
                if channelType.lowercased() == "qiscus"{
                    self.isQiscus = true
                }else if channelType.lowercased() == "telegram"{
                    self.isQiscus = false
                }else if channelType.lowercased() == "line"{
                    self.isQiscus = false
                }else if channelType.lowercased() == "fb"{
                    self.isQiscus = false
                }else if channelType.lowercased() == "wa"{
                    self.isQiscus = false
                }else if channelType.lowercased() == "twitter"{
                    self.isQiscus = false
                }else if channelType.lowercased() == "custom"{
                    self.isQiscus = false
                }else{
                    self.isQiscus = false
                }
            }
        }
    }
    
    private func setupPopupResolved(){
        self.tvNotes.layer.borderWidth = 1
        self.tvNotes.layer.cornerRadius = 8
        self.tvNotes.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        self.tvNotes.backgroundColor = UIColor.white
        self.tvNotes.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add Notes"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (self.tvNotes.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        self.tvNotes.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.tvNotes.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.tvNotes.text.isEmpty
        
        self.viewResolved.layer.cornerRadius = 8
        self.scrollViewResolved.layer.cornerRadius = 8
        self.btSubmitResolved.layer.cornerRadius = self.btSubmitResolved.frame.height / 2
        self.btCancelSubmit.layer.cornerRadius = self.btCancelSubmit.frame.height / 2
        
        self.btCancelSubmit.layer.borderWidth = 2
        self.btCancelSubmit.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
        
        self.ivAvatarResolved.layer.cornerRadius = self.ivAvatarResolved.frame.height / 2
        
        self.btCheckBoxSendNote.setImage(UIImage(named: "ic_uncheck")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.btCheckBox.setImage(UIImage(named: "ic_uncheck")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.btCheckBoxSendNote.tintColor = ColorConfiguration.defaultColorTosca
        self.btCheckBox.tintColor = ColorConfiguration.defaultColorTosca
        
        var isQiscusWidgetRoom = false
        
        if let room = self.room{
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                let channelType = json["channel"].string ?? "qiscus"
                
                if channelType.lowercased() == "qiscus"{
                    isQiscusWidgetRoom = true
                }else if channelType.lowercased() == "telegram"{
                    isQiscusWidgetRoom = false
                }else if channelType.lowercased() == "line"{
                    isQiscusWidgetRoom = false
                }else if channelType.lowercased() == "fb"{
                    isQiscusWidgetRoom = false
                }else if channelType.lowercased() == "wa"{
                    isQiscusWidgetRoom = false
                }else if channelType.lowercased() == "twitter"{
                    isQiscusWidgetRoom = false
                }else{
                    isQiscusWidgetRoom = false
                }
            }
        }
        
        if isQiscusWidgetRoom == false {
            self.heightBtCheckBoxSendNote.constant = 0
            self.heightBtCheckboxCons.constant = 0
            self.topHeightSubmitNoteCons.constant = 0
            self.lbSendNoteToCustomer.isHidden = true
            self.lbSendChatHistoryToCustomer.isHidden = true
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func setupInputBar(_ inputchatview: UIChatInput) {
        inputchatview.frame.size    = self.viewChatInput.frame.size
        inputchatview.frame.origin  = CGPoint.init(x: 0, y: 0)
        inputchatview.translatesAutoresizingMaskIntoConstraints = false
        inputchatview.delegate = self
        
        self.viewChatInput.addSubview(inputchatview)
        
        NSLayoutConstraint.activate([
            inputchatview.topAnchor.constraint(equalTo: self.viewChatInput.topAnchor, constant: 0),
            inputchatview.leftAnchor.constraint(equalTo: self.viewChatInput.leftAnchor, constant: 0),
            inputchatview.rightAnchor.constraint(equalTo: self.viewChatInput.rightAnchor, constant: 0),
            inputchatview.bottomAnchor.constraint(equalTo: self.viewChatInput.bottomAnchor, constant: 0)
            ])
    }
    
    private func setupNavigationTitle(){
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        var totalButton = 1
        if let leftButtons = self.navigationItem.leftBarButtonItems {
            totalButton += leftButtons.count
        }
        if let rightButtons = self.navigationItem.rightBarButtonItems {
            totalButton += rightButtons.count
        }
        
        let backButton = self.backButton(self, action: #selector(UIChatViewController.goBack))
        
        if let room = self.room {
            if let option = room.options {
                if !option.isEmpty{
                    let json = JSON.init(parseJSON: option)
                    let is_resolved = json["is_resolved"].bool ?? false
                    
                    if is_resolved == false {
                        self.chatInput.textView.isEditable = true
                        self.chatInput.sendButton.isEnabled = true
                        self.chatInput.attachButton.isEnabled = true
                        let resolveButton = self.resolveButton(self, action:  #selector(UIChatViewController.goResolve))
                        actionButton = self.actionButton(self, action:  #selector(UIChatViewController.goActionButton))
                        
                        if let userType = UserDefaults.standard.getUserType(){
                            if userType == 2 {
                                self.navigationItem.rightBarButtonItems = [actionButton, resolveButton]
                            }else{
                                self.navigationItem.rightBarButtonItems = [actionButton, resolveButton]
                            }
                        }
                    } else {
                        if let userType = UserDefaults.standard.getUserType(){
                            if userType == 2 {
                                self.chatInput.textView.text = "Text is disable"
                                self.chatInput.textView.isEditable = false
                                self.chatInput.sendButton.isEnabled = false
                                self.chatInput.attachButton.isEnabled = false
                            } else {
                                enableSendMessage()
                            }
                        }
                        
                    }
                }
            }else{
                enableSendMessage()
            }
        }else{
           enableSendMessage()
        }
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
      
        
        self.chatTitleView = UIChatNavigation(frame: self.navigationController?.navigationBar.frame ?? CGRect.zero)
        self.navigationItem.titleView = chatTitleView
        self.chatTitleView.room = room
        
        
        if let room = QiscusCore.database.room.find(id: room?.id ?? ""){
            self.lbNameResolved.text = room.name
            
            if let avatar = room.avatarUrl {
                if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
                    self.ivAvatarResolved.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
                }else{
                    self.ivAvatarResolved.af_setImage(withURL: room.avatarUrl ?? URL(string: "http://")!)
                }
            }else{
                self.ivAvatarResolved.af_setImage(withURL: room.avatarUrl ?? URL(string: "http://")!)
            }
        }
        
    }
    
    @objc func checkIFTypeWAExpired(){
        if let room = self.room{
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                let channelType = json["channel"].string ?? "qiscus"
                
                if channelType.lowercased() == "wa"{
                    //call api
                    getCustomerInfo()
                }
            }
        }
    }
    
    func getCustomerInfo(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/qiscus/room/\(room!.id)/user_info", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getCustomerInfo()
                            } else {
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    let channelID = json["data"]["channel_id"].int ?? 0
                    var userID = json["data"]["user_id"].string ?? ""
                    var isWaBlocked = json["data"]["is_blocked"].bool ?? false
                    self.isWaBlocked = isWaBlocked
                    self.userID = userID
                    if channelID != 0 {
                        self.setupHSMAlertMessage()
                        self.getTemplateHSM(channelID: channelID)
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getCustomerUser(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/qiscus/room/\(room!.id)/user_info", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getCustomerUser()
                            } else {
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    var userID = json["data"]["user_id"].string ?? ""
                    
                    self.userID = userID
                    self.tableViewConversation.reloadData()
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func handleHSMAlertPending(){
        
        if self.room?.lastComment?.message.contains("Message failed to send because more than 24 hours") == true{
            self.view.endEditing(true)
            self.viewExpiredHSMDisable.isHidden = false
            self.viewExpiredQuota0.isHidden = true
            self.viewAlertHSMTemplate.alpha = 1
            self.hideUIRecord(isHidden: true)
            self.settingTableViewHeightUP()
        }
    }
    

    
    func getTemplateHSM(channelID: Int){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["channel_id": channelID,
                     "approved" : true
        ] as [String : Any]
        
        
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/hsm_24", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getTemplateHSM(channelID: channelID)
                            } else {
                                return
                            }
                        }
                    } else if response.response?.statusCode == 400 {
                        if let userType = UserDefaults.standard.getUserType(){
                            if userType == 3 || userType == 2 {
                                //spv
                                let style = NSMutableParagraphStyle()
                                style.lineSpacing = 14
                                style.alignment = .center
                                let attributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : ColorConfiguration.alertTextColorHSM]
                                
                                let messageHSMDisable = "Please contact Your Admin"
                                let attributedStringHSMDisable = NSMutableAttributedString(string: messageHSMDisable, attributes: attributes)
                                
                                // textView is a UITextView HSM Quota0
                                self.tvAlertMessageHSMDisable.attributedText = attributedStringHSMDisable
                            }
                            
                            self.handleHSMAlertPending()
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let arrayTemplate = payload["data"]["hsm_template"]["hsm_details"].array
                    let enableSendHSM = payload["data"]["enabled"].bool ?? false
                    let hsmQuota = payload["data"]["hsm_quota"].int ?? 0
                    
                    self.lbAlertCreditCountHSM.text = "Credit Message Template remaining : \(hsmQuota) Messages"
                    
                    if arrayTemplate?.count != 0 {
                        var results = [HSMTemplateModel]()
                        for dataTemplate in arrayTemplate! {
                            let data = HSMTemplateModel(json: dataTemplate)
                            results.append(data)
                        }
                        self.dataHSMTemplate = results
                        self.dataLanguage.removeAll()
                        for i in results {
                            
                            if !i.countryName.isEmpty{
                                self.dataLanguage.append(i.countryName)
                            }
                        }
                        
                        if self.dataLanguage.count != 0 {
                            self.tfSelectTemplateLanguage.text = self.dataLanguage.first
                            
                            let filterData = self.dataHSMTemplate.filter{ $0.countryName.lowercased() == self.dataLanguage.first!.lowercased() }
                            
                            if let data = filterData.first{
                                self.textViewContentTemplateHSM.text = data.content
                            }else{
                                self.textViewContentTemplateHSM.text = ""
                            }
                            
                        }
                    }
                    
                    //self.qiscusAutoHideKeyboard()
                    self.view.endEditing(true)
                    if let room = QiscusCore.database.room.find(id: self.room!.id){
                        let lastComment = room.lastComment
                        
                        if lastComment?.message.contains("Message failed to send because more than 24 hours") == true {
                            if enableSendHSM == true{
                                if hsmQuota == 0 {
                                    self.viewExpiredQuota0.isHidden = false
                                }else{
                                    self.viewExpiredQuota0.isHidden = true
                                }
                                self.viewExpiredHSMDisable.isHidden = true
                            }else{
                                self.viewExpiredQuota0.isHidden = true
                                self.viewExpiredHSMDisable.isHidden = false
                            }
                            self.viewAlertHSMTemplate.alpha = 1
                            self.hideUIRecord(isHidden: true)
                            self.settingTableViewHeightUP()
                        }else{
                            self.settingTableViewNormal()
                            self.hideUIRecord(isHidden: false)
                            self.viewAlertHSMTemplate.alpha = 0
                        }
                    }else{
                        self.settingTableViewNormal()
                        self.hideUIRecord(isHidden: false)
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.hideUIRecord(isHidden: false)
            } else {
                //failed
                self.hideUIRecord(isHidden: false)
            }
        }
    }
    
    func settingTableViewHeightUP(){
        self.constraintViewInputBottom.constant = 0 - 100
        self.bottomUIPopupBGResolved.constant = 50
    }
    
    func settingTableViewNormal(){
        self.bottomUIPopupBGResolved.constant = 50
        self.constraintViewInputBottom.constant = 0
    }
    
    func enableSendMessage(){
        self.chatInput.textView.isEditable = true
        self.chatInput.sendButton.isEnabled = true
        self.chatInput.attachButton.isEnabled = true
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
    
    private func resolveButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 80,height: 30))
        backButton.setTitle("Resolve", for: .normal)
        backButton.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        backButton.tintColor        = ColorConfiguration.defaultColorTosca
        backButton.layer.cornerRadius = 15
        backButton.backgroundColor  = UIColor.white
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    private func actionButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let menuIcon = UIImageView()
        menuIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_dot_menu")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        menuIcon.image = image
        menuIcon.tintColor = UIColor.white
        
        menuIcon.frame = CGRect(x: 0,y: 0,width: 30,height: 30)
        
        let actionButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 30))
        actionButton.addSubview(menuIcon)
        actionButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: actionButton)
    }
    
    func qiscusAutoHideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.qiscusDismissKeyboard))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func qiscusDismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTableView() {
        let rotate = CGAffineTransform(rotationAngle: .pi)
        //self.tableViewConversation.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.tableViewConversation.transform = rotate
        self.tableViewConversation.scrollIndicatorInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: UIScreen.main.bounds.width - 8)
        self.tableViewConversation.rowHeight = UITableView.automaticDimension
        self.tableViewConversation.dataSource = self
        self.tableViewConversation.delegate = self
        self.tableViewConversation.scrollsToTop = false
        self.tableViewConversation.allowsSelection = false
        
        self.tableViewChatTemplate.rowHeight = UITableView.automaticDimension
        self.tableViewChatTemplate.dataSource = self
        self.tableViewChatTemplate.delegate = self
        self.tableViewConversation.allowsSelection = true
        self.tableViewChatTemplate.register(ChatTemplateCell.nib, forCellReuseIdentifier: ChatTemplateCell.identifier)
        
        
        self.chatDelegate = self
        
        // support variation comment type
        self.registerClass(nib: UINib(nibName: "QTextRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qTextRightCell")
        self.registerClass(nib: UINib(nibName: "QTextLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qTextLeftCell")
        self.registerClass(nib: UINib(nibName: "QImageRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qImageRightCell")
        self.registerClass(nib: UINib(nibName: "QFileRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qFileRightCell")
         self.registerClass(nib: UINib(nibName: "QFileLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qFileLeftCell")
        self.registerClass(nib: UINib(nibName: "QImageLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qImageLeftCell")
        self.registerClass(nib: UINib(nibName: "EmptyCell", bundle:nil), forMessageCellWithReuseIdentifier: "emptyCell")
        self.registerClass(nib: UINib(nibName: "QSystemCell", bundle:nil), forMessageCellWithReuseIdentifier: "qSystemCell")
        
        self.registerClass(nib: UINib(nibName: "QPostbackLeftCell", bundle: nil), forMessageCellWithReuseIdentifier: "postBack")
        self.registerClass(nib: UINib(nibName: "QPostbackRightCell", bundle: nil), forMessageCellWithReuseIdentifier: "postBackRight")
        self.registerClass(nib: UINib(nibName: "QCarouselCell", bundle: nil), forMessageCellWithReuseIdentifier: "qCarouselCell")
        self.registerClass(nib: UINib(nibName: "QCardRightCell", bundle: nil), forMessageCellWithReuseIdentifier: "qCardRightCell")
        self.registerClass(nib: UINib(nibName: "QCardLeftCell", bundle: nil ), forMessageCellWithReuseIdentifier: "qCardLeftCell")
        
         self.registerClass(nib: UINib(nibName: "QReplyImageRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyImageRightCell")
         self.registerClass(nib: UINib(nibName: "QReplyImageLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyImageLeftCell")
        
        self.registerClass(nib: UINib(nibName: "QVideoRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qVideoRightCell")
        self.registerClass(nib: UINib(nibName: "QVideoLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qVideoLeftCell")
        
        self.registerClass(nib: UINib(nibName: "QReplyRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyRightCell")
        self.registerClass(nib: UINib(nibName: "QReplyLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyLeftCell")
        
        self.registerClass(nib: UINib(nibName: "QLocationLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qLocationLeftCell")
        self.registerClass(nib: UINib(nibName: "QLocationRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qLocationRightCell")
    }
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btCheckBoxClick(_ sender: Any) {
        if (btCheckBox.isSelected == true){
            self.btCheckBox.setImage(UIImage(named: "ic_uncheck")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btCheckBox.isSelected = false
        } else {
             self.btCheckBox.setImage(UIImage(named: "ic_check_button")?.withRenderingMode(.alwaysTemplate), for: .selected)
            btCheckBox.isSelected = true
        }
        
         self.btCheckBox.tintColor = ColorConfiguration.defaultColorTosca
    }
    
    @IBAction func btCheckBoxClickSendNote(_ sender: Any) {
        if (btCheckBoxSendNote.isSelected == true){
             self.btCheckBoxSendNote.setImage(UIImage(named: "ic_uncheck")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btCheckBoxSendNote.isSelected = false
        } else {
             self.btCheckBoxSendNote.setImage(UIImage(named: "ic_check_button")?.withRenderingMode(.alwaysTemplate), for: .selected)
            btCheckBoxSendNote.isSelected = true
        }
        self.btCheckBoxSendNote.tintColor = ColorConfiguration.defaultColorTosca
    }
    
    
    @IBAction func submitResolved(_ sender: Any) {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 1  {
                //admin
                 asAdminOrAgent(value: 1)
            }else if userType == 2{
                //agent
                asAdminOrAgent(value: 0)
            }else{
                asAdminOrAgent(value: 1)
            }
        }else{
             asAdminOrAgent(value: 1)
        }
        
        if  self.viewAlertHSMTemplate.alpha == 1 {
            self.settingTableViewHeightUP()
        } else {
            self.settingTableViewNormal()
        }
    }
    
    @IBAction func cancelResolved(_ sender: Any) {
         view.endEditing(true)
        self.viewResloved.isHidden = true
        
        if  self.viewAlertHSMTemplate.alpha == 1 {
            self.settingTableViewHeightUP()
        } else {
            self.settingTableViewNormal()
        }
        
    }
    
    @objc func goResolve() {
        if let room = QiscusCore.database.room.find(id: self.room?.id ?? ""){
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                let notesData = json["notes"].string ?? ""
                
                self.tvNotes.text = notesData
                placeholderLabel.isHidden = !self.tvNotes.text.isEmpty
            }
        }
        self.viewResloved.isHidden = false
    }
    
    public func datePresentString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        
        let iso8601String = dateFormatter.string(from: date as Date)
        
        return iso8601String
    }
    
    @objc func goActionButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if self.isWaBlocked == false {
            alert.addAction(UIAlertAction(title: "Add Agent", style: .default , handler:{ (UIAlertAction)in
                let vc = AddAgentVC()
                vc.roomName = self.room?.name ?? ""
                vc.roomID = self.room?.id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            
            
            if let userType = UserDefaults.standard.getUserType(){
                if userType == 2 {
                   alert.addAction(UIAlertAction(title: "Assign Chat To", style: .default , handler:{ (UIAlertAction)in
                       let vc = AddAgentVC()
                       vc.roomName = self.room?.name ?? ""
                       vc.roomID = self.room?.id ?? ""
                       vc.isAssignFromAgent = true
                       self.navigationController?.pushViewController(vc, animated: true)
                   }))
                }else{
                    alert.addAction(UIAlertAction(title: "Remove Agent", style: .default , handler:{ (UIAlertAction)in
                        let vc = RemoveAgentVC()
                        vc.roomName = self.room?.name ?? ""
                        vc.roomID = self.room?.id ?? ""
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                }
            }
        }
        
        if let room = self.room{
            if !room.options!.isEmpty{
                let json = JSON.init(parseJSON: room.options!)
                let channelType = json["channel"].string ?? "qiscus"
                
                if channelType.lowercased() == "wa"{
                    if let userType = UserDefaults.standard.getUserType(){
                        if userType == 2 {
                           //no action block unblock contact
                        } else {
                            if self.isWaBlocked == false {
                                alert.addAction(UIAlertAction(title: "Block Contact", style: .destructive , handler:{ (UIAlertAction)in
                                    self.bgViewBlockContact.isHidden = false
                                    self.view.endEditing(true)
                                    self.hideUIRecord(isHidden: true)
                                }))
                            } else {
                                alert.addAction(UIAlertAction(title: "Unblock Contact", style: .destructive , handler:{ (UIAlertAction)in
                                    self.bgViewUnBlockContact.isHidden = false
                                    self.view.endEditing(true)
                                    self.hideUIRecord(isHidden: true)
                                }))
                            }
                        }
                    }
                }
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        
        if let presenter = alert.popoverPresentationController {
            presenter.barButtonItem = actionButton
        }
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func asAdminOrAgent(value : Int){
        if let room = self.room{
            guard let roomLocal = QiscusCore.database.room.find(id: room.id) else {
                return
            }
            
            guard let token = UserDefaults.standard.getAuthenticationToken() else {
                return
            }
            
            var notes = ""
            if let tv = self.tvNotes.text{
                if tv.isEmpty {
                    notes = ""
                }else{
                    notes = tv
                }
            }
            
            var sendEmail = false
            if self.btCheckBox.isSelected == true{
                sendEmail = true
            }
            
            var sendNotes = false
            if self.btCheckBoxSendNote.isSelected == true{
                sendNotes = true
            }
            
            let params = ["room_id": roomLocal.id,
                          "is_send_email": sendEmail,
                          "is_send_notes" : sendNotes,
                          "notes": notes,
                          "last_comment_id": roomLocal.lastComment?.id] as [String : Any]
            
            let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
            
            
            var adminOrAgent = "agent"
            if value == 1{
                adminOrAgent = "admin"
            }
        
            
            Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/\(adminOrAgent)/service/mark_as_resolved", method: .post, parameters: params, headers: header as! HTTPHeaders).responseJSON { (response) in
                print("response call \(response)")
                if response.result.value != nil {
                    if (response.response?.statusCode)! >= 300 {
                        //failed
                        self.viewResloved.isHidden = true
                        if response.response?.statusCode == 401 {
                            RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                                if success == true {
                                    self.asAdminOrAgent(value: value)
                                } else {
                                    return
                                }
                            }
                        }
                    } else {
                       //success
                        
                        QiscusCore.shared.getRoom(withID: roomLocal.id, onSuccess: { (rooms, comments) in
                            self.viewResloved.isHidden = true
                            self.goBack()
                        }, onError: { (error) in
                            self.viewResloved.isHidden = true
                        })
                    }
                } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                   //failed
                } else {
                   //failed
                }
            }
        }
    }
    
    @objc func loadMoreDataMessage(){
        self.presenter.loadMore()
    }
    
    func throthleLoadMore(){
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.loadMoreDataMessage),
                                               object: nil)
        
        perform(#selector(self.loadMoreDataMessage),
                with: nil, afterDelay: 0.5)
    }
    
    @objc func throthleChatTemplate(){
        var keyword = chatTemplatesKeyword
        if keyword.prefix(1) == "/" {
            self.tableViewChatTemplate.isHidden = false
        }else{
            self.tableViewChatTemplate.isHidden = true
            return
        }
        
        if keyword.count == 1 && keyword.prefix(1) == "/"{
            keyword = ""
        }
        
        if keyword.count >= 2 {
            keyword.removeFirst()
            self.chatTemplatesKeyword = keyword
        }else{
             self.chatTemplatesKeyword = keyword
        }
        
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        var appID = ""
        if let dataAppID = UserDefaults.standard.getAppID(){
            appID = dataAppID
        }
        let header = ["Authorization": token,
                      "Qiscus-App-Id" : appID] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v1/chat_templates?q=\(keyword)&limit=100", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if self.chatTemplates.count == 0 {
                        self.tableViewChatTemplate.isHidden = true
                    }
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.throthleChatTemplate()
                            } else {
                                return
                            }
                        }
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                    var resultsChatTemplate = [ChatTemplate]()
                    self.chatTemplates.removeAll()
                    print("response.result.value =\(json)")
                    if let chatTemplates = json["data"]["data"].array {
                        for chatTemplate in chatTemplates {
                            let chatTemplate = ChatTemplate.init(json: chatTemplate)
                            resultsChatTemplate.append(chatTemplate)
                        }
                    }
                    
                    self.chatTemplates = resultsChatTemplate
                    
                    self.tableViewChatTemplate.reloadData()
                    
                    if self.chatTemplates.count == 0 {
                        self.tableViewChatTemplate.isHidden = true
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                if self.chatTemplates.count == 0 {
                    self.tableViewChatTemplate.isHidden = true
                }
            } else {
                //failed
                if self.chatTemplates.count == 0 {
                    self.tableViewChatTemplate.isHidden = true
                }
            }
        }
    }
    
    func getChatTemplate(keyword : String){
        self.chatTemplatesKeyword = keyword
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(self.throthleChatTemplate),
                                               object: nil)
        
        perform(#selector(self.throthleChatTemplate),
                with: nil, afterDelay: 0.5)
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.constraintViewInputBottom.constant = 0
        self.viewPopupResolvedBottomConst.constant = 0
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardChange(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.constraintViewInputBottom.constant = 0 - keyboardHeight
        self.viewPopupResolvedBottomConst.constant = 0 + keyboardHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func getParticipant() -> String {
        var result = ""
        for m in self.presenter.participants {
            if result.isEmpty {
                result = m.username
            }else {
                result = result + ", \(m.username)"
            }
        }
        return result
    }
    
    // MARK : method
    func registerClass(nib: UINib?, forMessageCellWithReuseIdentifier reuseIdentifier: String) {
        self.tableViewConversation.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    
    func setBackground(with image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.transform = imageView.transform.rotated(by: CGFloat(M_PI))
        self.tableViewConversation.isOpaque = false
        self.tableViewConversation.backgroundView =   imageView
    }
    
    func setBackground(with color: UIColor) {
        self.tableViewConversation.backgroundColor = color
    }
    
    func scrollToComment(comment: CommentModel) {
        if let indexPath = self.presenter.getIndexPath(comment: comment) {
            
            self.tableViewConversation.allowsSelection = true
            
            if self.scrollToComment != nil {
                self.scrollToComment = nil
                self.tableViewConversation.scrollToRow(at: indexPath, at: .middle, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let userInfo = ["commentId": comment.id]
                    NotificationCenter.default.post(name: Notification.Name("selectedCell"), object: nil, userInfo : userInfo )
                }
            }
        }else{
            self.presenter.loadMore()
        }
    }
    
    func cellFor(message: CommentModel, at indexPath: IndexPath, in tableView: UITableView) -> UIBaseChatCell {
        let menuConfig = enableMenuConfig()
        var colorName:UIColor = UIColor.lightGray
        if message.type == "text" {
            if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                if message.message.contains("[/file]") == true{
                    var ext = message.getAttachmentURL(message: message.message)
                    if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qImageRightCell", for: indexPath) as! QImageRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
                        cell.isQiscus = self.isQiscus
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qTextRightCell", for: indexPath) as! QTextRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
                        cell.isQiscus = self.isQiscus
                        return cell
                    }
                }else if message.message.contains("[/sticker]") == true{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "qImageRightCell", for: indexPath) as! QImageRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    cell.isQiscus = self.isQiscus
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "qTextRightCell", for: indexPath) as! QTextRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    cell.isQiscus = self.isQiscus
                    return cell
                }
            }else{
                if message.message.contains("[/file]") == true{
                    var ext = message.getAttachmentURL(message: message.message)
                    if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qImageLeftCell", for: indexPath) as! QImageLeftCell
                        if self.room?.type == .group {
                            cell.colorName = colorName
                            cell.isPublic = true
                        }else {
                            cell.isPublic = false
                        }
                        cell.isQiscus = self.isQiscus
                        cell.cellMenu = self
                        return cell
                    }else{
                       let cell = tableView.dequeueReusableCell(withIdentifier: "qTextLeftCell", for: indexPath) as! QTextLeftCell
                        if self.room?.type == .group {
                            cell.colorName = colorName
                            cell.isPublic = true
                        }else {
                            cell.isPublic = false
                        }
                        cell.isQiscus = self.isQiscus
                        cell.cellMenu = self
                        return cell
                    }
                }else if message.message.contains("[/sticker]") == true{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "qImageLeftCell", for: indexPath) as! QImageLeftCell
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    cell.isQiscus = self.isQiscus
                    cell.cellMenu = self
                    return cell
                }else{
                   let cell = tableView.dequeueReusableCell(withIdentifier: "qTextLeftCell", for: indexPath) as! QTextLeftCell
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    cell.isQiscus = self.isQiscus
                    cell.cellMenu = self
                    return cell
                }
                
                
                
            }
        }else if  message.type == "file_attachment" {
            guard let payload = message.payload else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
                return cell
            }
            
            if let url = payload["url"] as? String {
                var caption = ""
                if let captionData = payload["caption"] as? String {
                    caption = captionData
                }
                let ext = message.fileExtension(fromURL:url)
                let urlFile = URL(string: url) ?? URL(string: "https://")
                var isImage = false
                var isVideo = false
                
                if ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif"){
                    isImage = true
                }
                
                if let messageExtras = message.extras {
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
                   
                    if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qImageRightCell", for: indexPath) as! QImageRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
                        cell.isQiscus = self.isQiscus
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qImageLeftCell", for: indexPath) as! QImageLeftCell
                        if self.room?.type == .group {
                            cell.colorName = colorName
                            cell.isPublic = true
                        }else {
                            cell.isPublic = false
                        }
                        cell.isQiscus = self.isQiscus
                        cell.cellMenu = self
                        return cell
                    }
                }else if(urlFile?.containsVideo == true || isVideo == true ) {
                    if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qVideoRightCell", for: indexPath) as! QVideoRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
                        cell.isQiscus = self.isQiscus
                        cell.vc = self
                        return cell
                    }
                    else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qVideoLeftCell", for: indexPath) as! QVideoLeftCell
                        if self.room?.type == .group {
                            cell.colorName = colorName
                            cell.isPublic = true
                        }else {
                            cell.isPublic = false
                        }
                        cell.isQiscus = self.isQiscus
                        cell.cellMenu = self
                        cell.vc = self
                        return cell
                    }
                }else{
                    if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qFileRightCell", for: indexPath) as! QFileRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
                        cell.isQiscus = self.isQiscus
                        cell.vc = self
                        return cell
                    }
                    else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qFileLeftCell", for: indexPath) as! QFileLeftCell
                        if self.room?.type == .group {
                            cell.colorName = colorName
                            cell.isPublic = true
                        }else {
                            cell.isPublic = false
                        }
                        cell.isQiscus = self.isQiscus
                        cell.cellMenu = self
                        cell.vc = self
                        return cell
                    }
                }
            }else{
                if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "qTextRightCell", for: indexPath) as! QTextRightCell
                    cell.menuConfig = menuConfig
                    cell.cellMenu = self
                    cell.isQiscus = self.isQiscus
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "qTextLeftCell", for: indexPath) as! QTextLeftCell
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
                    cell.isQiscus = self.isQiscus
                    cell.cellMenu = self
                    return cell
                }
            }
        }else if message.type == "system_event" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "qSystemCell", for: indexPath) as! QSystemCell
            
            return cell
        }else if message.type == "account_linking" {
            if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "postBackRight", for: indexPath) as! QPostbackRightCell
                cell.delegateChat = self
                cell.isQiscus = self.isQiscus
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postBack", for: indexPath) as! QPostbackLeftCell
                cell.isQiscus = self.isQiscus
                cell.delegateChat = self
                return cell
            }
        }else if message.type == "buttons" {
            if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "postBackRight", for: indexPath) as! QPostbackRightCell
                cell.delegateChat = self
                cell.isQiscus = self.isQiscus
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postBack", for: indexPath) as! QPostbackLeftCell
                cell.isQiscus = self.isQiscus
                cell.delegateChat = self
                return cell
            }
        }else if message.type == "button_postback_response" {
            if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "qTextRightCell", for: indexPath) as! QTextRightCell
                cell.menuConfig = menuConfig
                cell.cellMenu = self
                cell.isQiscus = self.isQiscus
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "qTextLeftCell", for: indexPath) as! QTextLeftCell
                if self.room?.type == .group {
                    cell.colorName = colorName
                    cell.isPublic = true
                }else {
                    cell.isPublic = false
                }
                cell.isQiscus = self.isQiscus
                cell.cellMenu = self
                return cell
            }
        }else if message.type == "carousel"{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "qCarouselCell", for: indexPath) as! QCarouselCell
            cell.delegateChat = self
            if self.room?.type == .group {
                cell.isPublic = true
            }else {
                cell.isPublic = false
            }
            cell.isQiscus = self.isQiscus
            return cell
        }else if message.type == "card" {
            if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                let cell =  tableView.dequeueReusableCell(withIdentifier: "qCardRightCell", for: indexPath) as! QCardRightCell
                cell.delegateChat = self
                cell.isQiscus = self.isQiscus
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "qCardLeftCell", for: indexPath) as! QCardLeftCell
                cell.delegateChat = self
                if self.room?.type == .group {
                    cell.isPublic = true
                    cell.colorName = colorName
                }else {
                    cell.isPublic = false
                }
                cell.isQiscus = self.isQiscus
                return cell
            }
            
        }else if message.type == "location" {
            if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                let cell =  tableView.dequeueReusableCell(withIdentifier: "qLocationRightCell", for: indexPath) as! QLocationRightCell
                cell.isQiscus = self.isQiscus
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "qLocationLeftCell", for: indexPath) as! QLocationLeftCell
                if self.room?.type == .group {
                    cell.isPublic = true
                    cell.colorName = colorName
                }else {
                    cell.isPublic = false
                }
                cell.isQiscus = self.isQiscus
                return cell
            }
            
        } else if message.type == "reply" {
            if let typeReply = message.payload?["replied_comment_type"] as? String {
                if  typeReply == "file_attachment" ||  typeReply == "location" || typeReply == "text" || typeReply == "reply" || typeReply == "unknown" {
                    guard let payload = message.payload else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
                        return cell
                    }
                    
                    if let url = payload["replied_comment_payload"] as? [String:Any] {
                        if let url = url["url"] as? String {
                            let ext = message.fileExtension(fromURL:url)
                            if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                                if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyImageRightCell", for: indexPath) as! QReplyImageRightCell
                                    cell.menuConfig = menuConfig
                                    cell.cellMenu = self
                                    cell.isQiscus = self.isQiscus
                                    return cell
                                }else{
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyImageLeftCell", for: indexPath) as! QReplyImageLeftCell
                                    if self.room?.type == .group {
                                        cell.colorName = colorName
                                        cell.isPublic = true
                                    }else {
                                        cell.isPublic = false
                                    }
                                    cell.isQiscus = self.isQiscus
                                    cell.cellMenu = self
                                    return cell
                                }
                            }else{
                                if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyRightCell", for: indexPath) as! QReplyRightCell
                                    cell.menuConfig = menuConfig
                                    cell.cellMenu = self
                                    cell.isQiscus = self.isQiscus
                                    cell.delegateChat = self
                                    return cell
                                }
                                else{
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyLeftCell", for: indexPath) as! QReplyLeftCell
                                    if self.room?.type == .group {
                                        cell.colorName = colorName
                                        cell.isPublic = true
                                    }else {
                                        cell.isPublic = false
                                    }
                                    cell.delegateChat = self
                                    cell.cellMenu = self
                                    cell.isQiscus = self.isQiscus
                                    return cell
                                }
                            }
                        }else{
                            if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                                let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyRightCell", for: indexPath) as! QReplyRightCell
                                cell.menuConfig = menuConfig
                                cell.cellMenu = self
                                cell.isQiscus = self.isQiscus
                                cell.delegateChat = self
                                return cell
                            }else{
                                let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyLeftCell", for: indexPath) as! QReplyLeftCell
                                if self.room?.type == .group {
                                    cell.colorName = colorName
                                    cell.isPublic = true
                                }else {
                                    cell.isPublic = false
                                }
                                cell.delegateChat = self
                                cell.cellMenu = self
                                cell.isQiscus = self.isQiscus
                                return cell
                            }
                        }
                    }else{
                        if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                            let cell = tableView.dequeueReusableCell(withIdentifier: "qTextRightCell", for: indexPath) as! QTextRightCell
                            cell.menuConfig = menuConfig
                            cell.cellMenu = self
                            cell.isQiscus = self.isQiscus
                            return cell
                        }else{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "qTextLeftCell", for: indexPath) as! QTextLeftCell
                            if self.room?.type == .group {
                                cell.colorName = colorName
                                cell.isPublic = true
                            }else {
                                cell.isPublic = false
                            }
                            cell.isQiscus = self.isQiscus
                            cell.cellMenu = self
                            return cell
                        }
                    }
                }else{
                    if (message.isMyComment() == true || (!message.userEmail.contains(userID) && !userID.isEmpty)){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyRightCell", for: indexPath) as! QReplyRightCell
                        cell.menuConfig = menuConfig
                        cell.isQiscus = self.isQiscus
                        cell.cellMenu = self
                        cell.delegateChat = self
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyLeftCell", for: indexPath) as! QReplyLeftCell
                        if self.room?.type == .group {
                            cell.colorName = colorName
                            cell.isPublic = true
                        }else {
                            cell.isPublic = false
                        }
                        cell.isQiscus = self.isQiscus
                        cell.delegateChat = self
                        cell.cellMenu = self
                        return cell
                    }
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
                return cell
            }
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
            return cell
        }
    }
}

// MARK: UIChatDelegate
extension UIChatViewController: UIChatViewDelegate {
    func onReloadComment(){
        self.tableViewConversation.reloadData()
    }
    func onUpdateComment(comment: CommentModel, indexpath: IndexPath) {
        // reload cell in section and index path
        if self.tableViewConversation.dataHasChanged {
            self.tableViewConversation.reloadData()
        } else {
           self.tableViewConversation.reloadRows(at: [indexpath], with: .none)
        }
    }
    
    func onLoadMessageFailed(message: String) {
        //
    }
    
    func onUser(name: String, isOnline: Bool, message: String) {
        self.chatTitleView.labelSubtitle.text = message
    }
    
    func onUser(name: String, typing: Bool) {
        if typing {
            if let room = self.presenter.room {
                if room.type == .group {
                    self.chatTitleView.labelSubtitle.text = "\(name) is Typing..."
                }else {
                    self.chatTitleView.labelSubtitle.text = "is Typing..."
                }
            }
        }else {
            if let room = self.presenter.room {
                if room.type == .group {
                    self.chatTitleView.labelSubtitle.text = getParticipant()
                }else{
                    self.chatTitleView.labelSubtitle.text = "Online"
                }
            }
        }
    }
    
    func onSendingComment(comment: CommentModel, newSection: Bool) {
        if newSection {
            self.tableViewConversation.beginUpdates()
            self.tableViewConversation.insertSections(IndexSet(integer: 0), with: .left)
            self.tableViewConversation.endUpdates()
        } else {
            let indexPath = IndexPath(row: 0, section: 0) // all view rotate because of this
            self.tableViewConversation.beginUpdates()
            self.tableViewConversation.insertRows(at: [indexPath], with: .left)
            self.tableViewConversation.endUpdates()
        }
    }
    
    func onLoadRoomFinished(roomName: String, roomAvatarURL: URL?) {
        if let _room = room {
            self.chatTitleView.room = _room
        }
        
        if self.presenter.comments.count == 0 {
            self.tableViewConversation.isHidden = true
            self.emptyMessageView.alpha = 1
        }else{
            self.tableViewConversation.isHidden = false
            self.emptyMessageView.alpha = 0
        }
    }
    
    func onLoadMoreMesageFinished() {
        self.tableViewConversation.reloadData()
        
        if let searchComment = scrollToComment{
            self.scrollToComment(comment: searchComment)
        }
    }
    
    func onLoadMessageFinished() {
        if self.presenter.comments.count == 0 {
            self.tableViewConversation.isHidden = true
            self.emptyMessageView.alpha = 1
        }else{
            self.tableViewConversation.isHidden = false
            self.emptyMessageView.alpha = 0
        }
        
        self.tableViewConversation.reloadData()
        if let searchComment = scrollToComment{
            self.scrollToComment(comment: searchComment)
        }
    }
    
    func onSendMessageFinished(comment: CommentModel) {
        
    }
    
    func onGotNewComment(newSection: Bool) {
        if self.presenter.comments.count == 0 {
            self.tableViewConversation.isHidden = true
            self.emptyMessageView.alpha = 1
        }else{
            if(self.tableViewConversation.isHidden == true){
                self.tableViewConversation.isHidden = false
                self.emptyMessageView.alpha = 0
            }
        }
        
        if Thread.isMainThread {
            if newSection {
                self.tableViewConversation.beginUpdates()
                self.tableViewConversation.insertSections(IndexSet(integer: 0), with: .right)
                self.tableViewConversation.endUpdates()
                self.tableViewConversation.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableViewConversation.beginUpdates()
                self.tableViewConversation.insertRows(at: [indexPath], with: .right)
                self.tableViewConversation.endUpdates()
                self.tableViewConversation.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                
            }
        }
        
        
        if let room = QiscusCore.database.room.find(id: self.room!.id){
            let lastComment = room.lastComment
            
            if lastComment?.message.contains("Message failed to send because more than 24 hours") == true {
                //call throthle
                NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                       selector: #selector(self.checkIFTypeWAExpired),
                                                       object: nil)
                
                perform(#selector(self.checkIFTypeWAExpired),
                        with: nil, afterDelay: 1)
            } else if lastComment?.message.contains("Admin unblocked this contact") == true{
                self.isWaBlocked = false
                self.setupNavigationTitle()
                self.setupToolbarHandle()
            } else if lastComment?.message.contains("Admin blocked this contact") == true{
                self.isWaBlocked = true
                self.setupNavigationTitle()
                self.setupToolbarHandle()
            }
        }
    }
}

extension UIChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewChatTemplate {
            return self.chatTemplates.count
        } else {
            let sectionCount = self.presenter.comments.count
            let rowCount = self.presenter.comments[section].count
            if sectionCount == 0 {
                return 0
            }
            return rowCount
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableViewChatTemplate {
            return 1
        } else {
            return self.presenter.comments.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: table cell confi
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get mesage at indexpath
        
        if tableView == self.tableViewChatTemplate {
            let cell = tableViewChatTemplate.dequeueReusableCell(withIdentifier: ChatTemplateCell.identifier, for: indexPath) as! ChatTemplateCell

            cell.lbCommand.text = self.chatTemplates[indexPath.row].command
            cell.lbMessageTemplate.text = self.chatTemplates[indexPath.row].message
            return cell
        } else {
            let comment = self.presenter.getMessage(atIndexPath: indexPath)
            var cell = self.cellFor(message: comment, at: indexPath, in: tableView)
            cell.comment = comment
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            
            // Load More
            let comments = self.presenter.comments
            if indexPath.section == comments.count - 1 && indexPath.row > comments[indexPath.section].count - 10 {
                self.throthleLoadMore()
            }
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.tableViewChatTemplate {
            return 0.01
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.tableViewChatTemplate {
            return nil
        } else {
           if let firstMessageInSection = self.presenter.comments[section].first {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM"
                let dateString = dateFormatter.string(from: firstMessageInSection.date)
                
                let label = DateHeaderLabel()
                label.text = dateString
                
                let containerView = UIView()
                containerView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                containerView.addSubview(label)
                label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                
                return containerView
                
            }
            return nil
        }
    }
    
}

extension UIChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if tableView == self.tableViewChatTemplate {
            return false
        } else {
            return true
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewChatTemplate {
            self.chatInput.textView.text = self.chatTemplates[indexPath.row].message
            self.tableViewChatTemplate.isHidden = true
            
            var maximumLabelSize: CGSize = CGSize(width: self.chatInput.textView.frame.size.width, height: 170)
            var expectedLabelSize: CGSize = self.chatInput.textView.sizeThatFits(maximumLabelSize)
          
            if expectedLabelSize.height >= 170 {
                 self.constraintViewInputHeight.constant = 170
            } else if expectedLabelSize.height <= 48 {
                self.constraintViewInputHeight.constant = 48
            } else {
                self.constraintViewInputHeight.constant = expectedLabelSize.height
            }
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            // get mesage at indexpath
            let comment = self.presenter.getMessage(atIndexPath: indexPath)
            self.chatDelegate?.uiChat(viewController: self, didSelectMessage: comment)
        }
    }
    
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if tableView == self.tableViewChatTemplate {
            return false
        } else {
            let comment = self.presenter.getMessage(atIndexPath: indexPath)
            if let response = self.chatDelegate?.uiChat(viewController: self, canPerformAction: action, forRowAtmessage: comment, withSender: sender) {
                return response
            }else {
                return false
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if tableView == self.tableViewChatTemplate {
            
        } else {
            let comment = self.presenter.getMessage(atIndexPath: indexPath)
            self.chatDelegate?.uiChat(viewController: self, performAction: action, forRowAt: comment, withSender: sender)
        }
    }
    
}

extension UIChatViewController : UIChatView {
    func uiChat(viewController: UIChatViewController, didSelectMessage message: CommentModel) {
        
    }
    
    func uiChat(viewController: UIChatViewController, performAction action: Selector, forRowAt message: CommentModel, withSender sender: Any?) {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.message
        }
    }
    
    func uiChat(viewController: UIChatViewController, canPerformAction action: Selector, forRowAtmessage: CommentModel, withSender sender: Any?) -> Bool {
        switch action.description {
        case "copy:":
            return true
        case "deleteComment:":
            return true
        case "replyComment:":
            return true
        default:
            return false
        }
    }
    
    func uiChat(viewController: UIChatViewController, firstMessage message: CommentModel, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension UIChatViewController : UIChatInputDelegate {
    func onHeightChanged(height: CGFloat) {
        self.constraintViewInputHeight.constant = height
    }
    
    func typing(_ value: Bool, query : String) {
        self.presenter.isTyping(value)
        if value == true {
            self.getChatTemplate(keyword: query)
        }
        
    }
    
    func send(message: CommentModel,onSuccess: @escaping (CommentModel) -> Void, onError: @escaping (String) -> Void) {
        self.presenter.sendMessage(withComment: message, onSuccess: { (comment) in
            if(self.tableViewConversation.isHidden == true){
                self.tableViewConversation.isHidden = false
                self.emptyMessageView.alpha = 0
            }
            self.presenter.isTyping(false)
            onSuccess(comment)
        }) { (error) in
            self.presenter.isTyping(false)
            onError(error)
        }
    }
    
    func hideUIRecord(isHidden : Bool){
         recordButton.isHidden = isHidden
    }
}

//// MARK: Handle Cell Menu
extension UIChatViewController : UIBaseChatCellDelegate {
    func didTap(delete comment: CommentModel) {
        QiscusCore.shared.deleteMessage(uniqueIDs: [comment.uniqId], onSuccess: { (commentsModel) in
            print("success delete comment for everyone")
        }) { (error) in
            print("failed delete comment for everyone")
        }
    }
    
    func didTap(reply comment: CommentModel) {
        self.chatInput.replyData = comment
        if usersColor.count != 0{
            if let email = self.chatInput.replyData?.userEmail, let color = usersColor[email] {
                self.chatInput.colorName = color
            }
        }
        self.chatInput.showPreviewReply()
    }
}

extension UIChatViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.tableViewChatTemplate) == true {
            return false
        }
        return true
    }
}


extension UITableView {
    var dataHasChanged: Bool {
        guard let dataSource = dataSource else { return false }
        let sections = dataSource.numberOfSections?(in: self) ?? 0
        if numberOfSections != sections {
            return true
        }
        for section in 0..<sections {
            if numberOfRows(inSection: section) != dataSource.tableView(self, numberOfRowsInSection: section) {
                return true
            }
        }
        return false
    }
}

// MARK: - iRecordView
extension UIChatViewController: RecordViewDelegate{
    func onStart() {
        print("onStart")
        self.chatInput.prepareRecording()
    }
    
    func onCancel() {
        self.chatInput.cancelRecord()
        print("onCancel")
    }
    
    func onFinished(duration: CGFloat) {
        print("onFinished \(duration)")
        self.chatInput.onFinishRecording()
        
    }
    
    func onAnimationEnd() {
        print("onAnimationEnd")
    }
}
