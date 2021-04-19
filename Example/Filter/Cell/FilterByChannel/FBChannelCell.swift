//
//  FBChannelCell.swift
//  Example
//
//  Created by Qiscus on 15/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol FBChannelCellDelegate{
    func updateDataFB(isFBSelected: Bool, dataFBChannelModel : [FBChannelModel]?)
}

class FBChannelCell: UITableViewCell {

    @IBOutlet weak var btFB: UIButton!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkUnCheckFB: UIButton!
    
    var viewController : FilterVC? = nil
    var dataFBChannelModel = [FBChannelModel]()
    var checkLatestConsTableView : CGFloat = 0
    var delegate: FBChannelCellDelegate?
    var defaults = UserDefaults.standard
    var isLoadDropDown = false
    var isLoadFirstTime : Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FilterChannelMultipleFBCell", bundle: nil), forCellReuseIdentifier: "FilterChannelMultipleFBCellIdentifire")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUIFB"), object: nil)
        
    }
    
    func setupData(data: [FBChannelModel]){
        self.dataFBChannelModel = data
        
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
                    delegate.updateDataFB(isFBSelected: true, dataFBChannelModel: self.dataFBChannelModel)
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
        self.btFB.isSelected = false
        self.btFB.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = 0
    }
    
    func dropUPAction(){
        self.btFB.isSelected = true
        self.btFB.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = CGFloat(self.dataFBChannelModel.count * 44)
    }
    
    func checkAction(){
        self.checkUnCheckFB.isSelected = true
        self.checkUnCheckFB.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
    }
    
    func unCheckAction(){
        self.checkUnCheckFB.isSelected = false
        self.checkUnCheckFB.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func FBCheckUnCheck(_ sender: Any) {
        if self.checkUnCheckFB.isSelected == true {
            self.unCheckAction()
            
            //unCheck multiple FB
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unCheckALLMultipleFB"), object: nil)
            
            for data in self.dataFBChannelModel.enumerated() {
                data.element.isSelected = false
            }
            
            if let delegate = delegate {
                delegate.updateDataFB(isFBSelected: false, dataFBChannelModel: nil)
            }
        }else {
            self.checkAction()
            
            //checkALL multiple FB
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleFB"), object: nil)
            
            for data in self.dataFBChannelModel.enumerated() {
                data.element.isSelected = true
            }
            
            if let delegate = delegate {
                delegate.updateDataFB(isFBSelected: true, dataFBChannelModel: self.dataFBChannelModel)
            }
        }
    }
    
    @IBAction func dropDownFBAction(_ sender: Any) {
        if self.btFB.isSelected == true {
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
        self.btFB.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.btFB.isSelected = false
        
        self.tableViewHeightCons.constant = 0
        self.isLoadDropDown = false
        self.checkUnCheckFB.isSelected = false
        self.checkUnCheckFB.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        
        self.tableView.reloadData()
        
    }
    
}

extension FBChannelCell : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.dataFBChannelModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterChannelMultipleFBCellIdentifire", for: indexPath) as! FilterChannelMultipleFBCell
        if self.dataFBChannelModel.count != 0 {
            cell.delegate = self
            cell.setupData(data: self.dataFBChannelModel[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

extension FBChannelCell : FilterChannelMultipleFBCellDelegate {
    func updateFilterSelected(indexPath: IndexPath, isSelected: Bool) {
        self.dataFBChannelModel[indexPath.row].isSelected = isSelected
        if let delegate = delegate {
            delegate.updateDataFB(isFBSelected: isSelected, dataFBChannelModel: self.dataFBChannelModel)
        }
        
        var counter = 0
        for i in self.dataFBChannelModel{
            if i.isSelected == true{
                counter += 1
            }
        }
        
        if counter == self.dataFBChannelModel.count {
            checkAction()
        }else{
            unCheckAction()
        }
    }
}
