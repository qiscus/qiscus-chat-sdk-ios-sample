//
//  FilterChannelMultipleInstagramCell.swift
//  Example
//
//  Created by Qiscus on 18/11/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol FilterChannelMultipleInstagramCellDelegate{
    func updateFilterSelected(indexPath: IndexPath, isSelected: Bool)
}

class FilterChannelMultipleInstagramCell: UITableViewCell {

    @IBOutlet weak var btCheckUnCheck: UIButton!
    @IBOutlet weak var titleName: UILabel!
    var indexPath = IndexPath()
    var delegate: FilterChannelMultipleInstagramCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(check(_:)), name: NSNotification.Name(rawValue: "checkALLMultipleInstagram"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(unCheck(_:)), name: NSNotification.Name(rawValue: "unCheckALLMultipleInstagram"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupData(data: InstagramChannelModel, indexPath : IndexPath){
        self.indexPath = indexPath
        self.titleName.text = data.name
        if data.isSelected == true{
            checkAction()
        }else{
            unCheckAction()
        }
    }
    
    @IBAction func checkUnCheckAction(_ sender: Any) {
        self.action()
    }
    
    func action(){
        if self.btCheckUnCheck.isSelected == true {
            self.unCheckAction()
        }else {
            self.checkAction()
        }
        
        if let delegate = self.delegate{
            delegate.updateFilterSelected(indexPath: self.indexPath, isSelected: self.btCheckUnCheck.isSelected)
        }
    }
    
    @objc func check(_ notification: Notification){
        self.checkAction()
    }
    
    @objc func unCheck(_ notification: Notification){
        self.unCheckAction()
    }
    
    func checkAction(){
        self.btCheckUnCheck.isSelected = true
        self.btCheckUnCheck.setImage(UIImage(named: "ic_rectangle_check_ok"), for: .normal)
    }
    
    func unCheckAction(){
        self.btCheckUnCheck.isSelected = false
        self.btCheckUnCheck.setImage(UIImage(named: "ic_rectangle_check"), for: .normal)
    }
    
}
