//
//  RDPointAnnotation.h
//  RiverData
//
//  Created by Tim Kelly on 12/6/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RDPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) NSString *siteId;
@property (assign, nonatomic) NSInteger numGauges;
@property (strong, nonatomic) NSString *siteCode;

@end
