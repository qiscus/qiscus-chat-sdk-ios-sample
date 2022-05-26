//
//  ResolveALLExpiredWACell.swift
//  Example
//
//  Created by Qiscus on 07/06/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit

protocol ResolveALLExpiredWACellDelegate{
    func inProgressResolve(data : WAChannelResolveModel, indexPath :  IndexPath)
}

class ResolveALLExpiredWACell: UITableViewCell {

    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var btResolve: UIButton!
    @IBOutlet weak var lbExpiredRoomCount: UILabel!
    @IBOutlet weak var lbChannelName: UILabel!
    var mainVC : ResolvedALLWAVC? = nil
    var data : WAChannelResolveModel? = nil
    var delegate : ResolveALLExpiredWACellDelegate? = nil
    var queque = 0
    var indexPosition = IndexPath(row: 0, section: 0)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func actionResolve(_ sender: Any) {
        
        let vc = AlertResolveWAChannelVC()
        vc.delegate = self
        vc.queque = self.queque
        vc.modalPresentationStyle = .overFullScreen
        
        self.mainVC?.navigationController?.present(vc, animated: false, completion: {

        })
    }
    
    func setupData(dataWAChannel : WAChannelResolveModel, indexPath: IndexPath){
        self.indexPosition = indexPath
        self.data = dataWAChannel
        self.lbChannelName.text = dataWAChannel.channelName
        self.lbExpiredRoomCount.text = "\(dataWAChannel.totalRooms)"
        
        if dataWAChannel.totalRooms == 0 {
            self.btResolve.isEnabled = false
            self.btResolve.setTitleColor(ColorConfiguration.defaultDisableResolve, for: .normal)
        }else{
            self.btResolve.isEnabled = true
            self.btResolve.setTitleColor(ColorConfiguration.defaultColorTosca, for: .normal)
        }
    }
    
}

extension ResolveALLExpiredWACell : AlertResolveWAChannelDelegate {
    func actionResolve(){
        if let data = self.data {
            data.inProgressResolve = true
            if let delegate = delegate {
                self.delegate?.inProgressResolve(data: data, indexPath: indexPosition)
            }
        }
    }
    
    func actionDismiss(){
        
    }
}


