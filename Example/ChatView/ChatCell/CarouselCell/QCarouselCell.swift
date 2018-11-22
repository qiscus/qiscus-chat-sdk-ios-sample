//
//  QCarouselCell.swift
//  Pods
//
//  Created by asharijuang on 02/11/18.
//

import UIKit
import QiscusUI
import QiscusCore
import SwiftyJSON

protocol QCellCarouselDelegate {
    func cellCarousel(carouselCell:QCarouselCell, didTapCard card:QCard)
    func cellCarousel(carouselCell:QCarouselCell, didTapAction action:QCardAction)
}

class QCarouselCell: QUIBaseChatCell {
    @IBOutlet weak var carouselView: UICollectionView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var carouselTrailing: NSLayoutConstraint!
    @IBOutlet weak var carouselLeading: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var carouselHeight: NSLayoutConstraint!
    var sizeCarousel : CGSize = CGSize(width: 0, height: 0)
//    var delegateChat : ChatViewController? = nil
    var cards = [QCard](){
        didSet{
            self.carouselView.reloadData()
            if let c = self.comment {
                guard let user = QiscusCore.getProfile() else { return }
                if c.userEmail == user.email {
                    if cards.count > 0 {
                        if cards.count == 1 {
                            let width = UIScreen.main.bounds.size.width
                            self.carouselLeading.constant = width - (width * 0.6 + 32)
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
    
    var delegate : QCellCarouselDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.carouselView.register(UINib(nibName: "QCarouselCardCell",bundle:nil), forCellWithReuseIdentifier: "cellCardCarousel")
        carouselView.delegate = self
        carouselView.dataSource = self
        carouselView.clipsToBounds = true
        
        self.layer.zPosition = 99
    }
    
    override  func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
    }
    
    override  func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
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
            guard let user = QiscusCore.getProfile() else { return }
            if c.userEmail == user.email {
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
            
            //if self.showUserName{
                if c.userEmail == user.email {
                    self.userNameLabel.text = "YOU"
                }else{
                    self.userNameLabel.text = c.username
                }
                self.userNameLabel.isHidden = false
                self.topMargin.constant = 20
//            }else{
//                self.userNameLabel.text = ""
//                self.userNameLabel.isHidden = true
//                self.topMargin.constant = 0
//            }
            
            var attributedText = NSMutableAttributedString(string: message.message)
            let allRange = (message.message as NSString).range(of: message.message)
            attributedText.addAttributes(self.textAttribute, range: allRange)
            
            let textView = UITextView()
            textView.font = UIConfiguration.chatFont
            if message.type == "carousel" {
                textView.font = UIFont.systemFont(ofSize: 12)
            }
            textView.dataDetectorTypes = .all
            textView.linkTextAttributes = self.linkTextAttributes
            
            
            var maxWidth:CGFloat = UIConfiguration.chatTextMaxWidth
            if message.type == "carousel"{
                maxWidth = (UIScreen.main.bounds.size.width * 0.70) - 8
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

    override  func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension QCarouselCell: UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let c = self.comment {
            var size = self.sizeCarousel
            size.width = UIScreen.main.bounds.size.width * 0.70
            size.height += 30
            return size
        }
        return CGSize.zero
    }
}

extension QCarouselCell: UICollectionViewDelegate{
    
}

extension QCarouselCell: UICollectionViewDataSource{
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCardCarousel", for: indexPath) as! QCarouselCardCell
        let height = self.sizeCarousel.height + 30.0
        
        cell.setupWithCard(card: self.cards[indexPath.item], height: height)
        cell.cardDelegate = self
        return cell
    }
}
extension QCarouselCell: QCarouselCardDelegate {
     func carouselCard(cardCell: QCarouselCardCell, didTapAction card: QCardAction) {
        self.delegate?.cellCarousel(carouselCell: self, didTapAction: card)
    }
}

// MARK : Carousel handle
extension ChatViewController : QCellCarouselDelegate {
    func cellCarousel(carouselCell: QCarouselCell, didTapCard card: QCard) {
        //
    }
    
    func cellCarousel(carouselCell: QCarouselCell, didTapAction action: QCardAction) {
        switch action.type {
        case .link:
            let urlString = action.payload!["url"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let urlArray = urlString.components(separatedBy: "/")
            
            if let url = URL(string: urlString) {
                func openInBrowser(){
                    UIApplication.shared.canOpenURL(url)
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
                                UIApplication.shared.canOpenURL(instagramURL)
                            }else{
                                UIApplication.shared.canOpenURL(url)
                            }
                        }
                    }else{
                        UIApplication.shared.canOpenURL(url)
                    }
                }else{
                    UIApplication.shared.canOpenURL(url)
                }
            }
            break
        default:
            let text = action.postbackText
            let type = "button_postback_response"
            let comment = CommentModel()
            comment.message = text
            comment.type    = type
            comment.payload = action.payload?.dictionaryObject
            
            self.sendMessage(message: comment)

            break
        }
    }
}
