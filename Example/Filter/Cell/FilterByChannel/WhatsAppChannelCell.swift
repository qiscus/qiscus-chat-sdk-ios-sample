//
//  WhatsAppChannelCell.swift
//  Example
//
//  Created by Qiscus on 13/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol WhatsAppChannelCellDelegate{
    func updateDataWA(isWaSelected: Bool, dataWAChannelModel : [WAChannelModel]?)
    func updateSelectedTypeWA(type : String)
}

class WhatsAppChannelCell: UITableViewCell {

    @IBOutlet weak var viewDropDown: UIView!
    @IBOutlet weak var btWA: UIButton!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var btMultipleWA: UIButton!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkUnCheckWA: UIButton!
    @IBOutlet weak var checkUnCheckALLWA: UIButton!
    @IBOutlet weak var checkUnCheckOngoingWA: UIButton!
    @IBOutlet weak var checkUnCheckExpiringWA: UIButton!
    
    
    var viewController : FilterVC? = nil
    var dataWAChannelModel = [WAChannelModel]()
    var checkLatestConsTableView : CGFloat = 0
    var delegate: WhatsAppChannelCellDelegate?
    var defaults = UserDefaults.standard
    var isLoadDropDown = false
    var isLoadDropDownChild = false
    var isFirstTimeLoad = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FilterChannelMultipleWACell", bundle: nil), forCellReuseIdentifier: "FilterChannelMultipleWACellIdentifire")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUIWA"), object: nil)
        
    }
    
    func setupData(data: [WAChannelModel]){
        self.dataWAChannelModel = data
        
        if let selectedTypeWA = defaults.string(forKey: "filterSelectedTypeWA"){
            if selectedTypeWA == "all" {
                self.checkUnCheckWA.isSelected = true
                self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
                
                self.checkUnCheckALLWA.isSelected = true
                self.checkUnCheckALLWA.setImage(UIImage(named: "ic_circle_check"), for: .normal)
                
            } else if (selectedTypeWA == "expired"){
                self.checkUnCheckWA.isSelected = true
                self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
                
                self.checkUnCheckOngoingWA.isSelected = true
                self.checkUnCheckOngoingWA.setImage(UIImage(named: "ic_circle_check"), for: .normal)
            } else if (selectedTypeWA == "almost_expired"){
                self.checkUnCheckWA.isSelected = true
                self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
                
                self.checkUnCheckExpiringWA.isSelected = true
                self.checkUnCheckExpiringWA.setImage(UIImage(named: "ic_circle_check"), for: .normal)
            }
        }
        
        var counter = 0
        for i in data{
            if i.isSelected == true{
                counter += 1
            }
        }
        
        if counter >= 1{
            
            if isLoadDropDown == true{
                self.viewDropDown.alpha = 1
                
                //dropdown main wa
                self.btWA.isSelected = true
                self.btWA.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
                self.viewHeight.constant = CGFloat(150 + self.dataWAChannelModel.count * 44)
                
                
                if isLoadDropDownChild == true{
                    //dropdown child wa multiple
                    self.btMultipleWA.isSelected = true
                    self.btMultipleWA.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
                    self.tableViewHeightCons.constant = CGFloat(self.dataWAChannelModel.count * 44)
                    self.viewHeight.constant = CGFloat(150 + self.tableViewHeightCons.constant)
                    self.checkLatestConsTableView = self.tableViewHeightCons.constant
                    self.isLoadDropDownChild = true
                }
                
            }
            
            if self.isFirstTimeLoad == true{
                self.isFirstTimeLoad = false
                
                self.dropDownWAAction(self.btWA)
                
                self.dropDownMultipleWAAction(self.btMultipleWA)
                
            }
            
            if let delegate = delegate {
                delegate.updateDataWA(isWaSelected: true, dataWAChannelModel: self.dataWAChannelModel)
            }
        }else{
            if isLoadDropDown == true{
                self.viewDropDown.alpha = 1
                
                //dropdown main wa
                self.btWA.isSelected = true
                self.btWA.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
                
                if isLoadDropDownChild == true{
                    //dropdown child wa multiple
                    self.btMultipleWA.isSelected = true
                    self.btMultipleWA.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
                    self.tableViewHeightCons.constant = CGFloat(self.dataWAChannelModel.count * 44)
                    self.viewHeight.constant = CGFloat(150 + self.tableViewHeightCons.constant)
                    self.checkLatestConsTableView = self.tableViewHeightCons.constant
                }
            }else{
                self.viewDropDown.alpha = 0
                self.tableViewHeightCons.constant = 0
                self.viewHeight.constant = 0
            }

           
        }
        
        
        self.tableView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func waCheckUnCheck(_ sender: Any) {
        if self.checkUnCheckWA.isSelected == true {
            self.checkUnCheckWA.isSelected = false
            self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
            
            //update uncheck ALL, ongoing, expiring wa
            self.checkUnCheckALLWA.isSelected = false
            self.checkUnCheckALLWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
            self.checkUnCheckOngoingWA.isSelected = false
            self.checkUnCheckOngoingWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
            self.checkUnCheckExpiringWA.isSelected = false
            self.checkUnCheckExpiringWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
            
            //unCheck multiple whatsapp
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unCheckALLMultipleWA"), object: nil)
            
            for data in self.dataWAChannelModel.enumerated() {
                data.element.isSelected = false
            }
            
            if let delegate = delegate {
                delegate.updateDataWA(isWaSelected: false, dataWAChannelModel: nil)
                delegate.updateSelectedTypeWA(type: "")
            }
        }else {
            self.checkUnCheckWA.isSelected = true
            self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
            
            //update check ALL wa
            self.checkUnCheckALLWA.isSelected = true
            self.checkUnCheckALLWA.setImage(UIImage(named: "ic_circle_check"), for: .normal)
            
            //checkALL multiple whatsapp
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleWA"), object: nil)
            
            for data in self.dataWAChannelModel.enumerated() {
                data.element.isSelected = true
            }
            
            if let delegate = delegate {
                delegate.updateDataWA(isWaSelected: true, dataWAChannelModel: self.dataWAChannelModel)
                delegate.updateSelectedTypeWA(type: "all")
            }
        }
    }
    
    @IBAction func waCheckUnCheckALL(_ sender: Any) {
        self.checkUnCheckWA.isSelected = true
        self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
        
        self.checkUnCheckALLWA.isSelected = true
        self.checkUnCheckALLWA.setImage(UIImage(named: "ic_circle_check"), for: .normal)
        
        //update uncheck ongoing and expiring
        self.checkUnCheckOngoingWA.isSelected = false
        self.checkUnCheckOngoingWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        self.checkUnCheckExpiringWA.isSelected = false
        self.checkUnCheckExpiringWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        
        //checkALL multiple whatsapp
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleWA"), object: nil)
        
        for data in self.dataWAChannelModel.enumerated() {
            data.element.isSelected = true
        }
        
        if let delegate = delegate {
            delegate.updateDataWA(isWaSelected: true, dataWAChannelModel: self.dataWAChannelModel)
            delegate.updateSelectedTypeWA(type: "all")
        }
    }
    
    @IBAction func waCheckUnCheckOngoing(_ sender: Any) {
        self.checkUnCheckWA.isSelected = true
        self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
        
        self.checkUnCheckOngoingWA.isSelected = true
        self.checkUnCheckOngoingWA.setImage(UIImage(named: "ic_circle_check"), for: .normal)
        
        //update uncheck ongoing and expiring
        self.checkUnCheckALLWA.isSelected = false
        self.checkUnCheckALLWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        self.checkUnCheckExpiringWA.isSelected = false
        self.checkUnCheckExpiringWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        
        //checkALL multiple whatsapp
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleWA"), object: nil)
        
        for data in self.dataWAChannelModel.enumerated() {
            data.element.isSelected = true
        }
        
        if let delegate = delegate {
            delegate.updateDataWA(isWaSelected: true, dataWAChannelModel: self.dataWAChannelModel)
            delegate.updateSelectedTypeWA(type: "expired")
        }
    }
    
    @IBAction func waCheckUnCheckExpiring(_ sender: Any) {
        self.checkUnCheckWA.isSelected = true
        self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
        
        self.checkUnCheckExpiringWA.isSelected = true
        self.checkUnCheckExpiringWA.setImage(UIImage(named: "ic_circle_check"), for: .normal)
        
        //update uncheck ongoing and expiring
        self.checkUnCheckALLWA.isSelected = false
        self.checkUnCheckALLWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        self.checkUnCheckOngoingWA.isSelected = false
        self.checkUnCheckOngoingWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        
        //checkALL multiple whatsapp
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleWA"), object: nil)
        
        for data in self.dataWAChannelModel.enumerated() {
            data.element.isSelected = true
        }
        
        if let delegate = delegate {
            delegate.updateDataWA(isWaSelected: true, dataWAChannelModel: self.dataWAChannelModel)
            delegate.updateSelectedTypeWA(type: "almost_expired")
        }
    }
    
    @IBAction func dropDownWAAction(_ sender: Any) {
        self.dropDownWAAction()
    }
    
    @IBAction func dropDownMultipleWAAction(_ sender: Any) {
        self.dropDownMultipleWAAction()
    }
    
    func dropDownWAAction(){
        if self.btWA.isSelected == true {
            self.btWA.isSelected = false
            self.btWA.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
            
            UIView.animate(withDuration: 0.3) {
                self.tableViewHeightCons.constant = 0
                self.viewHeight.constant = 0
                self.isLoadDropDown = false
                self.viewDropDown.alpha = 0
            }
           
        }else {
            self.btWA.isSelected = true
            self.btWA.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
            
            self.tableViewHeightCons.constant = self.checkLatestConsTableView
            if self.checkLatestConsTableView == 0 {
                self.viewHeight.constant = CGFloat(150)
            }else{
                self.viewHeight.constant = CGFloat(150 + self.dataWAChannelModel.count * 44)
            }
            
            self.isLoadDropDown = true
        
            self.viewDropDown.alpha = 1
            
        }
        //self.tableView.reloadData()
        
        self.viewController?.tableViewChannel.beginUpdates()
        self.viewController?.tableViewChannel.endUpdates()
    }
    
    func dropDownMultipleWAAction(){
        if self.btMultipleWA.isSelected == true {
            self.btWA.isSelected = false
           
            UIView.animate(withDuration: 0.3) {
                self.btWA.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
                self.tableViewHeightCons.constant = 0
                self.viewHeight.constant = 0
                self.isLoadDropDown = false
                self.viewDropDown.alpha = 0
            }
            self.viewController?.tableViewChannel.beginUpdates()
            self.viewController?.tableViewChannel.endUpdates()
            
            
            self.btMultipleWA.isSelected = false
            self.btMultipleWA.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
            self.tableViewHeightCons.constant = 0
            self.viewHeight.constant = CGFloat(150)
            self.checkLatestConsTableView = self.tableViewHeightCons.constant
            self.isLoadDropDownChild = false
            self.viewController?.tableViewChannel.beginUpdates()
            self.viewController?.tableViewChannel.endUpdates()
            
            self.btWA.isSelected = true
            self.btWA.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
            
            self.tableViewHeightCons.constant = self.checkLatestConsTableView
            if self.checkLatestConsTableView == 0 {
                self.viewHeight.constant = CGFloat(150)
            }else{
                self.viewHeight.constant = CGFloat(150 + self.dataWAChannelModel.count * 44)
            }
            self.isLoadDropDown = true
        
            self.viewDropDown.alpha = 1
            
        }else {
            self.btMultipleWA.isSelected = true
            self.btMultipleWA.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
            
            UIView.animate(withDuration: 0.3) {
                self.tableViewHeightCons.constant = CGFloat(self.dataWAChannelModel.count * 44)
                self.viewHeight.constant = CGFloat(150 + self.tableViewHeightCons.constant)
                self.checkLatestConsTableView = self.tableViewHeightCons.constant
                self.isLoadDropDownChild = true
            }
           
        }
        //self.tableView.reloadData()
        
        self.viewController?.tableViewChannel.beginUpdates()
        self.viewController?.tableViewChannel.endUpdates()
    }

    @objc func resetUI(_ notification: Notification){
        self.btWA.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.btWA.isSelected = false
        
        self.btMultipleWA.isSelected = false
        self.btMultipleWA.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.tableViewHeightCons.constant = 0
        self.viewHeight.constant = CGFloat(0)
        self.checkLatestConsTableView = self.tableViewHeightCons.constant
        
        self.checkUnCheckWA.isSelected = false
        self.checkUnCheckWA.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        self.checkUnCheckALLWA.isSelected = false
        self.checkUnCheckALLWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        self.checkUnCheckOngoingWA.isSelected = false
        self.checkUnCheckOngoingWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        self.checkUnCheckExpiringWA.isSelected = false
        self.checkUnCheckExpiringWA.setImage(UIImage(named: "ic_circle_uncheck"), for: .normal)
        self.isLoadDropDown = false
    }
    
}

extension WhatsAppChannelCell : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.dataWAChannelModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterChannelMultipleWACellIdentifire", for: indexPath) as! FilterChannelMultipleWACell
        if self.dataWAChannelModel.count != 0 {
            cell.delegate = self
            cell.setupData(data: self.dataWAChannelModel[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

extension WhatsAppChannelCell : FilterChannelMultipleWACellDelegate {
    func updateFilterSelected(indexPath: IndexPath, isSelected: Bool) {
        self.dataWAChannelModel[indexPath.row].isSelected = isSelected
        if let delegate = delegate {
            delegate.updateDataWA(isWaSelected: isSelected, dataWAChannelModel: self.dataWAChannelModel)
        }
    }
}
