//
//  WaitingResolveALLExpiredWACell.swift
//  Example
//
//  Created by Qiscus on 08/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol WaitingResolveALLExpiredWACellDelegate{
    func cancelResolve(data : WAChannelResolveModel)
}

class WaitingResolveALLExpiredWACell: UITableViewCell {

    @IBOutlet weak var viewInProgress: UIView!
    @IBOutlet weak var btCancel: UIButton!
    @IBOutlet weak var totalRoom: UILabel!
    @IBOutlet weak var linearProgress: UIProgressView!
    @IBOutlet weak var customLinearProgressBar: LinearProgressBar!
    var mainVC : ResolvedALLWAVC? = nil
    var data : WAChannelResolveModel? = nil
    var delegate : WaitingResolveALLExpiredWACellDelegate? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        linearProgress.transform = linearProgress.transform.scaledBy(x: 1, y: 3)
        
        linearProgress.layer.cornerRadius = 4
        linearProgress.clipsToBounds = true
        linearProgress.layer.sublayers![1].cornerRadius = 4
        linearProgress.subviews[1].clipsToBounds = true
        
        self.totalRoom.text = "Total room will be resolved : 0"
        
        
        customLinearProgressBar.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        customLinearProgressBar.progressBarColor = ColorConfiguration.defaultColorTosca
        customLinearProgressBar.progressBarWidth = 10
        customLinearProgressBar.cornerRadius = 4
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(dataWAChannel : WAChannelResolveModel){
        self.data = dataWAChannel
        self.totalRoom.text = "Total room will be resolved : \(dataWAChannel.totalRooms)"
        customLinearProgressBar.startAnimating()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        if let data = self.data {
            data.inProgressResolve = false
            data.isWaiting = true
            if let delegate = self.delegate {
                self.delegate?.cancelResolve(data: data)
            }
        }
//        let vc = AlertResolveCancelationWAChannelVC()
//        vc.delegate = self
//        vc.modalPresentationStyle = .overFullScreen
//        
//        self.mainVC?.navigationController?.present(vc, animated: false, completion: {
//
//        })
    }
    
}

//extension WaitingResolveALLExpiredWACell : AlertResolveCancelationWAChannelDelegate {    
//    func actionCancelResolved(){
//        if let data = self.data {
//            data.inProgressResolve = false
//            data.isWaiting = true
//            if let delegate = self.delegate {
//                self.delegate?.cancelResolve(data: data)
//            }
//        }
//    }
//    
//    func actionDismiss(){
//        
//    }
//}
