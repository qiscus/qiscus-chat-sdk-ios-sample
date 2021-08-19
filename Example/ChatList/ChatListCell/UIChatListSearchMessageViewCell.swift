//
//  UIChatListSearchMessageViewCell.swift
//  Example
//
//  Created by Qiscus on 16/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import SwiftyJSON

class UIChatListSearchMessageViewCell: UITableViewCell {
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var lbRoomName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(data : CommentModel, messageSearch : String = ""){
        self.setupDate(data: data)
        self.setupUI(data: data, messageSearch : messageSearch)
        
    }
    
    func setupUI(data : CommentModel, messageSearch : String = ""){
        
        var stringValue = "\(data.username): \(data.message)"
        
        if data.type == "file_attachment"{
            let payload = JSON(data.payload)
            let nameFile = payload["file_name"].string ?? "file attachment from \(messageSearch)"
            
            stringValue = "\(data.username): \(nameFile)"
            
            let attributedWithTextColor: NSAttributedString = stringValue.attributedStringWithColor([messageSearch, messageSearch.lowercased()], color: UIColor.black)

            self.lbMessage.attributedText = attributedWithTextColor
        }else{
            if messageSearch.isEmpty {
                self.lbMessage.text = stringValue
            }else{
                let attributedWithTextColor: NSAttributedString = stringValue.attributedStringWithColor([messageSearch, messageSearch.lowercased()], color: UIColor.black)

                self.lbMessage.attributedText = attributedWithTextColor
            }
        }
        
       

       
        
        
        if let room = QiscusCore.database.room.find(id: data.roomId) {
            self.lbRoomName.text = room.name
        }else{
            QiscusCore.shared.getChatRoomWithMessages(roomId: data.roomId) { (room, comment) in
                self.lbRoomName.text = room.name
            } onError: { (error) in
                self.lbRoomName.text = ""
            }

        }
        
    }
    
    private func setupDate(data : CommentModel){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: data.timestamp) {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "d/MM"
            let dateString = dateFormatter2.string(from: date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: date)
            
            var result = ""
            
            if Calendar.current.isDateInToday(date){
                result = "Today, \(timeString)"
            }
            else if Calendar.current.isDateInYesterday(date) {
                result = "Yesterday, \(timeString)"
            }else{
                result = "\(dateString), \(timeString)"
            }
            
            
            self.lbDate.text = result
        }else{
            self.lbDate.text = ""
        }
    }
    
}
