//
//  QiscusWidgetChannelCell.swift
//  Example
//
//  Created by Qiscus on 16/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol QiscusWidgetChannelCellDelegate{
    func updateDataQiscusWidget(isQiscusWidgetSelected: Bool, dataQiscusWidgetChannelModel : [QiscusWidgetChannelModel]?)
}

class QiscusWidgetChannelCell: UITableViewCell {

    @IBOutlet weak var btQiscusWidget: UIButton!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkUnCheckQiscusWidget: UIButton!
    
    var viewController : FilterVC? = nil
    var dataQiscusWidgetChannelModel = [QiscusWidgetChannelModel]()
    var checkLatestConsTableView : CGFloat = 0
    var delegate: QiscusWidgetChannelCellDelegate?
    var defaults = UserDefaults.standard
    var isLoadDropDown = false
    var isLoadFirstTime : Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FilterChannelMultipleQiscusWidgetCell", bundle: nil), forCellReuseIdentifier: "FilterChannelMultipleQiscusWidgetCellIdentifire")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUIQiscusWidget"), object: nil)
        
    }
    
    func setupData(data: [QiscusWidgetChannelModel]){
        self.dataQiscusWidgetChannelModel = data
        
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
                    delegate.updateDataQiscusWidget(isQiscusWidgetSelected: true, dataQiscusWidgetChannelModel: self.dataQiscusWidgetChannelModel)
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
        self.btQiscusWidget.isSelected = false
        self.btQiscusWidget.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = 0
    }
    
    func dropUPAction(){
        self.btQiscusWidget.isSelected = true
        self.btQiscusWidget.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = CGFloat(self.dataQiscusWidgetChannelModel.count * 44)
    }
    
    func checkAction(){
        self.checkUnCheckQiscusWidget.isSelected = true
        self.checkUnCheckQiscusWidget.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
    }
    
    func unCheckAction(){
        self.checkUnCheckQiscusWidget.isSelected = false
        self.checkUnCheckQiscusWidget.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func QiscusWidgetCheckUnCheck(_ sender: Any) {
        if self.checkUnCheckQiscusWidget.isSelected == true {
            self.unCheckAction()
            
            //unCheck multiple QiscusWidget
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unCheckALLMultipleQiscusWidget"), object: nil)
            
            for data in self.dataQiscusWidgetChannelModel.enumerated() {
                data.element.isSelected = false
            }
            
            if let delegate = delegate {
                delegate.updateDataQiscusWidget(isQiscusWidgetSelected: false, dataQiscusWidgetChannelModel: nil)
            }
        }else {
            self.checkAction()
            
            //checkALL multiple QiscusWidget
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleQiscusWidget"), object: nil)
            
            for data in self.dataQiscusWidgetChannelModel.enumerated() {
                data.element.isSelected = true
            }
            
            if let delegate = delegate {
                delegate.updateDataQiscusWidget(isQiscusWidgetSelected: true, dataQiscusWidgetChannelModel: self.dataQiscusWidgetChannelModel)
            }
        }
    }
    
    @IBAction func dropDownQiscusWidgetAction(_ sender: Any) {
        if self.btQiscusWidget.isSelected == true {
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
        self.btQiscusWidget.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.btQiscusWidget.isSelected = false
        
        self.tableViewHeightCons.constant = 0
        self.isLoadDropDown = false
        self.checkUnCheckQiscusWidget.isSelected = false
        self.checkUnCheckQiscusWidget.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        
        self.tableView.reloadData()
        
    }
    
}

extension QiscusWidgetChannelCell : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.dataQiscusWidgetChannelModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterChannelMultipleQiscusWidgetCellIdentifire", for: indexPath) as! FilterChannelMultipleQiscusWidgetCell
        if self.dataQiscusWidgetChannelModel.count != 0 {
            cell.delegate = self
            cell.setupData(data: self.dataQiscusWidgetChannelModel[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

extension QiscusWidgetChannelCell : FilterChannelMultipleQiscusWidgetCellDelegate {
    func updateFilterSelected(indexPath: IndexPath, isSelected: Bool) {
        self.dataQiscusWidgetChannelModel[indexPath.row].isSelected = isSelected
        if let delegate = delegate {
            delegate.updateDataQiscusWidget(isQiscusWidgetSelected: isSelected, dataQiscusWidgetChannelModel: self.dataQiscusWidgetChannelModel)
        }
        
        var counter = 0
        for i in self.dataQiscusWidgetChannelModel{
            if i.isSelected == true{
                counter += 1
            }
        }
        
        if counter == self.dataQiscusWidgetChannelModel.count {
            checkAction()
        }else{
            unCheckAction()
        }
    }
}
