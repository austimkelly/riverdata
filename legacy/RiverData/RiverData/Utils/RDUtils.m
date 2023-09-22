//
//  RDUtils.m
//  RiverData
//
//  Created by Tim Kelly on 4/15/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import "RDUtils.h"

@implementation RDUtils

+ (BOOL)hasLeadingNumberInString:(NSString *)string{
    
    BOOL isNumericStart = NO;
    
    if (string)
        return [string length] && isnumber([string characterAtIndex:0]);
    
    
    return isNumericStart;
}

@end
