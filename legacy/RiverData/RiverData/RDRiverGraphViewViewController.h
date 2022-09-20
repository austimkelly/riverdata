//
//  RDRiverGraphViewViewController.h
//  RiverData
//
//  Created by Tim Myxer on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDBaseViewController.h"
#import "RDBaseViewController.h"
#import "RDSingleGaugeItem.h"
#import "RDGaugeModel.h"

@interface RDRiverGraphViewViewController : RDBaseViewController

@property (strong, nonatomic) NSString *siteName;
@property (strong, nonatomic) RDSingleGaugeItem *timeSeriesItem;

@end
