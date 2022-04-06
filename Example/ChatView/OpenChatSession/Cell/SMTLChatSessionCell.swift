//
//  SMTLChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 02/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class SMTLChatSessionCell: UITableViewCell {
    @IBOutlet weak var viewTableView: UIView!
    @IBOutlet weak var viewTF: UIView!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfSMTL: UITextField!
    var vc : NewOpenChatSessionWAVC? = nil
    var dataLanguage = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewTF.layer.shadowColor = UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 0.15).cgColor
        self.viewTF.layer.shadowOffset = CGSize(width: -3, height: 5)
        self.viewTF.layer.shadowOpacity = 1
        self.viewTF.layer.shadowRadius = 14
        self.viewTF.layer.cornerRadius = 8
        
        self.viewTableView.layer.shadowColor = UIColor(red: 0.412, green: 0.412, blue: 0.412, alpha: 0.15).cgColor
        self.viewTableView.layer.shadowOffset = CGSize(width: -3, height: 5)
        self.viewTableView.layer.shadowOpacity = 1
        self.viewTableView.layer.shadowRadius = 14
        self.viewTableView.layer.cornerRadius = 8
        
        self.tfSMTL.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: -20, y: -20, width: 20, height: 20))
        let image = UIImage(named: "ic_drop_down")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = UIColor.lightGray
        self.tfSMTL.rightView = imageView
        
        
        
         //tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "OpenSessionWACell", bundle: nil), forCellReuseIdentifier: "OpenSessionWACellIdentifire")
        self.tableView.reloadData()
        
        self.tableViewHeightCons.constant = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectMessageTypeAction(_ sender: Any) {
        self.updateTableView()
    }
    
    func updateTableView(){
        if self.tableViewHeightCons.constant ==  CGFloat(self.dataLanguage.count * 50) {
            self.tableViewHeightCons.constant = 0
            self.tableView.alpha = 0
        }else{
            self.tableViewHeightCons.constant = CGFloat(self.dataLanguage.count * 50)
            self.tableView.alpha = 1
        }
        
        //reload master tableView
        self.vc?.reloadTableView()
    }
    
}

extension SMTLChatSessionCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataLanguage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSessionWACellIdentifire", for: indexPath) as! OpenSessionWACell
        
        cell.lbMessage.text = self.dataLanguage[indexPath.row]
       
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        self.tfSMTL.text = self.dataLanguage[indexPath.row]
        self.vc?.dataSMTLSelected =  self.tfSMTL.text ?? ""
        self.updateTableView()
        
    }
    
}



