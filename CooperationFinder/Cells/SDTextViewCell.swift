//
//  SDTextViewCell.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDTextViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
