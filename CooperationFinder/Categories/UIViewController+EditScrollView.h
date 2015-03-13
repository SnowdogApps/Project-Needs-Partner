//
//  UIViewController+EditScrollView.h
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 18.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (EditScrollView)

@property (nonatomic) CGPoint restorationContentOffset;
@property (nonatomic, weak) UIScrollView *scrollView;

- (void)moveUpForTextfield:(UITextField *)textField;
- (void)moveToOriginalPosition;

@end
