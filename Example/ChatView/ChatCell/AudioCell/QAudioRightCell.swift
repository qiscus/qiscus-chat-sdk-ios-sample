//
//  QAudioLeftCell.swift
//  Qiscus
//
//  Created by asharijuang on 06/09/18.
//

import UIKit
import QiscusUI
import QiscusCore
import AVFoundation

class QAudioRightCell: QUIBaseChatCell {
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fileContainer: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var currentTImeSlider: UISlider!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var seekTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressImageView: UIImageView!
    var menuConfig = enableMenuConfig()
    var player: AVPlayer?
    var _timeFormatter: DateComponentsFormatter?
    var timeFormatter: DateComponentsFormatter? {
        get {
            if _timeFormatter == nil {
                _timeFormatter = DateComponentsFormatter()
                _timeFormatter?.zeroFormattingBehavior = .pad;
                _timeFormatter?.allowedUnits = [.minute, .second]
                _timeFormatter?.unitsStyle = .positional;
            }
            
            return _timeFormatter
        }
        
        set {
            _timeFormatter = newValue
        }
    }

    var isPlaying = false {
        didSet {
            self.playButton.removeTarget(nil, action: nil, for: .allEvents)
            if isPlaying {
                self.playButton.setImage(UIImage(named: "audio_pause"), for: UIControl.State())
                self.playButton.addTarget(self, action: #selector(pauseButtonTapped(_:)), for: .touchUpInside)
            } else {
                self.playButton.setImage(UIImage(named: "play_audio"), for: UIControl.State())
                self.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    @IBAction func slide(_ sender: Any) {
        player?.seek(to: CMTimeMake(value: Int64(currentTImeSlider.value), timescale: 1))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setMenu(forward: menuConfig.forward, info: menuConfig.info)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu(forward: menuConfig.forward, info: menuConfig.info)
        // Configure the view for the selected state
    }
    
    override func present(message: CommentModel) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    func bindData(message: CommentModel){
        self.setupBalon()
        self.status(message: message)
        self.dateLabel.text = self.comment?.hour()
        guard let payload = self.comment?.payload else { return }
        if let url = payload["url"] as? String {
            player = AVPlayer(url: URL(string: url)!)
            
            if let currentDuration = player?.currentItem?.asset.duration {
                let duration = Double(CMTimeGetSeconds(currentDuration))
                DispatchQueue.main.async {
                    autoreleasepool{
                        self.currentTImeSlider.maximumValue = Float(Int(duration))
                        if let durationString = self.timeFormatter?.string(from: duration) {
                            self.durationLabel.text = durationString
                        }
                    }
                }
            }
            
        }
       
        self.playButton.setImage(UIImage(named: "play_audio"), for: UIControl.State())
        self.playButton.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        
    }
    
    func status(message: CommentModel){
        
        switch message.status {
        case .deleted:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            dateLabel.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.rightBaloonTextColor
            dateLabel.text = TextConfiguration.sharedInstance.sendingText
            ivStatus.image = UIImage(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            dateLabel.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.image = UIImage(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            dateLabel.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            dateLabel.textColor = ColorConfiguration.rightBaloonTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            dateLabel.textColor = ColorConfiguration.failToSendColor
            dateLabel.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        }
    }
    
    func setupBalon(){
        self.balloonView.image = self.getBallon()
        self.balloonView.tintColor = ColorConfiguration.rightBaloonColor
    }
    
    func playUsingAVPlayer() {
        let activeCell = QUIBaseChatCell.self
        
        if let targetCell = activeCell as? QAudioLeftCell{
            targetCell.isPlaying = false
        }
        
        if let targetCell = activeCell as? QAudioRightCell{
            targetCell.isPlaying = false
        }
        
        if(player == nil){
             guard let payload = self.comment?.payload else { return }
            if let url = payload["url"] as? String {
                player = AVPlayer(url: URL(string: url)!)
                
            }
        }
        
        player?.play()
        
        let interval = CMTime(value: 1, timescale: 1)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            
            let seconds = Int(CMTimeGetSeconds(progressTime))
            let secondsString = String(format: "%02d", Int(seconds % 60))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            
           
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                
                self.currentTImeSlider.value = Float(Int(seconds))
                self.seekTimeLabel.text = "\(minutesString):\(secondsString)"
                if(self.currentTImeSlider.value == self.currentTImeSlider.maximumValue){
                    self.isPlaying = false
                    self.player = nil
                }
                
            }
            
        })
    }
    
}
extension QAudioRightCell {
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.seekTimeLabel.text = "00:00"
        self.currentTImeSlider.value = 0
        self.isPlaying = true
        DispatchQueue.main.async {
            autoreleasepool{
                self.playUsingAVPlayer()
            }
        }
    }
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        self.isPlaying = false
        DispatchQueue.main.async {
            autoreleasepool{
                self.player?.pause()
            }
        }
    }
    
    
}
