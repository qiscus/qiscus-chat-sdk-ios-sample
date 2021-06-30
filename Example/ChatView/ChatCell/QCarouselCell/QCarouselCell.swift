//
//  QCarouselCell.swift
//  Pods
//
//  Created by asharijuang on 02/11/18.
//

import UIKit
import QiscusCore
import SwiftyJSON

class QCarouselCell: UIBaseChatCell {
    @IBOutlet weak var carouselView: UICollectionView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var carouselTrailing: NSLayoutConstraint!
    @IBOutlet weak var carouselLeading: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var carouselHeight: NSLayoutConstraint!
    var sizeCarousel : CGSize = CGSize(width: 0, height: 0)
    var delegateChat : UIChatViewController? = nil
    var isPublic: Bool = false
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var uiViewBackground: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    var isQiscus : Bool = false
    var message: CommentModel? = nil
    public var cards = [QCard](){
        didSet{
            self.carouselView.reloadData()
            if let c = self.comment {
                if c.userEmail == QiscusCore.getProfile()?.email {
                    if cards.count > 0 {
                        if cards.count == 1 {
                            self.carouselLeading.constant = QiscusHelper.screenWidth() - (QiscusHelper.screenWidth() * 0.75 + 32)
                        }else{
                            self.carouselLeading.constant = 0
                        }
                        let lastIndex = IndexPath(item: cards.count - 1, section: 0)
                        self.carouselView.scrollToItem(at: lastIndex, at: .left, animated: false)
                    }
                }else{
                    self.carouselLeading.constant = 0
                }
            }
        }
    }
    
    //public var cellCarouselDelegate:QCellCarouselDelegate?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setMenu(isQiscus: false)
        self.carouselView.register(UINib(nibName: "QCarouselCardCell",bundle: nil), forCellWithReuseIdentifier: "cellCardCarousel")
        carouselView.delegate = self
        carouselView.dataSource = self
        carouselView.clipsToBounds = true
        
        self.layer.zPosition = 99
        
        self.uiViewBackground.layer.shadowColor = UIColor.black.cgColor
        self.uiViewBackground.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.uiViewBackground.layer.shadowOpacity = 0.3
        self.uiViewBackground.layer.shadowRadius = 1.0
        self.uiViewBackground.layer.cornerRadius = 8
        
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
    
    override public func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
    }
    
    override public func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.message = message
        self.status(message: message)
        self.lbTime.text = self.hour(date: message.date())
        let payload = JSON(message.payload)
        
        var cards = payload["cards"].arrayValue
        var allCards = [QCard]()
        for cardData in cards {
            let card = QCard(json: cardData)
            allCards.append(card)
        }
        
        self.cards = allCards
        
        if let c = self.comment {
            var leftSpace = CGFloat(0)
            var rightSpace = CGFloat(0)
            
            if c.userEmail == QiscusCore.getProfile()?.email {
                self.userNameLabel.textAlignment = .right
                rightSpace = 15
            }else{
                self.userNameLabel.textAlignment = .left
                leftSpace = 42
            }
            
            let layout:UICollectionViewFlowLayout =  UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: leftSpace, bottom: 0, right: rightSpace)
            layout.scrollDirection = .horizontal
            
            self.carouselView.collectionViewLayout = layout
            
            if(self.isPublic == true){
                if c.isMyComment() {
                    self.lbNameHeight.constant = 0
                } else {
                    self.lbNameHeight.constant = 20
                    self.userNameLabel.text = c.username
                    self.userNameLabel.textColor = ColorConfiguration.otherAgentRightBallonColor
                }
                
                self.userNameLabel.isHidden = false
               // self.topMargin.constant = 20
            }else{
                self.userNameLabel.text = ""
                self.userNameLabel.isHidden = true
               // self.topMargin.constant = 0
            }
        
            var attributedText = NSMutableAttributedString(string: message.message)
            let allRange = (message.message as NSString).range(of: message.message)
            attributedText.addAttributes(self.textAttribute, range: allRange)
            
            let textView = UITextView()
            if message.type == "carousel" {
                textView.font = UIFont.systemFont(ofSize: 12)
            }
            textView.dataDetectorTypes = .all
            textView.linkTextAttributes = self.linkTextAttributes
            
            
            var maxWidth:CGFloat = 0.7 * QiscusHelper.screenWidth()
            if message.type == "carousel"{
                maxWidth = (QiscusHelper.screenWidth() * 0.70) - 8
            }
            if message.type != "carousel" {
                textView.attributedText = attributedText
            }
            
            var size = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            
            if self.comment!.type == "card" {
                guard let dataPayload = message.payload else {
                    return
                }
                let payload = JSON(dataPayload)
                let buttons = payload["buttons"].arrayValue
                size.height = CGFloat(240 + (buttons.count * 45)) + 5
                
            }else{
                guard let dataPayload = message.payload else {
                    return
                }
                
                let payload = JSON(dataPayload)
                let cards = payload["cards"].arrayValue
                var maxHeight = CGFloat(0)
                for card in cards{
                    var height = CGFloat(0)
                    let desc = card["description"].stringValue
                    textView.text = desc
                    let buttons = card["buttons"].arrayValue
                    size = textView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
                    height = CGFloat(180 + (buttons.count * 45)) + size.height
                    
                    if height > maxHeight {
                        maxHeight = height
                    }
                }
                size.height = maxHeight + 5
            
            }
            
            self.sizeCarousel = size
            
            self.carouselHeight.constant = size.height + 10
            self.carouselView.layoutIfNeeded()
        }
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu(isQiscus: false)
        // Configure the view for the selected state
    }
    
    public func cellDelegate(didTapCardAction action: QCardAction) {
        switch action.type {
        case .link:
            let urlString = action.payload!["url"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let urlArray = urlString.components(separatedBy: "/")
            
            if let url = URL(string: urlString) {
                func openInBrowser(){
                    UIApplication.shared.openURL(url)
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
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }else{
                        UIApplication.shared.openURL(url)
                    }
                }else{
                    UIApplication.shared.openURL(url)
                }
            }
            break
        default:
            let text = action.postbackText
            let type = "button_postback_response"
            
            
            
            let message = CommentModel()
            message.message = text
            message.type = type
            if let payload = action.payload {
                message.payload = payload.dictionaryObject
            }
            
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

extension QCarouselCell: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let c = self.comment {
            var size = self.sizeCarousel
            size.width = QiscusHelper.screenWidth() * 0.70
            size.height += 30
            return size
        }
        return CGSize.zero
    }
}

extension QCarouselCell: UICollectionViewDelegate{
    
}

extension QCarouselCell: UICollectionViewDataSource{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCardCarousel", for: indexPath) as! QCarouselCardCell
        let height = self.sizeCarousel.height + 30.0
        
        cell.setupWithCard(card: self.cards[indexPath.item], height: height)
        cell.cardDelegate = self
        return cell
    }
}
extension QCarouselCell: QCarouselCardDelegate {
    public func carouselCard(cardCell: QCarouselCardCell, didTapAction card: QCardAction) {
        self.cellDelegate(didTapCardAction: card)
    }
}
