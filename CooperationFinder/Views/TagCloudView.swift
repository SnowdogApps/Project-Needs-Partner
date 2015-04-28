//
//  TagCloudView.swift
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 05.03.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

import UIKit

class TagCloudView: UIView {

    var tags : [String]? {
        didSet {
            self.reloadData()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    private var labels : [UILabel]? = []
    private var intrinsicSize : CGSize = CGSizeZero
    
    var font : UIFont?
    var textColor : UIColor = UIColor.whiteColor()
    var textBackgroundColor : UIColor = UIColor(red: 104.0/255.0, green: 104.0/255.0, blue: 104.0/255.0, alpha: 1.0)
    
    let kTagPadding : CGFloat = 8.0
    let kTagHorizontalMargin : CGFloat = 8.0
    let kTagVerticalMargin : CGFloat = 4.0;
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let labels = self.labels {
            var currentX = kTagHorizontalMargin
            var currentY = kTagVerticalMargin
            var totalRect : CGRect = CGRectZero
            
            for label in self.labels! {
                let size = self.labelSizeForLabel(label)
                if (currentX + size.width > self.frame.size.width) {
                    currentY = totalRect.size.height + kTagVerticalMargin
                    currentX = kTagHorizontalMargin
                }
                
                label.frame = CGRectMake(currentX, currentY, size.width, size.height)
                totalRect = CGRectUnion(totalRect, label.frame)
                currentX += (size.width + kTagHorizontalMargin)
            }
            totalRect.size.width += kTagVerticalMargin
            
            self.intrinsicSize = CGSizeMake(self.frame.size.width, totalRect.size.height)
            self.invalidateIntrinsicContentSize()
        }
        
        super.layoutSubviews()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return self.intrinsicSize
    }
    
    
    private func labelForTag(tag : String) -> UILabel {
        let label = UILabel()
        label.text = tag
        label.numberOfLines = 1
        label.textAlignment = NSTextAlignment.Center
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.backgroundColor = self.textBackgroundColor
        label.textColor = self.textColor
        label.font = self.font
        label.layer.cornerRadius = 4.0
        label.layer.masksToBounds = true
        
        return label
    }
    
    private func labelSizeForLabel(label: UILabel) -> CGSize {
        let maxSize = CGSizeMake(self.frame.size.width - 2 * kTagPadding - 2 * kTagHorizontalMargin, CGFloat.max)
        let textSize = label.attributedText.boundingRectWithSize(maxSize, options: StringDrawingOptions.combine(NSStringDrawingOptions.UsesFontLeading, with: NSStringDrawingOptions.UsesLineFragmentOrigin), context: nil)
        let labelSize = CGSizeMake(textSize.width + 2 * kTagPadding, textSize.height)
        return labelSize
    }
    
    private func removeOldSubviews() {
        let views = self.subviews as! [UIView]
        for view in views {
            view.removeFromSuperview()
        }
    }
    
    func reloadData() {
        
        if let tags = self.tags {
            
            self.removeOldSubviews()
            self.labels?.removeAll(keepCapacity: true)
            
            for tag in tags {
                let label = self.labelForTag(tag)
                self.addSubview(label)
                self.labels?.append(label)
                
            }
        }
    }
}



