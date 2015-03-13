//
//  SDApplicationCell.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 10.03.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDApplicationCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
