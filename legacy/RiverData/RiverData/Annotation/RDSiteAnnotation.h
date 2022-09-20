//
//  RDSiteAnnotation.h
//  RiverData
//
//  Created by Tim Kelly on 8/1/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface RDSiteAnnotation : NSObject<MKAnnotation>

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString *)title withSubtitle:(NSString *)subtitle;

@end
