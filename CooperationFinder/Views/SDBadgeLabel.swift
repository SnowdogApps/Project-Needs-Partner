//
//  SDBadgeLabel.swift
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 26.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class SDBadgeLabel: UILabel {
    var fillColor: UIColor = UIColor(red: 12/255.0, green: 30/255.0, blue: 18/255.0, alpha: 1.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        backgroundColor = fillColor
    }

    
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let rect = self.attributedText.boundingRectWithSize(CGSizeMake(999, 999), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let newRect = CGRectInset(rect, -9.0, 0)
        return newRect
    }

}
