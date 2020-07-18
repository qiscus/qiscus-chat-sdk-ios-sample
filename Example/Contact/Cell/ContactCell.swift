//
//  ContactCell.swift
//  qisme
//
//  Created by qiscus on 1/4/17.
//  Copyright © 2017 qiscus. All rights reserved.
//

import UIKit
import AlamofireImage
import QiscusCore

protocol ContactCellDelegate {
    func reloadTableView()
}

open class ContactCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var ivCheck: UIImageView!
    var contact: MemberModel?
    var roomId : String? = ""
    var removeParticipant: Bool? = false
    var delegate : ContactCellDelegate? = nil
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        let image = UIImage(named: "ic_check")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        ivCheck.image = image
        ivCheck.tintColor = UIColor.white
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithData(contact data: MemberModel, searchText: String = "") {
        self.contact = data
        let fullName: String            = data.username
        let avatarURL: URL              = data.avatarUrl!
        let placeHolderImage: UIImage   = UIImage(named: "avatar", in: nil, compatibleWith: nil)!
        
        let cellImageLayer: CALayer?    = profileImageView.layer
        let imageRadius: CGFloat        = CGFloat(cellImageLayer!.frame.size.height / 2)
        let imageSize: CGSize           = CGSize(width: profileImageView.frame.width, height: profileImageView.frame.height)
        let imageFilter                 = AspectScaledToFillSizeWithRoundedCornersFilter(size: imageSize, radius: imageRadius)
        cellImageLayer!.cornerRadius    = imageRadius
        cellImageLayer!.masksToBounds   = true
        
        accessoryType = .none
        
        nameLabel.text                  = fullName
        userIDLabel.text                = data.email
        profileImageView.clipsToBounds  = true
        profileImageView.contentMode    = .scaleAspectFill
        
        if avatarURL.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
             profileImageView.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!, placeholderImage: placeHolderImage, filter: nil)
        }else{
          profileImageView.af_setImage(withURL: avatarURL, placeholderImage: placeHolderImage, filter: nil)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeParticipant(tapGestureRecognizer:)))
        ivCheck.isUserInteractionEnabled = true
        ivCheck.addGestureRecognizer(tapGestureRecognizer)
        
        makeMatchingPartBold(searchText: searchText)
    }
    
    @objc func removeParticipant(tapGestureRecognizer: UITapGestureRecognizer){
        if removeParticipant == true{
            QiscusCore.shared.removeParticipant(userEmails: [(contact?.email)!], roomId: roomId!, onSuccess: { (success) in
                self.delegate?.reloadTableView()
            }) { (error) in
                //error
            }
        }
    }
    
    func makeMatchingPartBold(searchText: String) {
        // check label text & search text
        guard
            let labelText = nameLabel.text
            else {
                return
        }
        
        // bold attribute
        let boldAttr = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: nameLabel.font.pointSize)]
        
        // check if label text contains search text
        if let matchRange: Range = labelText.lowercased().range(of: searchText.lowercased()) {
            
            // get range start/length because NSMutableAttributedString.setAttributes() needs NSRange not Range<String.Index>
            let matchRangeStart: Int = labelText.distance(from: labelText.startIndex, to: matchRange.lowerBound)
            let matchRangeEnd: Int = labelText.distance(from: labelText.startIndex, to: matchRange.upperBound)
            let matchRangeLength: Int = matchRangeEnd - matchRangeStart
            
            // create mutable attributed string & bold matching part
            let newLabelText = NSMutableAttributedString(string: labelText)
            newLabelText.setAttributes(boldAttr, range: NSMakeRange(matchRangeStart, matchRangeLength))
            
            // set label attributed text
            nameLabel.attributedText = newLabelText
        }
    }
    
}
