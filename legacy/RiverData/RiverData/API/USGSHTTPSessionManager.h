//
//  USGS_APIWrapper.h
//  RiverData
//
//  Created by Tim Kelly on 4/27/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

// 3rd Party
#import "AFHTTPSessionManager.h"

typedef void(^tFailureblock) (NSError *error);

@interface USGSHTTPSessionManager : AFHTTPSessionManager

+ (id)apiInstance;

- (void)fetchStateGauges:(NSString *)stateCode
  withFilterNumericSites:(BOOL)filterSiteNamesStartingWithNum
   withCompletionHandler:(void (^)(BOOL success, NSArray *gaugeModels))completionBlock
        withErrorHandler:(tFailureblock)errorBlock;


- (void)fetchAllGaugeDataForSiteId:(NSString *)siteId
                                      withGaugeIds:(NSArray *)gaugeIds
                             withCompletionHandler:(void (^)(BOOL success, NSArray *gaugeModels))completionBlock
                                  withErrorHandler:(tFailureblock)errorBlock;


@end
