//
//  QChatVC.swift
//  Qiscus
//
//  Created by Arief Nur Putranto on 07/05/18.
//

import UIKit
import ContactsUI
import SwiftyJSON
import QiscusCore

// Chat view blue print or function
protocol UIChatView2 {
    func uiChat(viewController : UIChatViewController2, didSelectMessage message: QMessage)
    func uiChat(viewController : UIChatViewController2, performAction action: Selector, forRowAt message: QMessage, withSender sender: Any?)
    func uiChat(viewController : UIChatViewController2, canPerformAction action: Selector, forRowAtmessage: QMessage, withSender sender: Any?) -> Bool
    func uiChat(viewController : UIChatViewController2, firstMessage message: QMessage, viewForHeaderInSection section: Int) -> UIView?
}

class DateHeaderLabel2: UILabel {
    
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

class UIChatViewController2: UIViewController {
    @IBOutlet weak var tableViewConversation: UITableView!
    @IBOutlet weak var viewChatInput: UIView!
    @IBOutlet weak var constraintViewInputBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintViewInputHeight: NSLayoutConstraint!
    @IBOutlet weak var emptyMessageView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var heightProgressBar: NSLayoutConstraint!
    
    var chatTitleView : UIChatNavigation = UIChatNavigation()
    var chatInput : CustomChatInput2 = CustomChatInput2()
    private var presenter: UIChatPresenter2 = UIChatPresenter2()
    
    var heightAtIndexPath: [String: CGFloat] = [:]
    var roomId: String = ""
    var chatDelegate : UIChatView2? = nil
    
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
    var room : QChatRoom? {
        set(newValue) {
            self.presenter.room = newValue
            self.refreshUI()
        }
        get {
            return self.presenter.room
        }
    }
    
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
        center.addObserver(self, selector: #selector(UIChatViewController2.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(UIChatViewController2.keyboardChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        center.addObserver(self,selector: #selector(reSubscribeRoom(_:)), name: Notification.Name(rawValue: "reSubscribeRoom"),object: nil)
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "reSubscribeRoom"), object: nil)
        view.endEditing(true)
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
        if self.room != nil {
            if self.room?.type == .group{
                let vc = RoomInfoVC()
                vc.room = room
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                // no action for type single
            }
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
        
    }
    
