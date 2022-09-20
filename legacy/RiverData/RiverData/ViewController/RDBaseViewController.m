//
//  RDBaseViewController.m
//  RiverData
//
//  Created by Tim Kelly on 5/26/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import "RDBaseViewController.h"
#import "TKGoogleAnalyticsUtil.h"

@interface RDBaseViewController ()


@end

@implementation RDBaseViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self layoutAnimated:NO];
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    

}

- (void)layoutAnimated:(BOOL)animated
{
    
    [_contentView layoutIfNeeded];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
