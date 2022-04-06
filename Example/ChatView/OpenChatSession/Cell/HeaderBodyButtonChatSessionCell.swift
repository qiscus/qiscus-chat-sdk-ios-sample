//
//  HeaderBodyButtonChatSessionCell.swift
//  Example
//
//  Created by arief nur putranto on 10/03/22.
//  Copyright © 2022 Qiscus. All rights reserved.
//

import UIKit

class HeaderBodyButtonChatSessionCell: UITableViewCell {

    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btButton: UIButton!
    @IBOutlet weak var btBody: UIButton!
    @IBOutlet weak var btHeader: UIButton!
    var vc : NewOpenChatSessionWAVC? = nil
    var data = [BroadcastTemplateModel]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ListOfHeaderBodyButtonCell", bundle: nil), forCellReuseIdentifier: "ListOfHeaderBodyButtonCellIdentifire")
        self.tableView.register(UINib(nibName: "OpenSessionWAListCell", bundle: nil), forCellReuseIdentifier: "OpenSessionWAListCellIdentifire")
        
       // self.setupHeightTableView()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupButton(isClick : Int, isFirstTime : Bool = false){
        
        let textAttribute: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha:1.0), .font: UIFont.systemFont(ofSize: 14)]
        
        let textAttributeSelected: [NSAttributedString.Key : Any] = [.foregroundColor: ColorConfiguration.defaultColorTosca, .font: UIFont.systemFont(ofSize: 14)]
              
        self.vc?.tabSelectedButton = isClick
        if isClick == 1 {
            self.btHeader.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btHeader.titleLabel?.tintColor = ColorConfiguration.defaultColorTosca
            self.btHeader.setAttributedTitle(NSAttributedString(string: "Header", attributes: textAttributeSelected), for: .normal)
            self.btHeader.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btHeader.layer.cornerRadius = 4
            self.btHeader.layer.borderWidth = 1
            self.btHeader.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
            self.btHeader.tintColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            
            self.btBody.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btBody.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btBody.titleLabel?.tintColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha:1.0)
            self.btBody.setAttributedTitle(NSAttributedString(string: "Body", attributes: textAttribute), for: .normal)
            
            
            self.btBody.layer.cornerRadius = 4
            self.btBody.layer.borderWidth = 1
            self.btBody.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1).cgColor
            
          
            self.btButton.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btButton.titleLabel?.tintColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha:1.0)
            self.btButton.setAttributedTitle(NSAttributedString(string: "Button", attributes: textAttribute), for: .normal)
            self.btButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btButton.layer.cornerRadius = 4
            self.btButton.layer.borderWidth = 1
            self.btButton.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1).cgColor
        }else if isClick == 2{
            self.btBody.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btBody.titleLabel?.tintColor = ColorConfiguration.defaultColorTosca
            self.btBody.setAttributedTitle(NSAttributedString(string: "Body", attributes: textAttributeSelected), for: .normal)
            self.btBody.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btBody.layer.cornerRadius = 4
            self.btBody.layer.borderWidth = 1
            self.btBody.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
            self.btBody.tintColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            
            
            self.btHeader.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btHeader.titleLabel?.tintColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha:1.0)
            self.btHeader.setAttributedTitle(NSAttributedString(string: "Header", attributes: textAttribute), for: .normal)
            self.btHeader.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btHeader.layer.cornerRadius = 4
            self.btHeader.layer.borderWidth = 1
            self.btHeader.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1).cgColor
            
            
            self.btButton.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btButton.titleLabel?.tintColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha:1.0)
            self.btButton.setAttributedTitle(NSAttributedString(string: "Button", attributes: textAttribute), for: .normal)
            self.btButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btButton.layer.cornerRadius = 4
            self.btButton.layer.borderWidth = 1
            self.btButton.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1).cgColor
        }else{
           
            self.btButton.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btButton.titleLabel?.tintColor = ColorConfiguration.defaultColorTosca
            self.btButton.setAttributedTitle(NSAttributedString(string: "Button", attributes: textAttributeSelected), for: .normal)
            self.btButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btButton.layer.cornerRadius = 4
            self.btButton.layer.borderWidth = 1
            self.btButton.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor
            self.btButton.tintColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            

            self.btBody.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btBody.titleLabel?.tintColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha:1.0)
            self.btBody.setAttributedTitle(NSAttributedString(string: "Body", attributes: textAttribute), for: .normal)
            self.btBody.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btBody.layer.cornerRadius = 4
            self.btBody.layer.borderWidth = 1
            self.btBody.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1).cgColor
            
            
            self.btHeader.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1)
            self.btHeader.titleLabel?.tintColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha:1.0)
            self.btHeader.setAttributedTitle(NSAttributedString(string: "Header", attributes: textAttribute), for: .normal)
            self.btHeader.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.btHeader.layer.cornerRadius = 4
            self.btHeader.layer.borderWidth = 1
            self.btHeader.layer.borderColor = UIColor(red: 242/255, green: 242/255, blue: 246/255, alpha: 1).cgColor
        }
    }
    
    func setupHeightTableView(){
        let data = self.data.first?.hsmDetails.filter { $0.language.lowercased() == self.vc?.dataBroadCastLanguageSelected.lowercased() }
        
        if let data = data?.first {
            let countBody = self.vc?.dataBody.count ?? 0
            if countBody == 0 && data.countBody != 0{
                for i in 1...data.countBody {
                    self.vc?.dataBody.append("")
                }
            }
            
            let countHeader = self.vc?.dataHeader.count ?? 0
            if countHeader == 0 && data.countHeader != 0 {
                for i in 1...data.countHeader {
                    self.vc?.dataHeader.append("")
                }
            }
            
            let countButton = self.vc?.dataButton.count ?? 0
            if countButton == 0 && data.countButton != 0{
                for i in 1...data.countButton {
                    self.vc?.dataButton.append("")
                }
            }
        }
       
        
        let selected = self.vc?.tabSelectedButton
        if selected == 1 {
            if data?.count == 0 {
                //show no header
                heightOfTableView.constant = 50
            }else{
                if let data = data?.first {
                    if data.countHeader == 0 {
                        //show no header
                        heightOfTableView.constant = 50
                    }else{
                        heightOfTableView.constant =  CGFloat((data.countHeader * 113))
                    }
                   
                }else{
                    heightOfTableView.constant = 50
                }
                
            }
        }else if selected == 2{
            if data?.count == 0 {
                //show no body
                heightOfTableView.constant = 50
            }else{
                if let data = data?.first {
                    if data.countBody == 0 {
                        //show no header
                        heightOfTableView.constant = 50
                    }else{
                        heightOfTableView.constant =  CGFloat((data.countBody * 113))
                    }
                }else{
                    heightOfTableView.constant = 50
                }
            }
        }else{
            if data?.count == 0 {
                //show no button
                heightOfTableView.constant = 50
            }else{
                if let data = data?.first {
                    if data.countButton == 0 {
                        //show no header
                        heightOfTableView.constant = 50
                    }else{
                        heightOfTableView.constant =  CGFloat((data.countButton * 113))
                    }
                    
                }else{
                    heightOfTableView.constant = 50
                }
            }
        }
        
        self.vc?.isReloadTableViewFromHeaderBodyButton = false
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.vc?.reloadTableView()
            }
        
        self.vc?.checkDataCanSend()
    }
   
    
    @IBAction func headerActionClick(_ sender: Any) {
        self.setupButton(isClick: 1)
        self.setupHeightTableView()
    }
    
    @IBAction func bodyActionClick(_ sender: Any) {
        self.setupButton(isClick: 2)
        self.setupHeightTableView()
    }
    
    @IBAction func buttonActionClick(_ sender: Any) {
        self.setupButton(isClick: 3)
        self.setupHeightTableView()
    }
}


extension HeaderBodyButtonChatSessionCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let data = self.data.first?.hsmDetails.filter { $0.language.lowercased() == self.vc?.dataBroadCastLanguageSelected.lowercased() }
        
        
        let selected = self.vc?.tabSelectedButton
        if selected == 1 {
            if data?.count == 0 {
                //show no header
                return 1
            }else{
                if data?.first?.countHeader == 0 {
                    //show no header
                    return 1
                }else{
                    return data?.first?.countHeader ?? 0
                }
                
            }
        }else if selected == 2{
            if data?.count == 0 {
                //show no body
                return 1
            }else{
                if data?.first?.countBody  == 0 {
                    //show no body
                    return 1
                }else{
                    return data?.first?.countBody ?? 0
                }
               
            }
        }else{
            if data?.count == 0 {
                //show no button
                return 1
            }else{
                if data?.first?.countButton == 0 {
                    //show no button
                    return 1
                }else{
                    return data?.first?.countButton ?? 0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellNoResult = tableView.dequeueReusableCell(withIdentifier: "OpenSessionWAListCellIdentifire", for: indexPath) as! OpenSessionWAListCell
        
        let dataFilter = self.data.first?.hsmDetails.filter { $0.language.lowercased() == self.vc?.dataBroadCastLanguageSelected.lowercased() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListOfHeaderBodyButtonCellIdentifire", for: indexPath) as! ListOfHeaderBodyButtonCell
        cell.vc = self.vc
        let selected = self.vc?.tabSelectedButton
        var data = ""
        
        if selected == 1 {
            if dataFilter?.count == 0 || dataFilter?.first?.countHeader == 0 {
                //show no header
                cellNoResult.lbMessage.text = "This template message does not have header or variables."
                cellNoResult.lbMessage.font = UIFont.italicSystemFont(ofSize: 14)
                return cellNoResult
            }else{
                data = self.vc?.dataHeader.first ?? ""
                cell.setup(type: self.vc?.tabSelectedButton ?? 1, data: data, indexData: indexPath.row)
                return cell
            }
        }else if selected == 2 {
            if dataFilter?.count == 0 || dataFilter?.first?.countBody == 0 {
                //show no body
                cellNoResult.lbMessage.text = "This template message does not have body or variables."
                cellNoResult.lbMessage.font = UIFont.italicSystemFont(ofSize: 14)
                return cellNoResult
            }else{
                if self.vc?.dataBody.count != 0{
                    data = self.vc?.dataBody[indexPath.row] ?? ""
                    
                    cell.setup(type: self.vc?.tabSelectedButton ?? 1, data: data, indexData: indexPath.row)
                    return cell
                }else{
                    cellNoResult.lbMessage.text = "This template message does not have body or variables."
                    cellNoResult.lbMessage.font = UIFont.italicSystemFont(ofSize: 14)
                    return cellNoResult
                }
            }
        }else{
            if dataFilter?.count == 0 || dataFilter?.first?.countButton == 0{
                //show no button
                cellNoResult.lbMessage.text = "This template message does not have button or variables."
                cellNoResult.lbMessage.font = UIFont.italicSystemFont(ofSize: 14)
                return cellNoResult
            }else{
                if self.vc?.dataButton.count != 0{
                    data = self.vc?.dataButton[indexPath.row] ?? ""
                    
                    cell.setup(type: self.vc?.tabSelectedButton ?? 1, data: data, indexData: indexPath.row)
                    return cell
                }else{
                    cellNoResult.lbMessage.text = "This template message does not have button or variables."
                    cellNoResult.lbMessage.font = UIFont.italicSystemFont(ofSize: 14)
                    return cellNoResult
                }
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
}
