//
//  RDUtils.h
//  RiverData
//
//  Created by Tim Kelly on 4/15/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_FAVORITES_CHANGED @"FavoritesChanged"

@interface RDUtils : NSObject

+ (BOOL)hasLeadingNumberInString:(NSString *)string;

@end
