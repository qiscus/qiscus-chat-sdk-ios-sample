//
//  QUIBaseChatCell.swift
//  Pods
//
//  Created by asharijuang on 24/09/18.
//

import Foundation
import QiscusCore

class enableMenuConfig : NSObject {
    override init() {}
}

protocol UIBaseChatCellDelegate {
    func didTap(delete comment: CommentModel)
}

class UIBaseChatCell: UITableViewCell {
    // MARK: cell data source
    var comment: CommentModel? {
        set {
            self._comment = newValue
            if let data = newValue { present(message: data) } // bind data only
        }
        get {
            return self._comment
        }
    }
    private var _comment : CommentModel? = nil
    var indexPath: IndexPath!
    var firstInSection: Bool = false
    var cellMenu : UIBaseChatCellDelegate? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    func present(message: CommentModel) {
        preconditionFailure("this func must be override, without super")
    }
    
    func update(message: CommentModel) {
        preconditionFailure("this func must be override, without super")
    }
    
    /// configure ui element when init cell
    func configureUI() {
        // MARK: configure long press on cell
        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        self.selectionStyle = .none
    }
}

extension UIBaseChatCell {
    
    var textAttribute:[NSAttributedString.Key: Any]{
        get{
            var foregroundColorAttributeName = ColorConfiguration.leftBaloonTextColor
            return [
                NSAttributedString.Key.foregroundColor: foregroundColorAttributeName,
                NSAttributedString.Key.font: ChatConfig.chatFont
            ]
        }
    }
    
    var linkTextAttributes:[NSAttributedString.Key: Any]{
        get{
            var foregroundColorAttributeName = ColorConfiguration.leftBaloonLinkColor
            var underlineColorAttributeName = ColorConfiguration.leftBaloonLinkColor
            return [
                NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): foregroundColorAttributeName,
                NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineColor.rawValue): underlineColorAttributeName,
                NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue): NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): ChatConfig.chatFont
            ]
        }
    }
    
    func setMenu() {
        
        let delete = UIMenuItem(title: "Delete", action: #selector(deleteComment(_:)))
        
        var menuItems: [UIMenuItem] = [UIMenuItem]()
        if let myComment = self.comment?.isMyComment() {
            if(myComment){
                menuItems.append(delete)
                UIMenuController.shared.menuItems = menuItems
            }else{
                //UIMenuController.shared.menuItems = [reply,share,forwardMessage,deleteForMe]
                UIMenuController.shared.menuItems = menuItems
            }
            
            UIMenuController.shared.update()
        }
        
    }
    
    @objc func deleteComment(_ send:AnyObject){
        guard let _comment = self.comment else { return }
        self.cellMenu?.didTap(delete: _comment)
    }
}

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}



