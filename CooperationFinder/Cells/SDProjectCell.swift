//
//  SDProjectCell.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDProjectCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var projectNameLabel: UILabel?
    @IBOutlet weak var dateLabel: SDBadgeLabel?
    @IBOutlet weak var commercialLabel: SDBadgeLabel?
    @IBOutlet weak var trustedLabel: SDBadgeLabel?
    @IBOutlet weak var trustedView: UIView?
    @IBOutlet weak var statusLabel : UILabel?
    @IBOutlet weak var statusIcon : UIImageView?
    
    var trusted: Bool?
    var commercial: Bool?
    
    override func layoutSubviews() {
        
        if let _trusted = trusted {
            var color = UIColor(red: 243/255.0, green: 143/255.0, blue: 39/255.0, alpha: 1.0)
            trustedLabel?.text = "trusted".uppercaseString
            trustedLabel?.fillColor = color
            trustedView?.backgroundColor = color
            trustedView?.hidden = false
        } else {
            trustedView?.hidden = true
            trustedLabel?.hidden = true
        }
        
        if commercial == true {
            commercialLabel?.hidden = false
            commercialLabel?.text = NSLocalizedString("commercial", comment:"").uppercaseString
        } else {
            commercialLabel?.hidden = true
        }
        
        super.layoutSubviews()
    }
}
