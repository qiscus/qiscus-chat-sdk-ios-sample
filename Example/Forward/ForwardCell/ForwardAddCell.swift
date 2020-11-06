//
//  ForwardAddCell.swift
//  Example
//
//  Created by Qiscus on 04/11/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import SwiftyJSON
import QiscusCore

class ForwardAddCell: UITableViewCell {
    
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var ivOnline: UIImageView!
    @IBOutlet weak var checkbox: UIImageView!
    @IBOutlet weak var icMemberCount: UIImageView!
    
    @IBOutlet weak var descriptionCons: NSLayoutConstraint!
    @IBOutlet weak var lbSubtitleRole: UILabel!
    let imageUnChecked = UIImage(named: "ic_checkbox_up")
    let imageChecked = UIImage(named: "ic_checkbox_checked")
    
    var checked: Bool = false {
        didSet {
            self.setupCheckboxState()
        }
    }
    
    var data : RoomModel? {
        didSet {
            if data != nil {
                self.setupUI()
            }
            
        }
    }
    var isOnline : Bool = false
    var onSelected: ((RoomModel?)->())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.checkbox.isUserInteractionEnabled = true
        let imgTouchEvent = UITapGestureRecognizer(target: self, action: #selector(ForwardAddCell.onCheckedChange))
        self.checkbox.addGestureRecognizer(imgTouchEvent)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupCheckboxState() {
        self.checkbox.image = self.checked ? imageChecked : imageUnChecked
    }
    
    func setupUI() {
        self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.height/2
        self.ivOnline.layer.cornerRadius = self.ivOnline.frame.height/2
        
        self.ivOnline.backgroundColor = ColorConfiguration.isOnlineColor
        //
        if let room = data {
            ivAvatar.af.setImage(withURL: (room.avatarUrl ?? URL(string: "http://"))!)
            self.lblUsername.text = room.name
            
            if room.type == .single {
                //default false
                self.lbSubtitleRole.isHidden = true
                
                self.descriptionCons.constant = 0
                self.icMemberCount.isHidden = true
                if isOnline == true {
                    showOnlineOffline(isOnline: true)
                }else{
                    showOnlineOffline(isOnline: false)
                }
                
                let me = QiscusCore.getUserData()
                guard let participants = room.participants else{
                    return
                }
                
                self.lbSubtitleRole.text = ""
                
            }else{
                self.hiddenOnline()
                self.descriptionCons.constant = 21
                self.icMemberCount.isHidden = false
                
                guard let participant = room.participants else{
                     self.lbSubtitleRole.text = "0"
                    return
                }
                
                self.lbSubtitleRole.text = "\(participant.count)"
            }
            
        }
        
    }
    
    @objc func onCheckedChange(_ sender: Any) {
        self.checkbox.image = self.checked ? imageUnChecked : imageChecked
        self.checked = !self.checked
        if let selected = self.onSelected {
            selected(data)
        }
    }
    
    func hiddenOnline(){
        self.ivOnline.isHidden = true
        self.ivOnline.backgroundColor = ColorConfiguration.isOfflineColor
    }
    
    func showOnlineOffline(isOnline : Bool = false){
        self.ivOnline.isHidden = false
        if isOnline == true {
            self.ivOnline.backgroundColor = ColorConfiguration.isOnlineColor
        }else{
            self.ivOnline.backgroundColor = ColorConfiguration.isOfflineColor
        }
        
    }
    
}
