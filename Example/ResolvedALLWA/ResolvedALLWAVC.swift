//
//  ResolvedALLWAVC.swift
//  Example
//
//  Created by Qiscus on 07/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResolvedALLWAVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tvText: UITextView!
    var dataWAChannels = [WAChannelResolveModel]()
    var queque = [WAChannelResolveModel]()
    var waitingList = [IndexPath]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getDataALLWA()
    }
    
    func setupUI(){
        self.title = "Resolve All Expired Chat"
        let backButton = self.backButton(self, action: #selector(ResolvedALLWAVC.goBack))
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ResolveALLExpiredWACell", bundle: nil), forCellReuseIdentifier: "ResolveALLExpiredWACellIdentifire")
        self.tableView.register(UINib(nibName: "InProgressResolveALLExpiredWACell", bundle: nil), forCellReuseIdentifier: "InProgressResolveALLExpiredWACellIdentifire")
        self.tableView.register(UINib(nibName: "WaitingResolveALLExpiredWACell", bundle: nil), forCellReuseIdentifier: "WaitingResolveALLExpiredWACellIdentifire")
        self.tableView.tableFooterView = UIView()
        
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.alignment = .justified
        let attributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor(red: 94/255.0, green: 107/255.0, blue: 125/255.0, alpha:1.0)]
        //
        let attributedString = NSMutableAttributedString(string: "You can easily resolve all conversations from WhatsApp that has expired based on the channel you want here. To learn more regarding resolve all expired WhatsApp conversation please check this documentation", attributes: attributes)
        let linkRange = (attributedString.string as NSString).range(of: "documentation")
        attributedString.addAttribute(NSAttributedString.Key.link, value: "https://documentation.qiscus.com/multichannel-customer-service/getting-started#resolve-all-expired-chat", range: linkRange)
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: ColorConfiguration.defaultColorTosca,
        ]
        self.tvText.linkTextAttributes = linkAttributes
        self.tvText.attributedText = attributedString
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor.white
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func getDataALLWA(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/bulk_resolve/wa", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getDataALLWA()
                            } else {
                                return
                            }
                        }
                    }else{
                        //show error
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                  
                    let waChannels = json["data"].array
                   
                    
                    if waChannels?.count != 0 {
                        for data in waChannels! {
                            var dataWA = WAChannelResolveModel(json: data)
                            self.dataWAChannels.append(dataWA)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    //tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataWAChannels.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.dataWAChannels[indexPath.row]
        
        if self.queque.count == 0{
            //no queque / normal
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResolveALLExpiredWACellIdentifire", for: indexPath) as! ResolveALLExpiredWACell
            cell.viewCell.layer.shadowColor = UIColor.black.cgColor
            cell.viewCell.layer.shadowOffset = CGSize(width: 1, height: 1)
            cell.viewCell.layer.shadowOpacity = 0.3
            cell.viewCell.layer.shadowRadius = 1.0
            cell.viewCell.layer.cornerRadius = 8
            cell.mainVC = self
            cell.delegate = self
            cell.queque = self.queque.count
            cell.setupData(dataWAChannel: data, indexPath: indexPath)

            return cell
        }else{
            if data.inProgressResolve == true {
                if data.isWaiting == false {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InProgressResolveALLExpiredWACellIdentifire", for: indexPath) as! InProgressResolveALLExpiredWACell
                    cell.viewInProgress.layer.shadowColor = UIColor.black.cgColor
                    cell.viewInProgress.layer.shadowOffset = CGSize(width: 1, height: 1)
                    cell.viewInProgress.layer.shadowOpacity = 0.3
                    cell.viewInProgress.layer.shadowRadius = 1.0
                    cell.viewInProgress.layer.cornerRadius = 8
                    cell.mainVC = self
                    cell.delegate = self
                    cell.setupData(dataWAChannel: data, indexPath: indexPath)
                    return cell
                }else{
                    //UIWAITING
                    let cell = tableView.dequeueReusableCell(withIdentifier: "WaitingResolveALLExpiredWACellIdentifire", for: indexPath) as! WaitingResolveALLExpiredWACell
                    cell.viewInProgress.layer.shadowColor = UIColor.black.cgColor
                    cell.viewInProgress.layer.shadowOffset = CGSize(width: 1, height: 1)
                    cell.viewInProgress.layer.shadowOpacity = 0.3
                    cell.viewInProgress.layer.shadowRadius = 1.0
                    cell.viewInProgress.layer.cornerRadius = 8
                    cell.mainVC = self
                    cell.delegate = self
                    cell.setupData(dataWAChannel: data, indexPath : indexPath)
                    return cell
                }
            }else{
                //normal
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResolveALLExpiredWACellIdentifire", for: indexPath) as! ResolveALLExpiredWACell
                cell.viewCell.layer.shadowColor = UIColor.black.cgColor
                cell.viewCell.layer.shadowOffset = CGSize(width: 1, height: 1)
                cell.viewCell.layer.shadowOpacity = 0.3
                cell.viewCell.layer.shadowRadius = 1.0
                cell.viewCell.layer.cornerRadius = 8
                cell.mainVC = self
                cell.delegate = self
                cell.queque = self.queque.count
                cell.setupData(dataWAChannel: data, indexPath: indexPath)

                return cell
            }
            
        }
        
       return UITableViewCell()
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension ResolvedALLWAVC : ResolveALLExpiredWACellDelegate {
    func inProgressResolve(data : WAChannelResolveModel, indexPath: IndexPath){
        self.waitingList.append(indexPath)
        for (index, element) in self.dataWAChannels.enumerated(){
            if dataWAChannels[index].channelId == data.channelId{
                if self.queque.count == 0 {
                    data.inProgressResolve = true
                    data.isWaiting = false
                }else{
                    data.inProgressResolve = true
                    data.isWaiting = true
                }
                dataWAChannels[index] = data
                self.queque.append(data)
                
                
                
               self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

extension ResolvedALLWAVC : WaitingResolveALLExpiredWACellDelegate {
    func cancelResolve(data : WAChannelResolveModel, indexPath : IndexPath){
        for (index, element) in self.dataWAChannels.enumerated(){
            if dataWAChannels[index].channelId == data.channelId{
                dataWAChannels[index] = data
                
                if self.queque.count != 0 {
                    self.queque = self.queque.filter { $0.channelId != data.channelId }
                    
                    self.waitingList = self.waitingList.filter { $0 != indexPath }
                   
                    
                }
               
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

extension ResolvedALLWAVC : InProgressResolveALLExpiredWACellDelegate {
    func cancelResolveInProgress(data : WAChannelResolveModel, indexPath : IndexPath){
        for (index, element) in self.dataWAChannels.enumerated(){
            if dataWAChannels[index].channelId == data.channelId{
                dataWAChannels[index] = data
                if  self.queque.count != 0{
                    self.queque.removeFirst()
                    self.waitingList.removeFirst()
                    
                    if self.queque.count != 0{
                        if let que = self.queque.first {
                            que.isWaiting = false
                            
                            for (index, element) in self.queque.enumerated(){
                                if self.queque[index].channelId == que.channelId {
                                    self.queque[index] = que
                                }
                            }
                        }
                    }
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .none)
                if self.waitingList.count != 0 {
                    self.tableView.reloadRows(at: [self.waitingList.first!], with: .none)
                }
            }
        }
    }
    
    func updateStatusResolve(data : WAChannelResolveModel, indexPath : IndexPath){
        for (index, element) in self.dataWAChannels.enumerated(){
            if dataWAChannels[index].channelId == data.channelId{
                dataWAChannels[index] = data
                
                if data.progressStatus.lowercased() == "finished" {
                    if self.queque.count != 0{
                        self.waitingList.removeFirst()
                        self.queque.removeFirst()
                        
                        if self.queque.count != 0{
                            if let que = self.queque.first {
                                que.isWaiting = false
                                
                                for (index, element) in self.queque.enumerated(){
                                    if self.queque[index].channelId == que.channelId {
                                        self.queque[index] = que
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    if self.waitingList.count != 0 {
                        self.tableView.reloadRows(at: [self.waitingList.first!], with: .none)
                    }
                }
            }
        }
    }
}

