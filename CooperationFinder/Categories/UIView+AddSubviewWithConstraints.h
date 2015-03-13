//
//  UIView+AddSubviewWithConstraints.h
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 06.11.2014.
//  Copyright (c) 2014 Snowdog sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AddSubviewWithConstraints)

- (void)addSubviewFillingSuperview:(UIView *)subview;
- (void)addSubviewInCenter:(UIView *)subview;

@end
