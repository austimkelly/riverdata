//
//  RDSecondViewController.m
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import "RDFavoritesViewController.h"
#import "RDGaugeViewController.h"
#import "RDAppDelegate.h"
#import "Favorites.h"
#import "RDUtils.h"

#if IS_LITE
#import "RDUpgradeDialog.h"
#endif

// 3rd Party
#import "UIAlertView+Blocks.h"

@interface RDFavoritesViewController () <UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *favoritesTableView;
@property (strong, nonatomic) NSMutableArray *favoriteSites; // Array of Favorites (NSManagedObject)

@end

@implementation RDFavoritesViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.favoritesTableView.allowsSelectionDuringEditing = YES;
    
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    
    self.splitViewController.delegate = self;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.favoritesTableView.backgroundColor = [UIColor systemBackgroundColor];
    
    [self refreshUI];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self refreshUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:NOTIFICATION_FAVORITES_CHANGED object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FAVORITES_CHANGED object:nil];
}

- (void)refreshUI{
    
    [self initFavorites];
    
    [self.favoritesTableView reloadData];
    
    [self.favoritesTableView setEditing:NO animated: YES];
    
    [self.splitViewController displayModeButtonItem];

}

- (void)initFavorites{
    
    RDAppDelegate *appD = (RDAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *unsortedFavorites = [[appD fetchAllFavorites] mutableCopy];
    
    NSArray *sortedFavorites = [unsortedFavorites sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Favorites *)a displayName];
        NSString *second = [(Favorites*)b displayName];
        return [[first uppercaseString] compare:[second uppercaseString]];
    }];
    
    self.favoriteSites = [NSMutableArray arrayWithArray:sortedFavorites];
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    // Don't seque while we are editing
    return !self.favoritesTableView.isEditing;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([sender isKindOfClass:[UITableViewCell class]]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.favoritesTableView indexPathForCell:cell];
        Favorites *selectedFavroite = [self.favoriteSites objectAtIndex:indexPath.row];
        
        if ([segue.identifier isEqualToString:@"showFavorites"]){
            RDGaugeViewController *gaugeVC;
            
            float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (ver >= 8.0) {
               gaugeVC = (RDGaugeViewController *)[[segue.destinationViewController viewControllers] lastObject];
            } else {
               gaugeVC = (RDGaugeViewController *)segue.destinationViewController;
            }
            
            
            gaugeVC.siteCode = selectedFavroite.siteCode;
            gaugeVC.naviTitle = selectedFavroite.displayName;
            //[gaugeVC refresh];
        }
        else {
            RDGaugeViewController *gaugeVC = [segue destinationViewController];
            gaugeVC.siteCode = selectedFavroite.siteCode;
            gaugeVC.naviTitle = selectedFavroite.displayName;
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.favoritesTableView setEditing:editing animated:YES];
}

#pragma mark UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    if (self.favoriteSites != nil && [self.favoriteSites count] > 0){
        return [NSString stringWithFormat:@"%lu Favorites", (unsigned long)[self.favoriteSites count]];
    } else {
        return [NSString stringWithFormat:@"Tap the star in a site to add a favorite!"];

    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.textColor = [UIColor labelColor];
        tableViewHeaderFooterView.contentView.backgroundColor = [UIColor riverDataMaroon];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 55;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.favoritesTableView.isEditing){
        
#if IS_LITE
        [RDUpgradeDialog showUpgradeDialogWithMessage:@"Editing river names in your favorite is supported in the full version. Would you like to upgrade now?"];
        return;
#endif
        
        Favorites *selectedFav = [self.favoriteSites objectAtIndex:indexPath.row];
        
        [UIAlertView showTextViewEditWithTitle:@"Edit River Name" message:@"" defaultText:selectedFav.displayName handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            // completion
            if (buttonIndex == 1){
                // OK pressed
                NSString *newDisplayName = [alertView textFieldAtIndex:0].text;
                if (newDisplayName.length > 0){
                    
                    if ([newDisplayName isEqualToString:selectedFav.displayName]){
                        // Nothing has changed, just go away silently
                    } else {
                        // Save off the new name in the managed object
                        RDLog(@"Save Here");
                        
                        RDAppDelegate *appD = (RDAppDelegate *)[UIApplication sharedApplication].delegate;
                        [appD updateDisplayName:newDisplayName withSiteCode:selectedFav.siteCode];
                        
                        [self.favoritesTableView reloadData];
                    }
                    
                } else {
                    
                    [UIAlertView showErrorWithMessage:@"River name must be at least one character." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        // nothing to do
                    }];
                    
                }
            } else {
                //ignore
            }
        }];
        
    } else {
        
//        UIViewController *test = self.splitViewController[self.splitViewController ]
//        NSLog(@"test");
        
    }
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        long index = indexPath.row;
        
        // Get the managed object
        Favorites *favMO = [self.favoriteSites objectAtIndex:index];
        
        if (favMO){
            
            RDAppDelegate *appD = (RDAppDelegate *)[UIApplication sharedApplication].delegate;
            
            // remove the managed object
            if ([appD removeFavoriteSite:favMO.siteCode]){
            
                // remove from the local data model
                [self.favoriteSites removeObjectAtIndex:index];
                
                [self.favoritesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

#pragma makr UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.favoriteSites count];
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FavoriteCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    Favorites *modelForRow = [self.favoriteSites objectAtIndex:indexPath.row];
    
    cell.textLabel.text = modelForRow.displayName;
    
    return cell;
}


#pragma mark Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[RDGaugeViewController class]]
        && ([(RDGaugeViewController *)[(UINavigationController *)secondaryViewController topViewController] siteCode] == nil)) {
        
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
        
    } else {
        
        return NO;
        
    }
}


@end
