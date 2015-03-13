//
//  StringDrawingOptions.h
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 05.03.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StringDrawingOptions : NSObject

+ (NSStringDrawingOptions)combine:(NSStringDrawingOptions)option1 with:(NSStringDrawingOptions)option2;

@end
