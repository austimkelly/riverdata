//
//  RDStateGaugesTableViewController.m
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import "RDStateGaugesTableViewController.h"
//#import "RDNetworkAPIEngine.h"
#import "RDGaugeModel.h"
#import "RDGaugeViewController.h"
#import "TKGoogleAnalyticsUtil.h"
#import "RDSiteMapViewViewController.h"
#import "RDUserDefaults.h"
#import "USGSHTTPSessionManager.h"

// 3rd Party
#import "UIAlertView+Blocks.h"
#import "SVProgressHUD.h"


@interface RDStateGaugesTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *gaugeModels;                 // Array of arrays with RDGaugeModel objects
@property (strong, nonatomic) NSMutableArray *filteredGaugeModels;  // Arrays of arrays
@property (assign, nonatomic) BOOL isFiltered;

@property (strong, nonatomic) IBOutlet UITableView *gaugesTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// Cluster map support
@property (strong, nonatomic) RDSiteMapViewViewController *mapVC;
@property (strong, nonatomic) UIBarButtonItem *rightBarButton;

@end

@implementation RDStateGaugesTableViewController

@synthesize gaugeModels = _gaugeModels;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    RDLog(@"Loaded with state: %@", self.state.twoLetterCode);
    
    UIRefreshControl *refresher = [[UIRefreshControl alloc] init];
    
    refresher.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh..."];
    
    [refresher addTarget:self action:@selector(fetchGauges) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresher;
    
    self.navigationItem.title = self.state.displayName;
    
    self.searchBar.delegate = self;
    
    self.gaugeModels = [NSArray array];
    
    // Map transition
    self.navigationItem.title = self.state.displayName;
    NSString *rightBarButtonTitle = @"Map";
    
    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(showSiteOnMap:)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    
    self.mapVC = [[RDSiteMapViewViewController alloc] initWithNibName:@"RDSiteMapViewViewController" bundle:nil];
    
    self.mapVC.filterOnTwoLetterStateCode = self.state.twoLetterCode;
    
    [self fetchGauges];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    GA_TRACK_CLASS
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([sender isKindOfClass:[UITableViewCell class]]){
        
        UITableViewCell *cell = (UITableViewCell *)sender;
        
        NSIndexPath *indexPath = [self.gaugesTableView indexPathForCell:cell];
        
        RDGaugeViewController *gaugeVC = [segue destinationViewController];
        
        
        if (self.isFiltered){
            gaugeVC.gaugeModelArray = [self.filteredGaugeModels objectAtIndex:indexPath.row];
        } else {
            gaugeVC.gaugeModelArray = [self.gaugeModels objectAtIndex:indexPath.row];
        }
        
        RDGaugeModel *model = [gaugeVC.gaugeModelArray objectAtIndex:0];
        gaugeVC.siteCode = model.siteId;
        
    }
    
}

- (void)showSiteOnMap:(id)sender{
    
    [UIView transitionWithView:self.navigationController.view duration:1.00 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.navigationController pushViewController:self.mapVC animated:NO];
    } completion:^(BOOL finished) {
        // completion
    }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark data fetching routines

- (void)fetchGauges{
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Fetching %@ Gauges from USGS...", self.state.displayName]];
    
    USGSHTTPSessionManager *apiManager = [USGSHTTPSessionManager apiInstance];
    
    [apiManager fetchStateGauges:self.state.twoLetterCode withFilterNumericSites:[RDUserDefaults getFilterNumericSites] withCompletionHandler:^(BOOL success, NSArray *gaugeModels) {
        // completion
        if (success){
            
            self.gaugeModels = gaugeModels;
            [self.tableView reloadData];
            
        }
        
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
        
    } withErrorHandler:^(NSError *error) {
        // error
        NSLog(@"ERROR: %@", error.localizedDescription);
        [UIAlertView showConfirmationDialogWithTitle:error.localizedDescription message:@"Retry?" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            // completion
            if (buttonIndex == 1){
                [self performSelector:@selector(fetchGauges) withObject:self];
            }
            
        }];
    }];
        
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger gaugeCount = 0;
    if (self.isFiltered){
        gaugeCount = self.filteredGaugeModels != nil ? [self.filteredGaugeModels count] : 0;
    } else {
        gaugeCount = self.gaugeModels != nil ? [self.gaugeModels count] : 0;
    }
    
    return [NSString stringWithFormat:@"%ld sites", (long)gaugeCount];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.textColor = [UIColor whiteColor];
        tableViewHeaderFooterView.textLabel.numberOfLines = 2;
        tableViewHeaderFooterView.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tableViewHeaderFooterView.contentView.backgroundColor = [UIColor riverDataMaroon];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.isFiltered){
        return [self.filteredGaugeModels count];
    } else {
        return [self.gaugeModels count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSArray *gaugeArray;
    
    if (self.isFiltered){
        gaugeArray = [self.filteredGaugeModels objectAtIndex:indexPath.row];
    } else {
        gaugeArray = [self.gaugeModels objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    RDGaugeModel *gaugeModel = [gaugeArray objectAtIndex:0];
    cell.textLabel.text = gaugeModel.riverDisplayName;
    int numGauges = (int)[gaugeArray count];
    if (numGauges == 1){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d gauge", numGauges];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d gauges", numGauges];
    }
    
    
    return cell;
}


#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0){
        self.isFiltered = NO;
    } else {
        self.isFiltered = YES;
        self.filteredGaugeModels = [NSMutableArray array];
        for (NSArray *gaugesArray in self.gaugeModels){
            
            RDGaugeModel *gauge = [gaugesArray objectAtIndex:0];
            
            NSRange nameRange = [gauge.riverDisplayName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound){
                [self.filteredGaugeModels addObject:gaugesArray];
            }
        }
    }
    
    [self.tableView reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.isFiltered = NO;
    [self.searchBar setText:@""];
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

@end
