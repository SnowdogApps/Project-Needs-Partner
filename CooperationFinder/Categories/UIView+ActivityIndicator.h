//
//  UIView+ActivityIndicator.h
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 04.09.2014.
//  Copyright (c) 2014 Snowdog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ActivityIndicator)

@property (nonatomic, strong) NSString *textToRestore;

- (void)addActivityIndicator;
- (void)addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)indicatorStyle;

- (void)removeActivityIndicator;

- (void)addIndicatorSubstitutingSubView:(UIView *)view;
- (void)removeIndicatorRevealingSubview:(UIView *)view;

@end
