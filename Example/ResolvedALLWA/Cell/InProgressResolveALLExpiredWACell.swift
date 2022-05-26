//
//  InProgressResolveALLExpiredWACell.swift
//  Example
//
//  Created by Qiscus on 08/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol InProgressResolveALLExpiredWACellDelegate{
    func cancelResolveInProgress(data : WAChannelResolveModel, indexPath : IndexPath)
    func updateStatusResolve(data : WAChannelResolveModel, indexPath : IndexPath)
}

class InProgressResolveALLExpiredWACell: UITableViewCell {

    @IBOutlet weak var viewInProgress: UIView!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var lbFailed: UILabel!
    @IBOutlet weak var lbSuccess: UILabel!
    @IBOutlet weak var totalRoom: UILabel!
    @IBOutlet weak var linearProgress: UIProgressView!
    var mainVC : ResolvedALLWAVC? = nil
    var data : WAChannelResolveModel? = nil
    var delegate : InProgressResolveALLExpiredWACellDelegate? = nil
    var indexPosition = IndexPath(row: 0, section: 0)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        linearProgress.transform = linearProgress.transform.scaledBy(x: 1, y: 3)
        
        linearProgress.progressTintColor = ColorConfiguration.defaultColorTosca
        linearProgress.layer.cornerRadius = 4
        linearProgress.clipsToBounds = true
        linearProgress.layer.sublayers![1].cornerRadius = 4
        linearProgress.subviews[1].clipsToBounds = true
        
        
        self.totalRoom.text = "Total room will be resolved : 0"
        self.lbSuccess.text = "Success : 0"
        self.lbFailed.text = "Failed : 0"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(dataWAChannel : WAChannelResolveModel, indexPath : IndexPath){
        self.indexPosition = indexPath
        self.data = dataWAChannel
        self.totalRoom.text = "Total room will be resolved : \(dataWAChannel.totalRooms)"
        
        self.lbFailed.text = "Failed : \(dataWAChannel.progressFailed)"
        self.lbSuccess.text = "Success : \(dataWAChannel.progressSuccess)"
        
        if dataWAChannel.progressProcessed != 0 || dataWAChannel.progressTotal != 0 {
            self.linearProgress.progress = Float(( dataWAChannel.progressProcessed / dataWAChannel.progressTotal ))
        }
       
        if dataWAChannel.progressStatus.isEmpty {
            //api post
            self.linearProgress.progress = 0.0
           
            self.postResolve()
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                if let delegate = self.delegate {
//                    if let data = self.data {
//                        data.totalRooms = 0
//                        data.progressStatus = "finished"
//                        data.isWaiting = false
//                        data.inProgressResolve = false
//                        delegate.updateStatusResolve(data: data, indexPath : self.indexPosition)
//                    }
//                }
//            }
            
        }else{
            //get
            self.getResolve()
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                if let delegate = self.delegate {
//                    if let data = self.data {
//                        data.totalRooms = 0
//                        data.progressStatus = "finished"
//                        data.isWaiting = false
//                        data.inProgressResolve = false
//                        delegate.updateStatusResolve(data: data, indexPath : self.indexPosition)
//                    }
//                }
//            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        let vc = AlertResolveCancelationWAChannelVC()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        
        self.mainVC?.navigationController?.present(vc, animated: false, completion: {

        })
    }
    
    func postResolve(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/bulk_resolve/wa/\(self.data?.channelId ?? 0)", method: .post, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.postResolve()
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
                    let progress = json["data"]["progress"]
                    
                    let progressStatus = progress["status"].string ?? ""
                    let progressFailed = progress["failed"].int ?? 0
                    let progressSuccess = progress["success"].int ?? 0
                    let progressProcessed = progress["processed"].int ?? 0
                    let progressTotal = progress["total"].int ?? 0
                    let totalRoom = json["data"]["total_rooms"].int ?? 0
                    
                    self.lbFailed.text = "Failed : \(progressFailed)"
                    self.lbSuccess.text = "Success : \(progressSuccess)"
                    
                    self.data?.progressStatus = progressStatus
                    self.data?.progressTotal = progressTotal
                    self.data?.progressFailed = progressFailed
                    self.data?.progressProcessed = progressProcessed
                    self.data?.progressSuccess = progressSuccess
                    self.data?.totalRooms = totalRoom
                    
                    
                    if let delegate = self.delegate {
                        if let data = self.data {
                            delegate.updateStatusResolve(data: data, indexPath : self.indexPosition)
                        }
                    }
                    
                    self.linearProgress.progress = Float(( progressProcessed / progressTotal ))
                    
                    self.getResolve()
                   
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func getResolve(){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/bulk_resolve/wa/\(self.data?.channelId ?? 0)", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.getResolve()
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
                    
                    let progress = json["data"]["progress"]
                    
                    let progressStatus = progress["status"].string ?? ""
                    let progressFailed = progress["failed"].int ?? 0
                    let progressSuccess = progress["success"].int ?? 0
                    let progressProcessed = progress["processed"].int ?? 0
                    let progressTotal = progress["total"].int ?? 0
                    let totalRoom = json["data"]["total_rooms"].int ?? 0
                    
                    self.lbFailed.text = "Failed : \(progressFailed)"
                    self.lbSuccess.text = "Success : \(progressSuccess)"
                    
                    self.data?.totalRooms = totalRoom
                    self.data?.progressStatus = progressStatus
                    self.data?.progressTotal = progressTotal
                    self.data?.progressFailed = progressFailed
                    self.data?.progressProcessed = progressProcessed
                    self.data?.progressSuccess = progressSuccess
                    
                    if progressProcessed != 0 || progressTotal != 0 {
                        self.linearProgress.progress = Float(( progressProcessed / progressTotal ))
                    }
                    
                    if let delegate = self.delegate {
                        if let data = self.data {
                            delegate.updateStatusResolve(data: data, indexPath : self.indexPosition)
                            
                            if progressStatus.lowercased() != "finished" {
                                self.getResolve()
                            }
                        }
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
}

extension InProgressResolveALLExpiredWACell : AlertResolveCancelationWAChannelDelegate {
    func actionCancelResolved(){
        //call api first
        
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/admin/bulk_resolve/wa/\(self.data?.channelId ?? 0)/abort", method: .post, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                return
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
                    let totalRoom = json["data"]["total_rooms"].int ?? 0
                    
                    self.data?.progressStatus = ""
                    self.data?.progressTotal = 0
                    self.data?.progressFailed = 0
                    self.data?.progressProcessed = 0
                    self.data?.progressSuccess = 0
                    self.data?.totalRooms = totalRoom
                    self.data?.isWaiting = true
                    self.data?.inProgressResolve = false
                    
                    //after call api
                    if let data = self.data {
                        if let delegate = self.delegate {
                            self.delegate?.cancelResolveInProgress(data: data, indexPath: self.indexPosition)
                        }
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
            } else {
                //failed
            }
        }
    }
    
    func actionDismiss(){
        
    }
}
