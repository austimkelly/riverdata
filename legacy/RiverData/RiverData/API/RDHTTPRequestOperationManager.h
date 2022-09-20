//
//  RDHTTPRequestOperationManager.h
//  RiverData
//
//  Created by Tim Kelly on 4/26/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

// 3rd party
#import "AFHTTPRequestOperationManager.h"

@interface RDHTTPRequestOperationManager : AFHTTPRequestOperationManager

@property (readonly, nonatomic) BOOL hasCachedResponse;

@end
