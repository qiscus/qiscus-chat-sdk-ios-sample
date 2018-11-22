//
//  QImageLeftCell.swift
//  Pods
//
//  Created by asharijuang on 04/09/18.
//

import UIKit
import QiscusCore
import QiscusUI
import SwiftyJSON
import SimpleImageViewer

class QMediaLeftCell: QUIBaseChatCell {
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var ivBaloon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setMenu()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu()
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.setupBalon()
        
        
    }
    
    func setupBalon(){
        self.ivBaloon.applyShadow()
        self.ivBaloon.image = self.getBallon()
        self.ivBaloon.tintColor = ColorConfiguration.leftBaloonColor
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
