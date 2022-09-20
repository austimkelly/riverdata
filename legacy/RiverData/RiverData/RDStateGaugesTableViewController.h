//
//  RDStateGaugesTableViewController.h
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RDSingleStateModel.h"

@interface RDStateGaugesTableViewController : UITableViewController

@property (strong, nonatomic) RDSingleStateModel *state;

@end
