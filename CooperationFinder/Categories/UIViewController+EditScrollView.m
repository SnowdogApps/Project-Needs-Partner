//
//  UIViewController+EditScrollView.m
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 18.02.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

#import "UIViewController+EditScrollView.h"

@implementation UIViewController (EditScrollView)

@dynamic restorationContentOffset;
@dynamic scrollView;

- (void)moveUpForTextfield:(UITextField *)textField {
    self.restorationContentOffset = self.scrollView.contentOffset;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat textFieldOriginY = textField.frame.origin.y;
    contentOffset.y = (textFieldOriginY > 100) ? textFieldOriginY - 100 : contentOffset.y;
    self.scrollView.contentOffset = contentOffset;
    
    [UIView commitAnimations];
}

- (void)moveToOriginalPosition {
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentOffset = self.restorationContentOffset;
    }];
}

@end
