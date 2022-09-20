//
//  TKGoogleAnalyticsUtil.h
//
//  Created by Tim Kelly on 5/30/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

// Macros based on v3.10 iOS SDK for Google Analytics
// See: https://developers.google.com/analytics/devguides/collection/ios/v3/
//
// You mileage may vary on other releases.
//
#import <Foundation/Foundation.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#define GA_INIT_TRACKER(ACCOUNT_NAME, ACCOUNT_ID, PERIOD) { \
[GAI sharedInstance].trackUncaughtExceptions = YES; \
[GAI sharedInstance].dispatchInterval = PERIOD; \
[[GAI sharedInstance] trackerWithName:ACCOUNT_NAME trackingId:ACCOUNT_ID]; \
}

// Track a object by its class name
#define GA_TRACK_CLASS GA_TRACK_PAGE(NSStringFromClass([self class]));

//#define GA_TRACK_METHOD(CATEGORY, ACTION, LABEL) [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:CATEGORY withAction:ACTION withLabel:LABEL withValue:0];

#define GA_TRACK_EVENT(CATEGORY, ACTION, LABEL, VALUE) \
id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker]; \
[tracker send:[[GAIDictionaryBuilder createEventWithCategory:CATEGORY action:ACTION label:LABEL value:VALUE] build]];

// Track a view by a user defined string
#define GA_TRACK_PAGE(PAGE) \
id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker]; \
[defaultTracker send:[[[GAIDictionaryBuilder createAppView] set:PAGE forKey:kGAIScreenName] build]];;


// Performance timing - When using performance timing be sure to first use
// GA_PERFORMANCE_START to enabel the timer
//  then use
// GA_PERFORMANCE_TIMER_STOP.
//      The first argument, REST_API_PREFIX, is the API prefix name you are invoking (without query parameters)
//      The second argument, PERFORMANCE_SUB_CATEGORY can be nil if there are subsets of the REST API you are using or specif query parameter values

#define GA_PERFORMANCE_TIMER_START NSDate *startTime = [NSDate date];

#define GA_PERFORMANCE_TIMER_STOP(PERFORMANCE_CATEGORY, NAME, LABEL) \
NSTimeInterval timeInterval = [startTime timeIntervalSinceNow]; \
id tracker = [[GAI sharedInstance] defaultTracker]; \
[tracker send:[[GAIDictionaryBuilder createTimingWithCategory:PERFORMANCE_CATEGORY interval:@((NSUInteger)(timeInterval * 1000)) name:NAME label:LABEL] build]];

