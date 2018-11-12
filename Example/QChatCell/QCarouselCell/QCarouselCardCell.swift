//
//  QCarouselCardCell.swift
//  Pods
//
//  Created by asharijuang on 02/11/18.
//

import UIKit
import SimpleImageViewer
import SDWebImage

public protocol QCarouselCardDelegate {
    func carouselCard(cardCell:QCarouselCardCell, didTapAction card:QCardAction)
}
public class QCarouselCardCell: UICollectionViewCell {
    @IBOutlet weak var containerArea: UIView!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var buttonContainer: UIStackView!
    
    @IBOutlet weak var buttonAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var cardHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var cardWidth: NSLayoutConstraint!
    
    var buttons = [UIButton]()
    var height = CGFloat(0)
    
    public var cardDelegate: QCarouselCardDelegate?
    
    var card:QCard?{
        didSet{
            if self.card != nil{
                self.cardChanged()
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.containerArea.layer.cornerRadius = 10.0
        self.containerArea.layer.borderWidth = 0.5
        self.containerArea.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1).cgColor
        self.containerArea.clipsToBounds = true
        self.containerArea.layer.zPosition = 999
        self.displayImageView.contentMode = .scaleAspectFill
        self.displayImageView.clipsToBounds = true
        self.cardWidth.constant = UIScreen.main.bounds.size.width * 0.70
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(QCarouselCardCell.cardTapped))
        self.containerArea.addGestureRecognizer(tapRecognizer)
    }
    
    func setupWithCard(card:QCard, height: CGFloat){
        self.height = height
        self.card = card
    }
    
    func cardChanged(){
        if self.card!.displayURL != "" {
            self.displayImageView.sd_setShowActivityIndicatorView(true)
            self.displayImageView.sd_setIndicatorStyle(.whiteLarge)
            self.displayImageView.sd_setImage(with: URL(string: self.card!.displayURL)!)
        }else{
            self.displayImageView.image = nil
        }
        self.titleLabel.text = self.card!.title
        self.descriptionLabel.text = self.card!.desc
        for currentButton in self.buttons {
            self.buttonContainer.removeArrangedSubview(currentButton)
            currentButton.removeFromSuperview()
        }
        self.buttons = [UIButton]()
        var yPos = CGFloat(0)
        let titleColor = UIColor(red: 101/255, green: 119/255, blue: 183/255, alpha: 1)
        var i = 0
        let buttonWidth = UIScreen.main.bounds.size.width * 0.70
        for action in self.card!.actions{
            let buttonFrame = CGRect(x: 0, y: yPos, width: buttonWidth, height: 45)
            let button = UIButton(frame: buttonFrame)
            button.setTitle(action.title, for: .normal)
            button.tag = i
            
            let borderFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: 0.5)
            let buttonBorder = UIView(frame: borderFrame)
            buttonBorder.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            button.setTitleColor(titleColor, for: .normal)
            button.addSubview(buttonBorder)
            self.buttons.append(button)
            self.buttonContainer.addArrangedSubview(button)
            button.addTarget(self, action: #selector(cardButtonTapped(_:)), for: .touchUpInside)
            
            yPos += 45
            i += 1
        }
        self.buttonAreaHeight.constant = yPos
        self.cardHeight.constant = height - 185
        self.containerArea.layoutIfNeeded()
    }
    @objc func cardButtonTapped(_ sender: UIButton) {
        if let c = self.card {
            self.cardDelegate?.carouselCard(cardCell: self, didTapAction: c.actions[sender.tag])
        }
    }
    @objc func cardTapped(){
        if let c = self.card {
            if let action = c.defaultAction {
                self.cardDelegate?.carouselCard(cardCell: self, didTapAction: action)
            }
        }
    }
}
