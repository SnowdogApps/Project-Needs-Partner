//
//  UIView+ActivityIndicator.m
//  CooperationFinder
//
//  Created by Radoslaw Szeja on 04.09.2014.
//  Copyright (c) 2014 Snowdog. All rights reserved.
//

#import "UIView+ActivityIndicator.h"
#import <objc/runtime.h>

#define INDICATOR_TAG 999

@implementation UIView (ActivityIndicator)

- (CGFloat)animationDuration
{
    return 0.25;
}

- (void)addActivityIndicator
{
    [self addActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

- (void)addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)indicatorStyle
{
    NSString *currentTitle;
    
    if ([self respondsToSelector:@selector(currentTitle)]) {
        currentTitle = [self valueForKey:@"currentTitle"];
    } else {
        currentTitle = objc_getAssociatedObject(self, @"currentTitle");
    }

    self.textToRestore = currentTitle;
    [self setCurrentTitle:@""];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.height/2, 0, self.frame.size.height, self.frame.size.height)];
    
    indicator.alpha = 0.0;
    indicator.activityIndicatorViewStyle = indicatorStyle;
    [indicator setTag:INDICATOR_TAG];
    [indicator startAnimating];
    [self setUserInteractionEnabled:NO];
    [self addSubview:indicator];
    [indicator startAnimating];
    
    [UIView animateWithDuration:[self animationDuration]
                     animations:^{
                         indicator.alpha = 1.0;
                     }];
}

- (void)addIndicatorSubstitutingSubView:(UIView *)view
{
    NSString *currentTitle;
    
    if ([self respondsToSelector:@selector(currentTitle)]) {
        currentTitle = [self valueForKey:@"currentTitle"];
    } else {
        currentTitle = objc_getAssociatedObject(self, @"currentTitle");
        objc_setAssociatedObject(self, @"currentTitle", @"", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    self.textToRestore = currentTitle;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:view.frame];
    
    indicator.alpha = 0.0;
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    indicator.tag = INDICATOR_TAG;
    [indicator startAnimating];
    [self setUserInteractionEnabled:NO];
    [self addSubview:indicator];
    [indicator startAnimating];
    
    [UIView animateWithDuration:[self animationDuration]
                     animations:^{
                         indicator.alpha = 1.0;
                         view.alpha = 0.0;
                     }];
}

- (void)removeIndicatorRevealingSubview:(UIView *)view
{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:INDICATOR_TAG];
    
    if (indicator != nil) {
        [UIView animateWithDuration:[self animationDuration]
                         animations:^{
                             indicator.alpha = 0.0;
                             view.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             [indicator removeFromSuperview];
                             [indicator stopAnimating];
                             [self setUserInteractionEnabled:YES];
                             
                             NSString *currentTitle;
                             if ([self respondsToSelector:@selector(currentTitle)]) {
                                 currentTitle = [self valueForKey:@"currentTitle"];
                             } else {
                                 currentTitle = [self textToRestore];
                             }
                             
                             [self setCurrentTitle:currentTitle];
                         }];
    }
}

- (void)removeActivityIndicator
{
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[self viewWithTag:INDICATOR_TAG];
    
    if (indicator != nil) {
        [UIView animateWithDuration:[self animationDuration]
                         animations:^{
                             indicator.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [indicator removeFromSuperview];
                             [indicator stopAnimating];
                             [self setUserInteractionEnabled:YES];
                             
                             NSString *currentTitle = self.textToRestore;
                             [self setCurrentTitle:currentTitle];
                         }];
    }
}

- (void)setCurrentTitle:(NSString *)title {
    if ([self isKindOfClass:[UIButton class]] && [self respondsToSelector:@selector(setTitle:forState:)]) {
        [(id)self setTitle:title forState:UIControlStateNormal];
    } else {
        objc_setAssociatedObject(self, @"currentTitle", title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)textToRestore {
    return objc_getAssociatedObject(self, @"textToRestore");
}

- (void)setTextToRestore:(NSString *)textToRestore {
    objc_setAssociatedObject(self, @"textToRestore", textToRestore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
