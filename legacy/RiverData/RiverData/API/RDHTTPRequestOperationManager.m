//
//  RDHTTPRequestOperationManager.m
//  RiverData
//
//  Created by Tim Kelly on 4/26/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import "RDHTTPRequestOperationManager.h"

@interface RDHTTPRequestOperationManager ()

@end

@implementation RDHTTPRequestOperationManager

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (!cachedResponse) {
        NSLog(@"No Cache response");
        _hasCachedResponse = NO;
    } else {
        NSLog(@"Cache response");
        _hasCachedResponse = YES;
    }
    
    return [super GET:URLString parameters:parameters success:success failure:failure];
    
}


@end
