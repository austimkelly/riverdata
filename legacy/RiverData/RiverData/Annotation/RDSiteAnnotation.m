//
//  RDSiteAnnotation.m
//  RiverData
//
//  Created by Tim Kelly on 8/1/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import "RDSiteAnnotation.h"

@interface RDSiteAnnotation ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString *siteSubtitle;
@property (strong, nonatomic) NSString *siteTitle;
@end

@implementation RDSiteAnnotation

@synthesize coordinate = _coordinate;
@synthesize siteSubtitle = _siteSubtitle;
@synthesize siteTitle = _siteTitle;

- (NSString *)subtitle{
	return self.siteSubtitle;
}

- (NSString *)title{
	return self.siteTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString *)title withSubtitle:(NSString *)subtitle{
    
    
    self.siteTitle = title;
    self.siteSubtitle = subtitle;
	self.coordinate = coordinate;
	return self;
}


@end
