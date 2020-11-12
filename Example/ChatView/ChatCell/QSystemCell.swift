//
//  QSystemCell.swift
//  Qiscus
//
//  Created by asharijuang on 05/09/18.
//

import UIKit

import QiscusCore

class QSystemCell:  UIBaseChatCell {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lbComment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewBackground.layer.cornerRadius = 8
        self.viewBackground.clipsToBounds = true
        self.viewBackground.layer.borderWidth = 1
        self.viewBackground.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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
        lbComment.text = "\(self.hour(date: message.date())) - \(message.message)"
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
