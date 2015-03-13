//
//  UIView+AddSubviewWithConstraints.m
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 06.11.2014.
//  Copyright (c) 2014 Snowdog sp. z o.o. All rights reserved.
//

#import "UIView+AddSubviewWithConstraints.h"

@implementation UIView (AddSubviewWithConstraints)

- (void)addSubviewFillingSuperview:(UIView *)subview {
    [self addSubview:subview];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[subview]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(subview)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(subview)]];
}

- (void)addSubviewInCenter:(UIView *)subview {
    
    [self addSubview:subview];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterX
                                    multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.f constant:0.f]];
}

@end
