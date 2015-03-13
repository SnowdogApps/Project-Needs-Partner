//
//  SDTagsCell.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 09.03.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDTagsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagCloudView: TagCloudView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
