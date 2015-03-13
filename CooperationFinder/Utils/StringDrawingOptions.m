//
//  StringDrawingOptions.m
//  CooperationFinder
//
//  Created by Rafal Kwiatkowski on 05.03.2015.
//  Copyright (c) 2015 Snowdog. All rights reserved.
//

#import "StringDrawingOptions.h"

@implementation StringDrawingOptions

+ (NSStringDrawingOptions)combine:(NSStringDrawingOptions)option1 with:(NSStringDrawingOptions)option2 {
    return option1 | option2;
}

@end
