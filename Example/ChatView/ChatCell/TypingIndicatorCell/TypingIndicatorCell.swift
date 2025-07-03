//
//  TypingIndicatorCell.swift
//  Example
//
//  Created by arief nur putranto on 22/05/25.
//  Copyright © 2025 Qiscus. All rights reserved.
//

import UIKit

class TypingIndicatorCell: UITableViewCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.transform = CGAffineTransform(rotationAngle: .pi) // agar cell terlihat normal
    }
    
    func bindData(message: String){
        self.setupBalon()
        
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        self.tvContent.text = message
        self.tvContent.textColor = ColorConfiguration.leftBaloonTextColor
        
        self.lbName.text = ""
        lbNameHeight.constant = 0
        
    }
    
    func setupBalon(){
        self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallonData()
        self.ivBaloonLeft.tintColor = ColorConfiguration.leftBaloonColor
    }
    
    func getBallonData()->UIImage?{
        var balloonImage:UIImage? = nil
        
        var edgeInset = UIEdgeInsets(top: 13, left: 28, bottom: 13, right: 13)
        balloonImage = AssetsConfiguration.leftBallonLast
        
        return balloonImage?.resizableImage(withCapInsets: edgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }

}
