//
//  RDAppDelegate.h
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSArray *)fetchAllFavorites;
- (BOOL)isFavoritedSite:(NSString *)siteCode;
- (BOOL)removeFavoriteSite:(NSString *)siteCode;
- (BOOL)addFavroiteSite:(NSString *)siteCode withSiteName:(NSString *)name;
- (BOOL)updateDisplayName:(NSString *)displayName withSiteCode:(NSString *)siteCode;

@end
