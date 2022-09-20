//
//  RDSiteItemTableViewCell.m
//  RiverData
//
//  Created by Tim Kelly on 1/7/15.
//  Copyright (c) 2015 Tim Kelly. All rights reserved.
//

#import "RDSiteItemTableViewCell.h"

#define MARGIN 0

@implementation RDSiteItemTableViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.imageView.image != nil){
        
        CGRect cvf = self.contentView.frame;
        self.imageView.frame = CGRectMake(0.0,
                                          0.0,
                                          cvf.size.height-1,
                                          cvf.size.height-1);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRect frame = CGRectMake(cvf.size.height + MARGIN,
                                  self.textLabel.frame.origin.y,
                                  cvf.size.width - cvf.size.height - 2*MARGIN,
                                  self.textLabel.frame.size.height);
        self.textLabel.frame = frame;
        
        frame = CGRectMake(cvf.size.height + MARGIN,
                           self.detailTextLabel.frame.origin.y,
                           cvf.size.width - cvf.size.height - 2*MARGIN,
                           self.detailTextLabel.frame.size.height);
        self.detailTextLabel.frame = frame;
    }
}

@end
