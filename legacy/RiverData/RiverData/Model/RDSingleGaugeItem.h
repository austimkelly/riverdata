//
//  RDSingleGaugeItem.h
//  RiverData
//
//  Created by Tim Myxer on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Model containing information on a single gauge from a single site. E.g. depth, or cfs */
@interface RDSingleGaugeItem : NSObject

- (id)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isValidData;

@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *timeSeriesId;
@property (strong, nonatomic) NSString *parentGaugeId;
@property (strong, nonatomic) NSString *unitAbbreviation;
@property (assign) double longitude;
@property (assign) double latitude;
@end
