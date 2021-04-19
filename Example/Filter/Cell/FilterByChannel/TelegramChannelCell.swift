//
//  TelegramChannelCell.swift
//  Example
//
//  Created by Qiscus on 16/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit


protocol TelegramChannelCellDelegate{
    func updateDataTelegram(isTelegramSelected: Bool, dataTelegramChannelModel : [TelegramChannelModel]?)
}

class TelegramChannelCell: UITableViewCell {

    @IBOutlet weak var btTelegram: UIButton!
    
    @IBOutlet weak var checkUnCheckTelegram: UIButton!
    
    var viewController : FilterVC? = nil
    var dataTelegramChannelModel = [TelegramChannelModel]()
    var checkLatestConsTableView : CGFloat = 0
    var delegate: TelegramChannelCellDelegate?
    var defaults = UserDefaults.standard
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUITelegram"), object: nil)
        
    }
    
    func setupData(data: [TelegramChannelModel]){
        self.dataTelegramChannelModel = data
        
        var counter = 0
        for i in data{
            if i.isSelected == true{
                counter += 1
            }
        }
        
        if counter == data.count {
            checkAction()
        }else{
            unCheckAction()
        }
        
        
        if counter >= 1{
            if let delegate = delegate {
                delegate.updateDataTelegram(isTelegramSelected: true, dataTelegramChannelModel: self.dataTelegramChannelModel)
            }
        }else{
            self.dropDownAction()
        }
        
    }
    
    func dropDownAction(){
        self.btTelegram.isSelected = false
        self.btTelegram.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        
    }
    
    func dropUPAction(){
        self.btTelegram.isSelected = true
        self.btTelegram.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
        
    }
    
    func checkAction(){
        self.checkUnCheckTelegram.isSelected = true
        self.checkUnCheckTelegram.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
    }
    
    func unCheckAction(){
        self.checkUnCheckTelegram.isSelected = false
        self.checkUnCheckTelegram.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func TelegramCheckUnCheck(_ sender: Any) {
        if self.checkUnCheckTelegram.isSelected == true {
            self.unCheckAction()
            
            //unCheck multiple Telegram
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unCheckALLMultipleTelegram"), object: nil)
            
            for data in self.dataTelegramChannelModel.enumerated() {
                data.element.isSelected = false
            }
            
            if let delegate = delegate {
                delegate.updateDataTelegram(isTelegramSelected: false, dataTelegramChannelModel: nil)
            }
        }else {
            self.checkAction()
            
            //checkALL multiple Telegram
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleTelegram"), object: nil)
            
            for data in self.dataTelegramChannelModel.enumerated() {
                data.element.isSelected = true
            }
            
            if let delegate = delegate {
                delegate.updateDataTelegram(isTelegramSelected: true, dataTelegramChannelModel: self.dataTelegramChannelModel)
            }
        }
    }
    
    @IBAction func dropDownTelegramAction(_ sender: Any) {
        if self.btTelegram.isSelected == true {
            self.dropDownAction()
        }else {
            self.dropUPAction()
            
        }
    }

    @objc func resetUI(_ notification: Notification){
        self.btTelegram.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.btTelegram.isSelected = false
        
        self.checkUnCheckTelegram.isSelected = false
        self.checkUnCheckTelegram.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        
    }
    
}
