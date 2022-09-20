//
//  RDUserDefaults.h
//  RiverData
//
//  Created by Tim Kelly on 4/14/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDUserDefaults : NSObject

+ (void)setStartAppOnFavorites:(bool)startOnFavorites;
+ (void)setFilterNumericSites:(bool)filterNumericSites;

+ (bool)getStartAppOnFavorites;
+ (bool)getFilterNumericSites;

@end
