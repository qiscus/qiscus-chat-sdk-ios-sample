//
//  CustomCHChannelCell.swift
//  Example
//
//  Created by Qiscus on 15/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit


protocol CustomCHChannelCellDelegate{
    func updateDataCustomCH(isCustomCHSelected: Bool, dataCustomCHChannelModel : [CustomCHChannelModel]?)
}

class CustomCHChannelCell: UITableViewCell {

    @IBOutlet weak var btCustomCH: UIButton!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkUnCheckCustomCH: UIButton!
    
    var viewController : FilterVC? = nil
    var dataCustomCHChannelModel = [CustomCHChannelModel]()
    var checkLatestConsTableView : CGFloat = 0
    var delegate: CustomCHChannelCellDelegate?
    var defaults = UserDefaults.standard
    var isLoadDropDown = false
    var isLoadFirstTime : Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FilterChannelMultipleCustomCHCell", bundle: nil), forCellReuseIdentifier: "FilterChannelMultipleCustomCHCellIdentifire")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUICustomCH"), object: nil)
        
    }
    
    func setupData(data: [CustomCHChannelModel]){
        self.dataCustomCHChannelModel = data
        
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
            if self.isLoadFirstTime == true{
                self.isLoadFirstTime = false
                self.isLoadDropDown = true
                self.dropUPAction()
                if let delegate = delegate {
                    delegate.updateDataCustomCH(isCustomCHSelected: true, dataCustomCHChannelModel: self.dataCustomCHChannelModel)
                }
            }
            
        }else{
            if isLoadDropDown == true{
                self.dropUPAction()
            }else{
                self.dropDownAction()
            }
        }
        
        
        self.tableView.reloadData()
        
    }
    
    func dropDownAction(){
        self.btCustomCH.isSelected = false
        self.btCustomCH.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = 0
    }
    
    func dropUPAction(){
        self.btCustomCH.isSelected = true
        self.btCustomCH.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = CGFloat(self.dataCustomCHChannelModel.count * 44)
    }
    
    func checkAction(){
        self.checkUnCheckCustomCH.isSelected = true
        self.checkUnCheckCustomCH.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
    }
    
    func unCheckAction(){
        self.checkUnCheckCustomCH.isSelected = false
        self.checkUnCheckCustomCH.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func CustomCHCheckUnCheck(_ sender: Any) {
        if self.checkUnCheckCustomCH.isSelected == true {
            self.unCheckAction()
            
            //unCheck multiple CustomCH
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unCheckALLMultipleCustomCH"), object: nil)
            
            for data in self.dataCustomCHChannelModel.enumerated() {
                data.element.isSelected = false
            }
            
            if let delegate = delegate {
                delegate.updateDataCustomCH(isCustomCHSelected: false, dataCustomCHChannelModel: nil)
            }
        }else {
            self.checkAction()
            
            //checkALL multiple CustomCH
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleCustomCH"), object: nil)
            
            for data in self.dataCustomCHChannelModel.enumerated() {
                data.element.isSelected = true
            }
            
            if let delegate = delegate {
                delegate.updateDataCustomCH(isCustomCHSelected: true, dataCustomCHChannelModel: self.dataCustomCHChannelModel)
            }
        }
    }
    
    @IBAction func dropDownCustomCHAction(_ sender: Any) {
        if self.btCustomCH.isSelected == true {
            self.isLoadDropDown = false
            self.dropDownAction()
        }else {
            self.isLoadDropDown = true
            self.dropUPAction()
            
        }
       // self.tableView.reloadData()
        
        self.viewController?.tableViewChannel.beginUpdates()
        self.viewController?.tableViewChannel.endUpdates()
    }

    @objc func resetUI(_ notification: Notification){
        self.btCustomCH.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.btCustomCH.isSelected = false
        
        self.tableViewHeightCons.constant = 0
        self.isLoadDropDown = false
        self.checkUnCheckCustomCH.isSelected = false
        self.checkUnCheckCustomCH.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        
        self.tableView.reloadData()
        
    }
    
}

extension CustomCHChannelCell : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.dataCustomCHChannelModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterChannelMultipleCustomCHCellIdentifire", for: indexPath) as! FilterChannelMultipleCustomCHCell
        if self.dataCustomCHChannelModel.count != 0 {
            cell.delegate = self
            cell.setupData(data: self.dataCustomCHChannelModel[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

extension CustomCHChannelCell : FilterChannelMultipleCustomCHCellDelegate {
    func updateFilterSelected(indexPath: IndexPath, isSelected: Bool) {
        self.dataCustomCHChannelModel[indexPath.row].isSelected = isSelected
        if let delegate = delegate {
            delegate.updateDataCustomCH(isCustomCHSelected: isSelected, dataCustomCHChannelModel: self.dataCustomCHChannelModel)
        }
        
        var counter = 0
        for i in self.dataCustomCHChannelModel{
            if i.isSelected == true{
                counter += 1
            }
        }
        
        if counter == self.dataCustomCHChannelModel.count {
            checkAction()
        }else{
            unCheckAction()
        }
    }
}
