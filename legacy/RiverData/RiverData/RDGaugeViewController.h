//
//  RDGaugeViewController.h
//  RiverData
//
//  Created by Tim Myxer on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDBaseViewController.h"
#import "RDGaugeModel.h"

@interface RDGaugeViewController : RDBaseViewController

- (void)refresh;

// Items that should be filled in by called view controller
@property (strong, nonatomic) NSArray *gaugeModelArray; // Array of RDGagueModel. Can be nil if all gauges should be fetched.
@property (strong, nonatomic) NSString *siteCode; // This should be filled in by the caller
@property (strong, nonatomic) NSString *naviTitle; // Title for this view controller

@end
