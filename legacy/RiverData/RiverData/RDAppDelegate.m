//
//  RDAppDelegate.m
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "RDAppDelegate.h"
#import "TKGoogleAnalyticsUtil.h"
#import "Favorites.h"
#import "UIColor+RDColor.h"
#import "RDUserDefaults.h"
#import "RDGaugeViewController.h"

#define FAVORITES_ENTITY @"Favorites"

#define ATTRIB_SITE_ID @"siteCode"
#define ATTRIB_SITE_NAME @"internalName"
#define ATTRIB_SITE_DISPLAY_NAME @"displayName"

@implementation RDAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
#ifdef IS_LITE
    GA_INIT_TRACKER(@"River Data Lite", @"UA-41719370-3", 60)
#else
    GA_INIT_TRACKER(@"RiverData", @"UA-41719370-1", 60)
#endif
    
    [self initFavorites];
    
    [[UITabBar appearance] setTintColor:[UIColor riverDataMustard]];
    //[[UITabBar appearance] setBarTintColor:[UIColor riverDataMaroon]];
    
#ifdef IS_LITE
    [Crashlytics startWithAPIKey:@"0f5be543cf45e4478a97563de3ca80edb38aeba9"];
#else
    [Crashlytics startWithAPIKey:@"0f5be543cf45e4478a97563de3ca80edb38aeba9"];
#endif
    
    [self setDefaultTab];
    
    return YES;
}

- (void)setDefaultTab{
    
    if ([RDUserDefaults getStartAppOnFavorites]){
        UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
        tabBar.selectedIndex = 1;
    }
    
}

- (void)initFavorites{
    
    NSString *key = @"didV1FavoritesConvert";
    
    BOOL didUpdateV1Favorites = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    
    if (didUpdateV1Favorites){
        return;
    }
    
    NSArray *favsArrayV2 = [self fetchAllFavorites];
    
    if (favsArrayV2 == nil || [favsArrayV2 count] == 0) {
        
        // No favorites found, try to convert
        [self convertV1PropertyList];
        
    } 
    
    // Set that we tried the v1 favorites convert so we don't do it again
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:key];
    [userDefaults synchronize];
    
}

- (Favorites *)fetchFavoriteForSiteCode:(NSString *)siteCode{
    
    NSError *error = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:FAVORITES_ENTITY inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K MATCHES %@", ATTRIB_SITE_ID, siteCode];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    Favorites *favorite = nil;
    if (fetchedObjects != nil && [fetchedObjects count] > 0){
        favorite = [fetchedObjects objectAtIndex:0];
    }
    
    return favorite;
    
}

/** Get an array of Favorite objects from our Favorites entity
    These favorites come from v2 (managed objects) 
 
 @return An array of Favorite objects 
 */
- (NSArray *)fetchAllFavorites{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:FAVORITES_ENTITY];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error != nil){
        NSLog(@"ERROR: %@", error.localizedDescription);
    }
    
    return results;
    
}

- (BOOL)isFavoritedSite:(NSString *)siteCode{
    
    BOOL isFavorite = NO;
    
    NSArray *favorites = [self fetchAllFavorites];
    
    if (favorites != nil && [favorites count] > 0){
        
        for (Favorites *fav in favorites){
            if ([fav.siteCode isEqualToString:siteCode]){
                isFavorite = YES;
                break;
            }
        }
        
    }
    
    return isFavorite;
}

- (BOOL)removeFavoriteSite:(NSString *)siteCode{
    
    BOOL success = YES;
    
    // TODO: Do work
    if (![self isFavoritedSite:siteCode]){
        return success; // This is not a favorite so there's notthing to remove, ignore
    }
    
    Favorites *fav = [self fetchFavoriteForSiteCode:siteCode];
    
    if (fav){
        
        NSError *error = nil;
        NSManagedObjectContext *context = [self managedObjectContext];
        
        [context deleteObject:fav];
        
        if (![context save:&error]) {
            NSLog(@"ERROR, couldn't save after deleting object: %@", [error localizedDescription]);
            success = NO;
        }
        
    }
    
    return success;
}

- (BOOL)addFavroiteSite:(NSString *)siteCode withSiteName:(NSString *)name{
    
    BOOL success = YES;
    
    if ([self isFavoritedSite:siteCode]){
        return success; // This is already a favorite so ignore the request
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    Favorites *favorite = [NSEntityDescription
                           insertNewObjectForEntityForName:FAVORITES_ENTITY
                           inManagedObjectContext:context];
    
    favorite.displayName = favorite.internalName = name;
    favorite.siteCode = siteCode;
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"ERROR, couldn't save after inserting object: %@", [error localizedDescription]);
        success = NO;
    }
    
    return success;
}


- (BOOL)updateDisplayName:(NSString *)displayName withSiteCode:(NSString *)siteCode{
    
    BOOL success = NO;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:FAVORITES_ENTITY inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"siteCode LIKE %@", siteCode];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array == nil || [array count] == 0)
    {
        
    } else {
        Favorites *favToUpdate = [array objectAtIndex:0];
        favToUpdate.displayName = displayName;
        
        if (![context save:&error]) {
            NSLog(@"ERROR, couldn't save after inserting object: %@", [error localizedDescription]);
            success = NO;
        } else {
            success = YES;
        }
    }
    
    return success;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Favorites.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:FAVORITES_ENTITY withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark app v1 conversion helpers


- (void)convertV1PropertyList{
    
    NSArray *v1UserFavs = [[NSUserDefaults standardUserDefaults] objectForKey:@"RiversList"];
    
    if (v1UserFavs != nil && [v1UserFavs count] > 0){
        
        NSManagedObjectContext *context = [self managedObjectContext];

        for (NSDictionary *faveDict in v1UserFavs){
        
            RDLog(@"V1 FAVORITE: %@", faveDict);
            
            Favorites *favorite = [NSEntityDescription
                                  insertNewObjectForEntityForName:FAVORITES_ENTITY
                                  inManagedObjectContext:context];
            
            favorite.displayName = favorite.internalName = [faveDict objectForKey:@"title"];
            favorite.siteCode = [faveDict objectForKey:@"siteCode"];
            
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"ERROR, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
    
}

@end
