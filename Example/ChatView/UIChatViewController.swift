//
//  QChatVC.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 07/05/18.
//

import UIKit
import ContactsUI
import SwiftyJSON
import QiscusCore
import Alamofire
import iRecordView

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

class UIChatViewController: UIViewController, UITextViewDelegate {
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
    @IBOutlet weak var btSubmitResolved: UIButton!
    @IBOutlet weak var btCancelSubmit: UIButton!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var tableViewChatTemplate: UITableView!
    @IBOutlet weak var topProgressBar: NSLayoutConstraint!
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
    
    open func getProgressBar() -> UIProgressView {
        return progressBar
    }
    
    open func getProgressBarHeight() ->  NSLayoutConstraint{
        return heightProgressBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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

        view.endEditing(true)

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        self.tableViewChatTemplate.isHidden = true
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

    
    func setupToolbarHandle(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        self.chatTitleView.isUserInteractionEnabled = true
        self.chatTitleView.addGestureRecognizer(tap)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if let room = self.room {
            var channelTypeString = ""
            let vc = ChatAndCustomerInfoVC()
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
                }else{
                    channelTypeString = "Qiscus Widget"
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
        
//        if hasTopNotch() == true {
//            self.topProgressBar.constant = 0
//        } else {
//            self.topProgressBar.constant = 65
//        }
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            
            print("arief check topPadding =\(topPadding)")
            self.topProgressBar.constant = 0
        }else {
            self.topProgressBar.constant = 65
        }
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
        recordButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -8).isActive = true
        

        recordView.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -20).isActive = true
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
                        let actionButton = self.actionButton(self, action:  #selector(UIChatViewController.goActionButton))
                        
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
        self.tableViewConversation.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
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
        self.registerClass(nib: UINib(nibName: "QCarouselCell", bundle: nil), forMessageCellWithReuseIdentifier: "qCarouselCell")
        self.registerClass(nib: UINib(nibName: "QCardRightCell", bundle: nil), forMessageCellWithReuseIdentifier: "qCardRightCell")
        self.registerClass(nib: UINib(nibName: "QCardLeftCell", bundle: nil ), forMessageCellWithReuseIdentifier: "qCardLeftCell")
        
        self.registerClass(nib: UINib(nibName: "QReplyTextRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyTextRightCell")
        self.registerClass(nib: UINib(nibName: "QReplyTextLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyTextLeftCell")
        
         self.registerClass(nib: UINib(nibName: "QReplyImageRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyImageRightCell")
         self.registerClass(nib: UINib(nibName: "QReplyImageLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qReplyImageLeftCell")
        
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
            if userType == 1 {
                 asAdminOrAgent(value: 1)
            }else{
                asAdminOrAgent(value: userType)
            }
        }else{
             asAdminOrAgent(value: 0)
        }
    }
    
    @IBAction func cancelResolved(_ sender: Any) {
         view.endEditing(true)
        self.viewResloved.isHidden = true
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
    
    @objc func goActionButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
        
       
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
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
            self.tableViewConversation.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func cellFor(message: CommentModel, at indexPath: IndexPath, in tableView: UITableView) -> UIBaseChatCell {
        let menuConfig = enableMenuConfig()
        var colorName:UIColor = UIColor.lightGray
        if message.type == "text" {
            if (message.isMyComment() == true){
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
                        cell.cellMenu = self
                        return cell
                    }
                }else{
                   let cell = tableView.dequeueReusableCell(withIdentifier: "qTextLeftCell", for: indexPath) as! QTextLeftCell
                    if self.room?.type == .group {
                        cell.colorName = colorName
                        cell.isPublic = true
                    }else {
                        cell.isPublic = false
                    }
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
                let ext = message.fileExtension(fromURL:url)
                if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                    if (message.isMyComment() == true){
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
                        cell.cellMenu = self
                        return cell
                    }
                }else{
                    if (message.isMyComment() == true){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qFileRightCell", for: indexPath) as! QFileRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
                        cell.isQiscus = self.isQiscus
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
                        cell.cellMenu = self
                        return cell
                    }
                }
            }else{
                if (message.isMyComment() == true){
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
                    cell.cellMenu = self
                    return cell
                }
            }
        }else if message.type == "system_event" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "qSystemCell", for: indexPath) as! QSystemCell
            
            return cell
        }else if message.type == "account_linking" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postBack", for: indexPath) as! QPostbackLeftCell
            cell.delegateChat = self
            return cell
        }else if message.type == "buttons" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postBack", for: indexPath) as! QPostbackLeftCell
            cell.delegateChat = self
            return cell
        }else if message.type == "button_postback_response" {
            if (message.isMyComment() == true){
                let cell = tableView.dequeueReusableCell(withIdentifier: "qTextRightCell", for: indexPath) as! QTextRightCell
                cell.menuConfig = menuConfig
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
            return cell
        }else if message.type == "card" {
            if (message.isMyComment() == true){
                let cell =  tableView.dequeueReusableCell(withIdentifier: "qCardRightCell", for: indexPath) as! QCardRightCell
                cell.delegateChat = self
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
                return cell
            }
            
        } else if message.type == "reply" {
            if let typeReply = message.payload?["replied_comment_type"] as? String {
                if typeReply == "text" || typeReply == "reply"{
                    if (message.isMyComment() == true){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyTextRightCell", for: indexPath) as! QReplyTextRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
                        cell.isQiscus = self.isQiscus
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qReplyTextLeftCell", for: indexPath) as! QReplyTextLeftCell
                        if self.room?.type == .group {
                            cell.colorName = colorName
                            cell.isPublic = true
                        }else {
                            cell.isPublic = false
                        }
                        cell.cellMenu = self
                        return cell
                    }
                }else if  typeReply == "file_attachment" {
                    guard let payload = message.payload else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
                        return cell
                    }
                    
                    if let url = payload["replied_comment_payload"] as? [String:Any] {
                        if let url = url["url"] as? String {
                            let ext = message.fileExtension(fromURL:url)
                            if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                                if (message.isMyComment() == true){
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
                                    cell.cellMenu = self
                                    return cell
                                }
                            }else{
                                if (message.isMyComment() == true){
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qTextRightCell", for: indexPath) as! QTextRightCell
                                    cell.menuConfig = menuConfig
                                    cell.cellMenu = self
                                    cell.isQiscus = self.isQiscus
                                    return cell
                                    //noted will support reply type file in next release
//                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qFileRightCell", for: indexPath) as! QFileRightCell
//                                    cell.menuConfig = menuConfig
//                                    cell.cellMenu = self
//                                    return cell
                                }
                                else{
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qTextLeftCell", for: indexPath) as! QTextLeftCell
                                    if self.room?.type == .group {
                                        cell.colorName = colorName
                                        cell.isPublic = true
                                    }else {
                                        cell.isPublic = false
                                    }
                                    cell.cellMenu = self
                                    return cell
                                    //noted will support reply type file in next release
//                                    let cell = tableView.dequeueReusableCell(withIdentifier: "qFileLeftCell", for: indexPath) as! QFileLeftCell
//                                    if self.room?.type == .group {
//                                        cell.colorName = colorName
//                                        cell.isPublic = true
//                                    }else {
//                                        cell.isPublic = false
//                                    }
//                                    cell.cellMenu = self
//                                    return cell
                                }
                            }
                        }else{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
                            return cell
                        }
                    }else{
                        if (message.isMyComment() == true){
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
                            cell.cellMenu = self
                            return cell
                        }
                    }
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
                    return cell
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
                presenter.loadMore()
            }
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.tableViewChatTemplate {
            return 0.01
        } else {
            return 20
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
