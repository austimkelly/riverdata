//
//  USGS_APIWrapper.m
//  RiverData
//
//  Created by Tim Kelly on 4/27/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import "USGSHTTPSessionManager.h"
#import "RDGaugeModel.h"
#import "RDUtils.h"
#import "RDSingleGaugeItem.h"

#define USGS_API_ROOT @"http://waterservices.usgs.gov/nwis/iv/"

@implementation USGSHTTPSessionManager

+ (id)apiInstance{
    
    static dispatch_once_t once;
    static  USGSHTTPSessionManager *_sharedUSGSHTTPClient = nil;
    dispatch_once(&once, ^{
        
        _sharedUSGSHTTPClient = [[super alloc] initWithBaseURL:[NSURL URLWithString:USGS_API_ROOT]];
        
    });
    
    return _sharedUSGSHTTPClient;
}


- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (!cachedResponse) {
        NSLog(@"Cache MISS");
        //_hasCachedResponse = NO;
    } else {
        NSLog(@"Cache HIT");
        //_hasCachedResponse = YES;
    }
    
    return [super GET:URLString parameters:parameters success:success failure:failure];
    
}


- (void)fetchStateGauges:(NSString *)stateCode
                  withFilterNumericSites:(BOOL)filterSiteNamesStartingWithNum
                   withCompletionHandler:(void (^)(BOOL success, NSArray *gaugeModels))completionBlock
                        withErrorHandler:(tFailureblock)errorBlock{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:stateCode, @"stateCd",  @"json", @"format", nil];
    
    [self GET:USGS_API_ROOT parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // error
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
    
    if (gaugeIdsParam){
        RDLog(@"GET: %@?format=json&sites=%@&parameterCd=%@", USGS_API_ROOT, siteId, gaugeIdsParam);
    } else {
        RDLog(@"GET: %@?format=json&sites=%@", USGS_API_ROOT, siteId);
    }

    [self GET:USGS_API_ROOT parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
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
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // error
        completionBlock(NO, nil);
        errorBlock(error);
    }];
    
    
}


@end
