//
//  RDGaugeModel.h
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Model to display a single monitoring site, e.g. Barton Creek at Lost Creek, Austin, TX */
@interface RDGaugeModel : NSObject

@property (strong, nonatomic) NSString *riverInternalName;
@property (strong, nonatomic) NSString *riverDisplayName;
@property (strong, nonatomic) NSNumber *latitute; // float
@property (strong, nonatomic) NSNumber *longitude; // float
@property (strong, nonatomic) NSString *siteId;
@property (strong, nonatomic) NSString *agencyCode;

@property (strong, nonatomic) NSString *gaugeId;
@property (strong, nonatomic) NSString *gaugeDescription;

- (id)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isValidModel;

@end
