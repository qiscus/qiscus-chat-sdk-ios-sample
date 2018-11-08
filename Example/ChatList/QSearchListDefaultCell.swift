//
//  QSearchListDefaultCell.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/20/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

import UIKit

class QSearchListDefaultCell: QSearchListCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setupUI() {
        //self.titleLabel.text = 
        
    }
    override func searchTextChanged() {
        let boldAttr = [NSAttributedStringKey.foregroundColor: UIColor.red,
                        NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14.0)]
        let normalAttr = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]
        
        let message = self.comment!.message
        let newLabelText = NSMutableAttributedString(string: message)
        let allRange = (message as NSString).range(of: message)
        newLabelText.setAttributes(normalAttr, range: allRange)
        
        
        if let matchRange: Range = message.lowercased().range(of: searchText.lowercased()) {
            
            let matchRangeStart: Int = message.distance(from: message.startIndex, to: matchRange.lowerBound)
            let matchRangeEnd: Int = message.distance(from: message.startIndex, to: matchRange.upperBound)
            let matchRangeLength: Int = matchRangeEnd - matchRangeStart
            
            newLabelText.setAttributes(boldAttr, range: NSMakeRange(matchRangeStart, matchRangeLength))
            
        }
        self.descriptionView.attributedText = newLabelText
    }
}
