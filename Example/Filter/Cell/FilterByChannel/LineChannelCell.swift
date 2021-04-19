//
//  LineChannelCell.swift
//  Example
//
//  Created by Qiscus on 15/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol LineChannelCellDelegate{
    func updateDataLine(isLineSelected: Bool, dataLineChannelModel : [LineChannelModel]?)
}

class LineChannelCell: UITableViewCell {

    @IBOutlet weak var btLine: UIButton!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkUnCheckLine: UIButton!
    
    var viewController : FilterVC? = nil
    var dataLineChannelModel = [LineChannelModel]()
    var delegate: LineChannelCellDelegate?
    var defaults = UserDefaults.standard
    var isLoadDropDown = false
    var isLoadFirstTime : Bool = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "FilterChannelMultipleLineCell", bundle: nil), forCellReuseIdentifier: "FilterChannelMultipleLineCellIdentifire")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUI(_:)), name: NSNotification.Name(rawValue: "resetUILine"), object: nil)
        
    }
    
    func setupData(data: [LineChannelModel]){
        self.dataLineChannelModel = data
        
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
                    delegate.updateDataLine(isLineSelected: true, dataLineChannelModel: self.dataLineChannelModel)
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
        self.btLine.isSelected = false
        self.btLine.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = 0
    }
    
    func dropUPAction(){
        self.btLine.isSelected = true
        self.btLine.setImage(UIImage(named: "ic_drop_up_filter"), for: .normal)
        
        self.tableViewHeightCons.constant = CGFloat(self.dataLineChannelModel.count * 44)
    }
    
    func checkAction(){
        self.checkUnCheckLine.isSelected = true
        self.checkUnCheckLine.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
    }
    
    func unCheckAction(){
        self.checkUnCheckLine.isSelected = false
        self.checkUnCheckLine.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func LineCheckUnCheck(_ sender: Any) {
        if self.checkUnCheckLine.isSelected == true {
            self.unCheckAction()
            
            //unCheck multiple Line
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "unCheckALLMultipleLine"), object: nil)
            
            for data in self.dataLineChannelModel.enumerated() {
                data.element.isSelected = false
            }
            
            if let delegate = delegate {
                delegate.updateDataLine(isLineSelected: false, dataLineChannelModel: nil)
            }
        }else {
            self.checkAction()
            
            //checkALL multiple Line
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "checkALLMultipleLine"), object: nil)
            
            for data in self.dataLineChannelModel.enumerated() {
                data.element.isSelected = true
            }
            
            if let delegate = delegate {
                delegate.updateDataLine(isLineSelected: true, dataLineChannelModel: self.dataLineChannelModel)
            }
        }
    }
    
    @IBAction func dropDownLineAction(_ sender: Any) {
        if self.btLine.isSelected == true {
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
        self.btLine.setImage(UIImage(named: "ic_drop_down_filter"), for: .normal)
        self.btLine.isSelected = false
        
        self.tableViewHeightCons.constant = 0
        self.isLoadDropDown = false
        self.checkUnCheckLine.isSelected = false
        self.checkUnCheckLine.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
        
        self.tableView.reloadData()
        
    }
    
}

extension LineChannelCell : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.dataLineChannelModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterChannelMultipleLineCellIdentifire", for: indexPath) as! FilterChannelMultipleLineCell
        if self.dataLineChannelModel.count != 0 {
            cell.delegate = self
            cell.setupData(data: self.dataLineChannelModel[indexPath.row], indexPath: indexPath)
        }
        
        return cell
    }
}

extension LineChannelCell : FilterChannelMultipleLineCellDelegate {
    func updateFilterSelected(indexPath: IndexPath, isSelected: Bool) {
        self.dataLineChannelModel[indexPath.row].isSelected = isSelected
        if let delegate = delegate {
            delegate.updateDataLine(isLineSelected: isSelected, dataLineChannelModel: self.dataLineChannelModel)
        }
        
        var counter = 0
        for i in self.dataLineChannelModel{
            if i.isSelected == true{
                counter += 1
            }
        }
        
        if counter == self.dataLineChannelModel.count {
            checkAction()
        }else{
            unCheckAction()
        }
    }
}
