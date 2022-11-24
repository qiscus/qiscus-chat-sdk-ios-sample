//
//  BroadcastHistoryVC.swift
//  Example
//
//  Created by Qiscus on 13/12/20.
//  Copyright © 2020 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BroadcastHistoryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lbNoDataListBroadCast: UILabel!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var viewBgDetail: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var lbDetailTime: UILabel!
    @IBOutlet weak var lbDetailStatus: UILabel!
    @IBOutlet weak var lbDetailTemplateName: UILabel!
    @IBOutlet weak var lbDetailMessage: UILabel!
    
    @IBOutlet weak var viewHeaderDetail: UIView!
    @IBOutlet weak var lbHeader: UILabel!
    
    @IBOutlet weak var ivImageRightConst: NSLayoutConstraint!
    @IBOutlet weak var ivImageHeaderWidhtConst: NSLayoutConstraint!
    @IBOutlet weak var lbHeaderTop: UILabel!
    @IBOutlet weak var ivImageHeader: UIImageView!
    @IBOutlet weak var viewHeaderDetailConst: NSLayoutConstraint!
    
    
    @IBOutlet weak var viewFooterDetail: UIView!
    @IBOutlet weak var heightViewFooterDeailConst: NSLayoutConstraint!
    @IBOutlet weak var lbFooter: UILabel!

    
    @IBOutlet weak var viewButtonDetail: UIView!
    @IBOutlet weak var stackViewButton: UIStackView!
    @IBOutlet weak var stackViewButtonHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var lbButtonTop: UILabel!
    @IBOutlet weak var heightViewButtonConst: NSLayoutConstraint!
    
    var dataBroadCastHistory = [BroadCastHistoryModel]()
    var roomID = ""
    var totalBroadCastHistory = 1
    var page = 2
    var noLoadMore = false
    
    var buttonCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI(){
        //setup navigationBar
        self.title = "Broadcast History"
        let backButton = self.backButton(self, action: #selector(BroadcastHistoryVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        //table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "DetailBroadcastHistoryCell", bundle: nil), forCellReuseIdentifier: "DetailBroadcastHistoryCellIdentifire")
        
        self.tableView.tableFooterView = UIView()
        
        self.btCancel.layer.cornerRadius = self.btCancel.frame.height / 2

        self.btCancel.layer.borderWidth = 2
        self.btCancel.layer.borderColor = ColorConfiguration.defaultColorTosca.cgColor

        self.viewPopup.layer.cornerRadius = 8
        
        if self.dataBroadCastHistory.count == 0 {
            self.lbNoDataListBroadCast.alpha = 1
        } else {
            self.lbNoDataListBroadCast.alpha = 0
        }
        
    }
    
    func showDetail(data : BroadCastHistoryModel){
        self.buttonCount = 0
        
        self.stackViewButton.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        self.viewBgDetail.alpha = 1
        self.lbDetailTime.text = "\(data.dateString(date: data.getDate())) (\((data.hour(date: data.getDate()))))"
        self.lbDetailMessage.text = data.message
        self.lbDetailTemplateName.text = data.templateName
        
        if data.status == 4 {
           self.lbDetailStatus.text = "Read"
        } else if data.status == 3 {
            self.lbDetailStatus.text = "Delivered"
        } else if data.status == 2 {
             self.lbDetailStatus.text = "Sent"
        } else if data.status == 1 {
             self.lbDetailStatus.text = "Pending"
        }else{
            self.lbDetailStatus.text = "Failed"
        }
        
        if data.header.isEmpty == true {
            self.viewHeaderDetailConst.constant = 0
            self.viewHeaderDetail.alpha = 0
        }else{
            self.viewHeaderDetailConst.constant = 70
            self.viewHeaderDetail.alpha = 1
            
            let data = data.header
            let json = JSON.init(parseJSON: data)
            let valueText = json["text"].string ?? ""
            let valueType = json["type"].string ?? ""
            
            self.lbHeaderTop.text = "Header (\(valueType))"
            self.lbHeader.text = valueText
            
            if valueType.lowercased() == "image" || valueType.lowercased() == "images"{
                self.ivImageHeaderWidhtConst.constant = 14
                self.ivImageRightConst.constant = 5
                self.lbHeader.text = "Image"
                self.ivImageHeader.image = UIImage(named: "ic_broadcast_image")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.ivImageHeader.tintColor = ColorConfiguration.defaultColorTosca
            }else if valueType.lowercased() == "video" || valueType.lowercased() == "videos"{
                self.ivImageHeaderWidhtConst.constant = 14
                self.ivImageRightConst.constant = 5
                self.lbHeader.text = "Video"
                self.ivImageHeader.image = UIImage(named: "ic_videocam")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.ivImageHeader.tintColor = ColorConfiguration.defaultColorTosca
            }else if valueType.lowercased() == "document" || valueType.lowercased() == "documents" || valueType.lowercased() == "file" || valueType.lowercased() == "files"{
                self.ivImageHeaderWidhtConst.constant = 14
                self.ivImageRightConst.constant = 5
                self.lbHeader.text = "Document"
                self.ivImageHeader.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.ivImageHeader.tintColor = ColorConfiguration.defaultColorTosca
            }else if valueType.lowercased() == "audio" || valueType.lowercased() == "audios"{
                self.ivImageHeaderWidhtConst.constant = 14
                self.ivImageRightConst.constant = 5
                self.lbHeader.text = "Audio"
                self.ivImageHeader.image = UIImage(named: "ic_file_attachment")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                self.ivImageHeader.tintColor = ColorConfiguration.defaultColorTosca
            }else{
                self.ivImageHeaderWidhtConst.constant = 0
                self.ivImageRightConst.constant = 0
            }
        }
        
        if data.footer.isEmpty == true {
            self.heightViewFooterDeailConst.constant = 0
            self.viewFooterDetail.alpha = 0
        }else{
            self.heightViewFooterDeailConst.constant = 80
            self.viewFooterDetail.alpha = 1
            
            self.lbFooter.text = data.footer
        }
        
        if data.button.isEmpty == true {
            self.heightViewButtonConst.constant = 0
            self.viewButtonDetail.alpha = 0
        }else{
            let data = data.button
            let json = JSON.init(parseJSON: data)
            
            
            let buttonsPayload = json.arrayValue
            self.stackViewButtonHeightConst.constant = CGFloat(buttonsPayload.count * 30)
            
            for buttonsData in buttonsPayload{
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.stackViewButton.frame.size.width, height: 30))
                let type = buttonsData["type"].string ?? ""
                let title = buttonsData["button_text"].string ?? "-"
                if type.lowercased() == "url" {
                    button.setTitle(" Web Check in (\(title))", for: .normal)
                    button.setImage(UIImage(named: "ic_broadcast_link"), for: .normal)
                    button.imageView?.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
                    
                    self.lbButtonTop.text = "Button (Call to Action)"
                }else if type.lowercased() == "quick_reply"{
                    self.lbButtonTop.text = "Button (Quick Reply)"
                    button.setTitle(buttonsData["button_text"].string ?? "-", for: .normal)
                }else if type.lowercased() == "phone_number" {
                    button.setTitle(" Call CS (\(title))", for: .normal)
                    button.setImage(UIImage(named: "ic_broadcast_phone"), for: .normal)
                    button.imageView?.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
                    self.lbButtonTop.text = "Button (Call to Action)"
                }else{
                    self.lbButtonTop.text = "Button"
                    button.setTitle("\(title)", for: .normal)
                }
                
                button.setTitleColor(UIColor.black, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .light)
                button.tag = buttonCount
                //button.addTarget(self, action:#selector(self.postback(sender:)), for: .touchUpInside)
                self.stackViewButton.addArrangedSubview(button)
                self.buttonCount += 1
            }
            
            
            self.heightViewButtonConst.constant = CGFloat(51 + (self.buttonCount * 30))
            self.viewButtonDetail.alpha = 1
        }
        
    }


    @IBAction func actionCancel(_ sender: Any) {
        self.viewBgDetail.alpha = 0
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
        self.navigationController?.popViewController(animated: true)
    }
    
    func getListBroadCastHistory(){
        
        if self.noLoadMore == true {
           return
        }
        
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        let param = ["page": self.page,
                     "limit": 10,
            ] as [String : Any]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/customer_rooms/\(self.roomID)/broadcast_history", method: .get, parameters: param, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //error
                    
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getListBroadCastHistory()
                            } else {
                                return
                            }
                        }
                    }
                    
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    if let broadCastHistory = payload["data"]["broadcast_logs"].array {
                        if broadCastHistory.count == 0 {
                            self.noLoadMore = true
                            return
                        }
                        var results = [BroadCastHistoryModel]()
                        for dataBroadcast in broadCastHistory {
                            let data = BroadCastHistoryModel(json: dataBroadcast)
                            results.append(data)
                        }
                        self.dataBroadCastHistory.append(contentsOf: results)
                        
                         self.tableView.reloadData()
                        
                        let total = payload["meta"]["total"].int ?? 1
                        
                        self.totalBroadCastHistory = total
                        if self.dataBroadCastHistory.count < self.totalBroadCastHistory {
                             self.page += 1
                        }else{
                           self.noLoadMore = true
                        }
                        
                    }else {
                         self.noLoadMore = true
                    }
   
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.noLoadMore = true
            } else {
                //failed
                self.noLoadMore = true
            }
        }
    }

}


extension BroadcastHistoryVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataBroadCastHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailBroadcastHistoryCellIdentifire", for: indexPath) as! DetailBroadcastHistoryCell
        
        let data = self.dataBroadCastHistory[indexPath.row]
        cell.setupData(data: data)
        
        let loadMore = self.dataBroadCastHistory.count - 2
        
        if loadMore == indexPath.row {
            self.getListBroadCastHistory()
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.showDetail(data: self.dataBroadCastHistory[indexPath.row])
    }
}

