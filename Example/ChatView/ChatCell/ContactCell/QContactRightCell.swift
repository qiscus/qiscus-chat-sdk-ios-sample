//
//  QContactRightCell.swift
//  Qiscus
//
//  Created by asharijuang on 06/09/18.
//

import UIKit
import QiscusUI
import QiscusCore
import SwiftyJSON

class QContactRightCell: QUIBaseChatCell {
    
    @IBOutlet weak var nameContact: UILabel!
    @IBOutlet weak var noTelp: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var ivBaloon: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var viewLine: UIView!
    var menuConfig = enableMenuConfig()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setMenu(forward: menuConfig.forward, info: menuConfig.info)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu(forward: menuConfig.forward, info: menuConfig.info)
        self.viewLine.backgroundColor = ColorConfiguration.rightBaloonColor
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.setupBalon()
        self.status(message: message)
        self.lbName.text = "You"
        self.lbTime.text = message.hour()
        let data = message.payload
        let payloadJSON = JSON(data)
        self.nameContact.text = payloadJSON["name"].stringValue
        self.noTelp.text = payloadJSON["value"].stringValue
        
    }
    
    func status(message: CommentModel){
        
        switch message.status {
        case .deleted:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            lbTime.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.rightBaloonTextColor
            lbTime.text = TextConfiguration.sharedInstance.sendingText
            ivStatus.image = UIImage(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            lbTime.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.image = UIImage(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            lbTime.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            lbTime.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            lbTime.textColor = ColorConfiguration.failToSendColor
            lbTime.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        }
    }
    
    func setupBalon(){
        self.ivBaloon.applyShadow()
        self.ivBaloon.image = self.getBallon()
        self.ivBaloon.tintColor = ColorConfiguration.rightBaloonColor
    }
    
    @IBAction func saveContact(_ sender: Any) {
        
    }
    
}
