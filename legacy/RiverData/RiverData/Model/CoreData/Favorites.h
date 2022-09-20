//
//  Favorites.h
//  RiverData
//
//  Created by Tim Kelly on 7/22/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorites : NSManagedObject

@property (nonatomic, retain) NSString * siteCode;
@property (nonatomic, retain) NSString * internalName;
@property (nonatomic, retain) NSString * displayName;

@end