    private func setupInputBar(_ inputchatview: UIChatInput2) {
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
        
        let backButton = self.backButton(self, action: #selector(UIChatViewController2.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.chatTitleView = UIChatNavigation(frame: self.navigationController?.navigationBar.frame ?? CGRect.zero)
        self.navigationItem.titleView = chatTitleView
        self.chatTitleView.room = room
        
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = #colorLiteral(red: 0.5176470588, green: 0.7607843137, blue: 0.3803921569, alpha: 1)
        
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
    
    private func setupTableView() {
        let rotate = CGAffineTransform(rotationAngle: .pi)
        self.tableViewConversation.transform = rotate
        self.tableViewConversation.scrollIndicatorInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: UIScreen.main.bounds.width - 8)
        self.tableViewConversation.rowHeight = UITableView.automaticDimension
        self.tableViewConversation.dataSource = self
        self.tableViewConversation.delegate = self
        self.tableViewConversation.scrollsToTop = false
        self.tableViewConversation.allowsSelection = false
        self.chatDelegate = self
        
        // support variation comment type
        self.registerClass(nib: UINib(nibName: "QTextRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qTextRightCell")
        self.registerClass(nib: UINib(nibName: "QTextLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qTextLeftCell")
        self.registerClass(nib: UINib(nibName: "QImageRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qImageRightCell")
        self.registerClass(nib: UINib(nibName: "QFileRightCell", bundle:nil), forMessageCellWithReuseIdentifier: "qFileRightCell")
         self.registerClass(nib: UINib(nibName: "QFileLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qFileLeftCell")
        self.registerClass(nib: UINib(nibName: "QImageLeftCell", bundle:nil), forMessageCellWithReuseIdentifier: "qImageLeftCell")
        self.registerClass(nib: UINib(nibName: "EmptyCell", bundle:nil), forMessageCellWithReuseIdentifier: "emptyCell")
        
    }
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.constraintViewInputBottom.constant = 0
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
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func getParticipant() -> String {
        var result = ""
        for m in self.presenter.participants {
            if result.isEmpty {
                result = m.name
            }else {
                result = result + ", \(m.name)"
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
    
    func scrollToComment(comment: QMessage) {
        if let indexPath = self.presenter.getIndexPath(comment: comment) {
            self.tableViewConversation.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func cellFor(message: QMessage, at indexPath: IndexPath, in tableView: UITableView) -> UIBaseChatCell {
        let menuConfig = enableMenuConfig()
        var colorName:UIColor = UIColor.lightGray
        
        if message.type == "text" {
            if (message.isMyComment2() == true){
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
        }else if  message.type == "file_attachment" {
            guard let payload = message.payload else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
                    return cell
            }
                
            if let url = payload["url"] as? String {
                let ext = message.fileExtension(fromURL:url)
                if(ext.contains("jpg") || ext.contains("png") || ext.contains("heic") || ext.contains("jpeg") || ext.contains("tif") || ext.contains("gif")){
                    if (message.isMyComment2() == true){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qImageRightCell", for: indexPath) as! QImageRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
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
                    if (message.isMyComment2() == true){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "qFileRightCell", for: indexPath) as! QFileRightCell
                        cell.menuConfig = menuConfig
                        cell.cellMenu = self
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
                if (message.isMyComment2() == true){
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
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
            return cell
        }
    }
}

// MARK: UIChatDelegate
extension UIChatViewController2: UIChatViewDelegate2 {
    func onReloadComment(){
        self.tableViewConversation.reloadData()
    }
    func onUpdateComment(comment: QMessage, indexpath: IndexPath) {
        // reload cell in section and index path
        if self.tableViewConversation.cellForRow(at: indexpath) != nil{
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
    
    func onSendingComment(comment: QMessage, newSection: Bool) {
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
    
    func onSendMessageFinished(comment: QMessage) {
        
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
                self.tableViewConversation.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                self.tableViewConversation.endUpdates()
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableViewConversation.beginUpdates()
                self.tableViewConversation.insertRows(at: [indexPath], with: .right)
                self.tableViewConversation.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                self.tableViewConversation.endUpdates()
            }
        }
    }
}

extension UIChatViewController2: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = self.presenter.comments.count
        let rowCount = self.presenter.comments[section].count
        if sectionCount == 0 {
            return 0
        }
        return rowCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.comments.count
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let firstMessageInSection = self.presenter.comments[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            let dateString = dateFormatter.string(from: firstMessageInSection.timestamp)
            
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

extension UIChatViewController2: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // get mesage at indexpath
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        self.chatDelegate?.uiChat(viewController: self, didSelectMessage: comment)
    }
    
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        if let response = self.chatDelegate?.uiChat(viewController: self, canPerformAction: action, forRowAtmessage: comment, withSender: sender) {
            return response
        }else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        self.chatDelegate?.uiChat(viewController: self, performAction: action, forRowAt: comment, withSender: sender)
    }
    
}

extension UIChatViewController2 : UIChatView2 {
    func uiChat(viewController: UIChatViewController2, didSelectMessage message: QMessage) {
        
    }
    
    func uiChat(viewController: UIChatViewController2, performAction action: Selector, forRowAt message: QMessage, withSender sender: Any?) {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.message
        }
    }
    
    func uiChat(viewController: UIChatViewController2, canPerformAction action: Selector, forRowAtmessage: QMessage, withSender sender: Any?) -> Bool {
        switch action.description {
        case "copy:":
            return true
        case "deleteComment:":
            return true
        default:
            return false
        }
    }
    
    func uiChat(viewController: UIChatViewController2, firstMessage message: QMessage, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension UIChatViewController2 : UIChatInputDelegate2 {
    func onHeightChanged(height: CGFloat) {
        self.constraintViewInputHeight.constant = height
    }
    
    func typing(_ value: Bool) {
        self.presenter.isTyping(value)
    }
    
    func send(message: QMessage,onSuccess: @escaping (QMessage) -> Void, onError: @escaping (String) -> Void) {
        
        if message.chatRoomId.isEmpty{
            if let room = self.room{
                message.chatRoomId = room.id
            }
        }
        
        if let data = QiscusCoreManager.qiscusCore2.getUserData(){
            message.userAvatarUrl = data.avatarUrl
            message.userEmail = data.id
            message.name    = data.name
        }
        
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
}

//// MARK: Handle Cell Menu
extension UIChatViewController2 : UIBaseChatCellDelegate {
    func didTap(delete comment: QMessage) {
        QiscusCoreManager.qiscusCore2.shared.deleteMessages(messageUniqueIds: [comment.uniqueId], onSuccess: { (commentsModel) in
            print("success delete comment for everyone")
        }) { (error) in
            print("failed delete comment for everyone")
        }
    }
}
