//
//  USGS_APIWrapper.m
//  RiverData
//
//  Created by Tim Kelly on 4/27/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import "USGS_APIWrapper.h"
#import "RDHTTPRequestOperationManager.h"
#import "RDGaugeModel.h"
#import "RDUtils.h"
#import "RDSingleGaugeItem.h"

#define USGS_API_ROOT @"http://waterservices.usgs.gov/nwis/iv/"

@implementation USGS_APIWrapper

+ (id)apiInstance{
    
    static dispatch_once_t once;
    static  id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


- (void)fetchStateGauges:(NSString *)stateCode
                  withFilterNumericSites:(BOOL)filterSiteNamesStartingWithNum
                   withCompletionHandler:(void (^)(BOOL success, NSArray *gaugeModels))completionBlock
                        withErrorHandler:(tFailureblock)errorBlock{
    
    RDHTTPRequestOperationManager *apiManager = [RDHTTPRequestOperationManager manager];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:stateCode, @"stateCd",  @"json", @"format", nil];
    
    [apiManager GET:USGS_API_ROOT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        // success
        
        NSDictionary *JSON = responseObject;
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        
        NSArray *timeSeries = [[JSON objectForKey:@"value"] objectForKey:@"timeSeries"];
        
        if (timeSeries){
            
            for (NSDictionary *dict in timeSeries){
                
                RDGaugeModel *gaugeInfo = [[RDGaugeModel alloc] initWithDictionary:dict];
                
                if (filterSiteNamesStartingWithNum && [RDUtils hasLeadingNumberInString:gaugeInfo.riverDisplayName]){
                    continue;
                }
                
                if (gaugeInfo && [gaugeInfo isValidModel]){
                    
                    // Check and see if this gauge is already in the rivers dictionary
                    NSMutableArray *gaugeArray = [resultDict objectForKey:gaugeInfo.riverDisplayName];
                    
                    if (gaugeArray != nil){
                        
                        [gaugeArray addObject:gaugeInfo];
                        
                    } else {
                        
                        gaugeArray = [NSMutableArray array];
                        [gaugeArray addObject:gaugeInfo];
                    }
                    
                    [resultDict setObject:gaugeArray forKey:gaugeInfo.riverDisplayName];
                    
                } else {
                    if (gaugeInfo)
                        RDLog(@"INVALID MODEL: %@", gaugeInfo.description);
                }
                
            }
            
        }
        
        RDLog(@"River Names: %@", [resultDict allKeys]);
        
        NSArray *sortedKeys = [[resultDict allKeys] sortedArrayUsingSelector: @selector(compare:)];
        NSMutableArray *sortedValues = [NSMutableArray array];
        for (NSString *key in sortedKeys)
            [sortedValues addObject: [resultDict objectForKey:key]];
        
        
        completionBlock(YES, [NSArray arrayWithArray:sortedValues]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // failure
        completionBlock(NO, nil);
        errorBlock(error);
    }];
    
}


- (void)fetchAllGaugeDataForSiteId:(NSString *)siteId
                      withGaugeIds:(NSArray *)gaugeIds
             withCompletionHandler:(void (^)(BOOL success, NSArray *gaugeModels))completionBlock
                  withErrorHandler:(tFailureblock)errorBlock{
    
    NSString *gaugeIdsParam = nil;
    
    if (gaugeIds != nil && [gaugeIds count] > 0) {
        
        gaugeIdsParam = @"";
        
        for (NSString *siteId in gaugeIds){
            
            if ([gaugeIdsParam length] > 0){
                gaugeIdsParam = [gaugeIdsParam stringByAppendingString:@","];
            }
            
            gaugeIdsParam = [gaugeIdsParam stringByAppendingString:siteId];
            
        }
        
    }
    
    NSDictionary *params  = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"json", @"format", siteId, @"sites",  nil];
    if (gaugeIds != nil && [gaugeIds count] > 0){
        [params setValue:gaugeIdsParam forKey:@"parameterCd"];
    }
    
    RDHTTPRequestOperationManager *apiManager = [RDHTTPRequestOperationManager manager];
    
    if (gaugeIdsParam){
        RDLog(@"GET: %@?format=json&sites=%@&parameterCd=%@", USGS_API_ROOT, siteId, gaugeIdsParam);
    } else {
        RDLog(@"GET: %@?format=json&sites=%@", USGS_API_ROOT, siteId);
    }

    
    [apiManager GET:USGS_API_ROOT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // success
        NSDictionary *JSON = responseObject;
        
        NSMutableArray *resultArray = [NSMutableArray array];
        
        NSArray *timeSeries = [[JSON objectForKey:@"value"] objectForKey:@"timeSeries"];
        
        for (NSDictionary *timeSeriesDict in timeSeries){
            
            RDSingleGaugeItem *gaugeItem = [[RDSingleGaugeItem alloc] initWithDictionary:timeSeriesDict];
            
            if (gaugeItem && [gaugeItem isValidData]){
                
                [resultArray addObject:gaugeItem];
                
            }
        }
        
        completionBlock(YES, resultArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // error
        
    }];
    
    
}


@end
