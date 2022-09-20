//
//  RDSiteMapViewController.h
//  RiverData
//
//  Created by Tim Kelly on 8/1/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import "RDBaseViewController.h"
#import "RDSingleGaugeItem.h"

@interface RDSiteMapViewController : RDBaseViewController

@property (strong, nonatomic) RDSingleGaugeItem *firstGauge; // get basic info about site, like long/lat
@property (strong, nonatomic) NSString *riverName;

@end
