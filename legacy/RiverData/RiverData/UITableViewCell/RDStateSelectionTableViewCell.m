//
//  RDStateSelectionTableViewCell.m
//  RiverData
//
//  Created by Tim Myxer on 5/30/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import "RDStateSelectionTableViewCell.h"

#define MARGIN 37

@implementation RDStateSelectionTableViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect cvf = self.contentView.frame;
//    self.imageView.frame = CGRectMake(0.0,
//                                      0.0,
//                                      cvf.size.height-1,
//                                      cvf.size.height-1);
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
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

@end
