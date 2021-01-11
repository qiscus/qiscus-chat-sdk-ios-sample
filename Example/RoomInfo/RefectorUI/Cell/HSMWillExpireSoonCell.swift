//
//  HSMWillExpireSoonCell.swift
//  Example
//
//  Created by Qiscus on 08/01/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

class HSMWillExpireSoonCell: UITableViewCell {

    @IBOutlet weak var btAlertInfoExpireSoon: UIButton!
    @IBOutlet weak var lbCountDownTimer: UILabel!
    var lastDateCustomer : Date? = nil
    var countdownTimer : Timer? = nil
    var allSeconds = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lbCountDownTimer.text = ""
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(invalidateCounter), name: Notification.Name("invalidateCounter"), object: nil)
    }
    
    @objc func invalidateCounter(){
        if  countdownTimer != nil {
            countdownTimer?.invalidate()
            countdownTimer = nil
            self.lbCountDownTimer.text = ""
        }
    }
    
    func setupData(lastCommentCustomerDate : Date? = nil){
        if lastCommentCustomerDate != nil {
           
            if countdownTimer == nil {
                let currentDate = Date()
                
                let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: lastCommentCustomerDate!, to: currentDate)
                let hours = diffComponents.hour ?? 0
                let minutes = diffComponents.minute ?? 0
                let seconds = diffComponents.second ?? 0
                
                let hoursInSeconds = hours * 60 * 60 // 1 jam x 60minute x 60second
                let minutesInSeconds = minutes * 60 // 60minutes x 60second
                let lastTimeInSeconds = hoursInSeconds + minutesInSeconds + seconds
                
                let expiredTime = 24*60*60 //24 hours after last message from customer
                
                let differentTime = expiredTime - lastTimeInSeconds
                
                self.allSeconds = differentTime
                
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            }

        }
        
    }
    
    @objc func updateTime() {
        self.allSeconds -= 1
        secondsToHoursMinutesSeconds(seconds: self.allSeconds)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) {
        self.lbCountDownTimer.text = "\(seconds / 3600):\((seconds % 3600) / 60):\((seconds % 3600) % 60)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
