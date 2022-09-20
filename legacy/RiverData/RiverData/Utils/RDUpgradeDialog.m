//
//  RDUpgradeDialog.m
//  RiverData
//
//  Created by Tim Kelly on 1/6/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import "RDUpgradeDialog.h"
#import "TKGoogleAnalyticsUtil.h"

// 3rd Party
#import "UIAlertView+Blocks.h"

@implementation RDUpgradeDialog

+ (void)showUpgradeDialogWithMessage:(NSString *)message;{
    
    [UIAlertView showConfirmationDialogWithTitle:@"Upgrade to the full version of River Data?" message:message handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        // upgrade
        if (buttonIndex == 1){
            
            GA_TRACK_EVENT(@"Upgrade", @"Yes", message, nil);
            
            NSURL *rdURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/river-data/id552825440?mt=8"];
            
            [[UIApplication sharedApplication] openURL:rdURL];
            
        } else {
            
            GA_TRACK_EVENT(@"Upgrade", @"No", message, nil);
            
        }
    }];
    
}

@end
