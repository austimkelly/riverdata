//
//  RDUserDefaults.m
//  RiverData
//
//  Created by Tim Kelly on 4/14/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import "RDUserDefaults.h"

@implementation RDUserDefaults

#define KEY_START_ON_FAVS @"startOnFavs"
#define KEY_FILTER_NUMERIC_SITES @"filterNumericSites"

+ (void)setStartAppOnFavorites:(bool)startOnFavorites{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // to store
    [defaults setObject:[NSNumber numberWithBool:startOnFavorites] forKey:KEY_START_ON_FAVS];
    [defaults synchronize];
    
}

+ (void)setFilterNumericSites:(bool)filterNumericSites{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // to store
    [defaults setObject:[NSNumber numberWithBool:filterNumericSites] forKey:KEY_FILTER_NUMERIC_SITES];
    [defaults synchronize];
    
}

+ (bool)getStartAppOnFavorites{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool result = NO;
    // to load
    NSNumber *aNumber = [defaults objectForKey:KEY_START_ON_FAVS];
    if (aNumber != nil) result = [aNumber boolValue];
    
    return result;
}

+ (bool)getFilterNumericSites{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool result = NO;
    // to load
    NSNumber *aNumber = [defaults objectForKey:KEY_FILTER_NUMERIC_SITES];
    if (aNumber != nil) result = [aNumber boolValue];
    
    return result;
    
}

@end
