//
//  SDButtonCell.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDButtonCell: UITableViewCell {
    var mainButtonTapped: (() -> ())?
    
    @IBAction func buttonTapped(sender: UIButton) {
        if let buttonBlock = mainButtonTapped {
            buttonBlock()
        }
    }
}
