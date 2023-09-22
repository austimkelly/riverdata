//
//  RDSiteMapViewViewController.h
//  RiverData
//
//  Created by Tim Kelly on 12/4/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import "RDBaseViewController.h"

@interface RDSiteMapViewViewController : RDBaseViewController

/** When set on the view controller, this value will be used to see the DataReader class and only return annotations for the provided state. */
@property (strong, nonatomic) NSString *filterOnTwoLetterStateCode;

@end
