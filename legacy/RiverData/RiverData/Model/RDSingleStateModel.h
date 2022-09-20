//
//  RDSingleStateModel.h
//  RiverData
//
//  Created by Tim Myxer on 5/26/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Model for a single state supported by the river data app */
@interface RDSingleStateModel : NSObject

@property (nonatomic, readonly) NSString *twoLetterCode; // Two letter state abbreviation
@property (nonatomic, readonly) NSString *displayName;   //
@property (nonatomic, readonly) UIImage *thumb;

// Initialize the model
- (id)initStateWithDisplayName:(NSString *)displayName withCharCode:(NSString *)charCode withThumbNail:(UIImage *)thumb;

@end
