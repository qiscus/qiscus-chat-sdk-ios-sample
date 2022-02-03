//
//  InstagramChannelCell.swift
//  Example
//
//  Created by Qiscus on 16/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol InstagramChannelCellDelegate{
    func updateDataInstagram(isInstagramSelected: Bool, dataInstagramChannelModel : [InstagramChannelModel]?)
}

class InstagramChannelCell: UITableViewCell {

    @IBOutlet weak var btInstagram: UIButton!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkUnCheckInstagram: UIButton!
    
    var viewController : FilterVC? = nil
    var dataInstagramChannelModel = [InstagramChannelModel]()
    var checkLatestConsTableView : CGFloat = 0
    var delegate: InstagramChannelCellDelegate?
    var defaults = UserDefaults.standard
    var isLoadDropDown = false
    var isLoadFirstTime : Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FilterChannelMultipleInstagramCell", bundle: nil), forCellReuseIdentifier: "FilterChannelMultipleInstagramCellIdentifire")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUIInstagram"), object: nil)
        
    }
    
    func setupData(data: [InstagramChannelModel]){
        self.dataInstagramChannelModel = data
        
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
                    delegate.updateDataInstagram(isInstagramSelected: true, dataInstagramChannelModel: self.dataInstagramChannelModel)
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
        self.btInstagram.isSelected = false
        self.btInstagram.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = 0
    }
    
    func dropUPAction(){
        self.btInstagram.isSelected = true
        self.btInstagram.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = CGFloat(self.dataInstagramChannelModel.count * 44)
    }
    
    func checkAction(){
        self.checkUnCheckInstagram.isSelected = true
        self.checkUnCheckInstagram.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
    }
    
    func unCheckAction(){
        self.checkUnCheckInstagram.isSelected = false
        self.checkUnCheckInstagram.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func InstagramCheckUnCheck(_ sender: Any) {
        if self.checkUnCheckInstagram.isSelected == true {
            self.unCheckAction()
            
            //unCheck multiple Instagram
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unCheckALLMultipleInstagram"), object: nil)
            
            for data in self.dataInstagramChannelModel.enumerated() {
                data.element.isSelected = false
            }
            
            if let delegate = delegate {
                delegate.updateDataInstagram(isInstagramSelected: false, dataInstagramChannelModel: nil)
            }
        }else {
            self.checkAction()
            
            //checkALL multiple Instagram
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleInstagram"), object: nil)
            
            for data in self.dataInstagramChannelModel.enumerated() {
                data.element.isSelected = true
            }
            
            if let delegate = delegate {
                delegate.updateDataInstagram(isInstagramSelected: true, dataInstagramChannelModel: self.dataInstagramChannelModel)
            }
        }
    }
    
    @IBAction func dropDownInstagramAction(_ sender: Any) {
        if self.btInstagram.isSelected == true {
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
        self.btInstagram.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.btInstagram.isSelected = false
        
        self.tableViewHeightCons.constant = 0
        self.isLoadDropDown = false
        self.checkUnCheckInstagram.isSelected = false
        self.checkUnCheckInstagram.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        
        self.tableView.reloadData()
        
    }
    
}

extension InstagramChannelCell : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.dataInstagramChannelModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterChannelMultipleInstagramCellIdentifire", for: indexPath) as! FilterChannelMultipleInstagramCell
        if self.dataInstagramChannelModel.count != 0 {
            cell.delegate = self
            cell.setupData(data: self.dataInstagramChannelModel[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

extension InstagramChannelCell : FilterChannelMultipleInstagramCellDelegate {
    func updateFilterSelected(indexPath: IndexPath, isSelected: Bool) {
        self.dataInstagramChannelModel[indexPath.row].isSelected = isSelected
        if let delegate = delegate {
            delegate.updateDataInstagram(isInstagramSelected: isSelected, dataInstagramChannelModel: self.dataInstagramChannelModel)
        }
        
        var counter = 0
        for i in self.dataInstagramChannelModel{
            if i.isSelected == true{
                counter += 1
            }
        }
        
        if counter == self.dataInstagramChannelModel.count {
            checkAction()
        }else{
            unCheckAction()
        }
    }
}
