//
//  ChatTitleView.swift
//  QiscusUI
//
//  Created by Qiscus on 25/10/18.
//

import UIKit
import QiscusCore

class UIChatNavigation: UIView {
    var contentsView            : UIView!
    // ui component
    /// UILabel title,
    @IBOutlet weak var labelTitle: UILabel!
    /// UILabel subtitle
    @IBOutlet weak var labelSubtitle: UILabel!
    /// UIImageView room avatar
    @IBOutlet weak var imageViewAvatar: UIImageView!
    
    var room: RoomModel? {
        set {
            self._room = newValue
            if let data = newValue { present(room: data) } // bind data only
        }
        get {
            return self._room
        }
    }
    private var _room : RoomModel? = nil
    
    // If someone is to initialize a UIChatInput in code
    override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        let nib = UINib(nibName: "UIChatNavigation", bundle: nil)
        commonInit(nib: nib)
    }
    
    // If someone is to initalize a UIChatInput in Storyboard setting the Custom Class of a UIView
    required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        let nib = UINib(nibName: "UIChatNavigation", bundle: nil)
        commonInit(nib: nib)
    }
    
    func commonInit(nib: UINib) {
        self.contentsView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        // 2. Adding the 'contentView' to self (self represents the instance of a WeatherView which is a 'UIView').
        addSubview(contentsView)
        
        // 3. Setting this false allows us to set our constraints on the contentView programtically
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. Setting the constraints programatically
        contentsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentsView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentsView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        self.autoresizingMask  = (UIView.AutoresizingMask.flexibleWidth)
        self.setupUI()
    }
    
    private func setupUI() {
        // default ui
        if self.imageViewAvatar != nil {
            self.imageViewAvatar.layer.cornerRadius = self.contentsView.frame.height/2
        }
    }
    
    func present(room: RoomModel) {
        // title value
        self.labelTitle.text = room.name
        self.imageViewAvatar.af_setImage(withURL: room.avatarUrl ?? URL(string: "http://")!)
        if room.type == .group {
            self.labelSubtitle.text = getParticipant(room: room)
        }else {
            self.labelSubtitle.text = ""
            // MARK : TODO provide last seen
            //            guard let user = QiscusCore.getProfile() else { return }
            //            self.presenter.participants.forEach { (member) in
            //                if member.email != user.email {
            //                    self.subtitleLabel.text = "last seen at \(member.lastCommentReadId)"
            //                }
            //            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("height \(self.contentsView.frame)")
        if self.imageViewAvatar != nil {
            self.imageViewAvatar.layer.cornerRadius = self.contentsView.frame.height/2
        }
    }
    
}

extension UIChatNavigation {
    func getParticipant(room: RoomModel) -> String {
        var result = ""
        guard let participants = room.participants else { return result }
        for m in participants {
            if result.isEmpty {
                result = m.username
            }else {
                result = result + ", \(m.username)"
            }
        }
        return result
    }
}
