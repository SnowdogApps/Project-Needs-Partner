//
//  SDTwoButtonCell.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDTwoButtonCell: SDButtonCell {
    var secondaryButtonTapped: (() -> ())?

    @IBAction func secondaryButtonTapped(sender: UIButton) {
        if let secondaryBlock = secondaryButtonTapped {
            secondaryBlock()
        }
    }
}
