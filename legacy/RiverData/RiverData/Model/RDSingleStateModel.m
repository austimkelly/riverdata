//
//  RDSingleStateModel.m
//  RiverData
//
//  Created by Tim Myxer on 5/26/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import "RDSingleStateModel.h"

@implementation RDSingleStateModel

@synthesize displayName = _displayName, thumb = _thumb, twoLetterCode = _twoLetterCode;

- (id)initStateWithDisplayName:(NSString *)displayName withCharCode:(NSString *)charCode withThumbNail:(UIImage *)thumb{
    
    self = [super init];
    
    _displayName = displayName;
    _twoLetterCode = charCode;
    _thumb = thumb;
    
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@:%@", self.displayName, self.twoLetterCode];
}

@end
