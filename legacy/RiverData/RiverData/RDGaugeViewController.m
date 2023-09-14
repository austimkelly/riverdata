//
//  RDGaugeViewController.m
//  RiverData
//
//  Created by Tim Myxer on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import "RDGaugeViewController.h"
//#import "RDNetworkAPIEngine.h"
#import "RDSingleGaugeItem.h"
#import "RDRiverGraphViewViewController.h"
#import "RDSiteMapViewController.h"
#import "RDSiteItemTableViewCell.h"
#import "TKGoogleAnalyticsUtil.h"
#import "USGSHTTPSessionManager.h"
#import "RDUtils.h"

#if IS_LITE
#import "RDUpgradeDialog.h"
#endif

// 3rd Party
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIAlertView+Blocks.h"
#import "CMMapLauncher.h"
#import "TSMiniWebBrowser.h"

@interface RDGaugeViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *guageItemTableViewController;
@property (strong, nonatomic) NSArray *timeSeriesResult;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIImage *starEnabledImg;
@property (strong, nonatomic) UIImage *starDisabledImg;
@property (strong, nonatomic) UIBarButtonItem *favoriteButton;

@property (nonatomic, assign) BOOL isFavorite;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

@end

@implementation RDGaugeViewController

@synthesize gaugeModelArray = _gaugeModelArray;
@synthesize timeSeriesResult = _timeSeriesResult;
@synthesize siteCode = _siteCode;
@synthesize naviTitle = _naviTitle;
@synthesize starDisabledImg = _starDisabledImg, starEnabledImg = _starEnabledImg;
@synthesize favoriteButton = _favoriteButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self initUI];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh..."];
    [self.refreshControl addTarget:self action:@selector(fetchGaugeData) forControlEvents:UIControlEventValueChanged];
    [self.guageItemTableViewController addSubview:self.refreshControl];
    
    if (self.gaugeModelArray != nil && [self.gaugeModelArray count] > 0){
        [self fetchGaugeData];
    }
    else if (self.siteCode != nil){
        [self fetchGaugeData];
    } else if (self.siteCode == nil) {
        // show empty view controller
        self.guageItemTableViewController.hidden = YES;
        
    }
    
    if (self.splitViewController){
        self.navigationItem.leftBarButtonItem = [self.splitViewController displayModeButtonItem];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeSecondaryOnly;
    }
    
}

- (void)refresh{
    
    [self fetchGaugeData];
    
}

- (void)initUI{
    
    self.isFavorite = [((RDAppDelegate *)[[UIApplication sharedApplication] delegate]) isFavoritedSite:self.siteCode];
    
    // Add favorite image
    UIImage *selectedStar = [UIImage imageNamed:@"star_selected"];
    UIImage *unSelectedStar = [UIImage imageNamed:@"star_disabled"];
    
    if ([selectedStar respondsToSelector:@selector(imageWithRenderingMode:)]){
        self.starEnabledImg = [selectedStar imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.starDisabledImg = [unSelectedStar imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        self.starEnabledImg = selectedStar;
        self.starDisabledImg = unSelectedStar;
    }
    
    UIImage *currStar = self.isFavorite ? self.starEnabledImg : self.starDisabledImg;
    
    self.favoriteButton = [[UIBarButtonItem alloc] initWithImage:currStar style:UIBarButtonItemStylePlain target:self action:@selector(toggleFavoriteState)];
    self.navigationItem.rightBarButtonItem = self.favoriteButton;
    
    // Set up custom label so it will be on two lines
    
    if (self.gaugeModelArray == nil){
        
        self.title = self.naviTitle == nil ? @"Favorite" : self.naviTitle;
        
    } else {
        
        RDGaugeModel *topGaugeModel = [self.gaugeModelArray objectAtIndex:0];
        self.title = topGaugeModel.riverDisplayName;
        
    }
    
    // Add custom label
    UILabel *customNaviTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 55)];
    customNaviTitle.backgroundColor = [UIColor clearColor];
    customNaviTitle.numberOfLines = 2;
    customNaviTitle.textAlignment = NSTextAlignmentCenter;
    customNaviTitle.font = [UIFont boldSystemFontOfSize:14];
    customNaviTitle.text = self.title;
    
    self.navigationItem.titleView = customNaviTitle;
    
}

- (void)toggleFavoriteState{
    
#if IS_LITE
    if (!self.isFavorite){
        NSArray *favorites = [((RDAppDelegate *)[[UIApplication sharedApplication] delegate]) fetchAllFavorites];
        if (favorites != nil && [favorites count] >= 3){
            [RDUpgradeDialog showUpgradeDialogWithMessage:@"The lite version only supports adding 3 favorites."];
            return;
        }
    }
#endif
    
    if (self.siteCode == nil){
        [UIAlertView showErrorWithMessage:@"Once a USGS site is successfully loaded, tap the star to store in your favorites!" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            // nothing to do
        }];
        return;
    }
    
    self.isFavorite = !self.isFavorite; // flip state
    
    UIImage *currStar = self.isFavorite ? self.starEnabledImg : self.starDisabledImg;

    [self.favoriteButton setImage:currStar];
    
    self.navigationItem.rightBarButtonItem = self.favoriteButton;

    if (self.isFavorite){
        
        [self.view makeToast:[NSString stringWithFormat:@"%@ was added to Favorites", self.title] duration:2.5f position:@"center" title:@"Added Favorite" image:self.starEnabledImg];
        
        [((RDAppDelegate *)[[UIApplication sharedApplication] delegate]) addFavroiteSite:self.siteCode withSiteName:self.title];
        
    } else {
        
        [self.view makeToast:[NSString stringWithFormat:@"%@ was removed from Favorites", self.title] duration:2.5f position:@"center" title:@"Removed Favorite" image:self.starDisabledImg];
        
        [((RDAppDelegate *)[[UIApplication sharedApplication] delegate]) removeFavoriteSite:self.siteCode];
    }
    
    // Post notification that favorites was modified
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAVORITES_CHANGED object:self];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    //[SVProgressHUD dismiss];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"PushGraphView"]){
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        RDRiverGraphViewViewController *graphVC = [segue destinationViewController];
        
        graphVC.timeSeriesItem = [self.timeSeriesResult objectAtIndex:indexPath.row];
        graphVC.siteName = self.title;
        
    } else if ([segue.identifier isEqualToString:@"PushMapView"]){
        
        RDSiteMapViewController *siteMap = [segue destinationViewController];
        siteMap.firstGauge = [self.timeSeriesResult objectAtIndex:0];
        siteMap.riverName = self.navigationItem.title;
        
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark data fetching routines

- (void)fetchGaugeData{
    
    self.guageItemTableViewController.hidden = NO;
    
    RDLog(@"Fetching gauge with IDs: %@", self.gaugeModelArray);
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Fetching Gauge Data"]];
    
    RDGaugeModel *model = [self.gaugeModelArray objectAtIndex:0];
    
    NSMutableArray *gaugeIds = nil;
    
    if (self.gaugeModelArray != nil){
        
        self.siteCode = model.siteId;
        
        gaugeIds = [NSMutableArray array];
        
        for (RDGaugeModel *model in self.gaugeModelArray){
            
            [gaugeIds addObject:model.gaugeId];
            
        }
    } else {
        
        // we already have the sideCode but not gauge Ids, so nothing else to do.
        
    }
    
    USGSHTTPSessionManager *api = [USGSHTTPSessionManager apiInstance];
    
    [api fetchAllGaugeDataForSiteId:self.siteCode withGaugeIds:gaugeIds withCompletionHandler:^(BOOL success, NSArray *gaugeModels) {
        
        // completion
        if (success && [gaugeModels count] > 0){
            
            self.timeSeriesResult = gaugeModels;
            RDLog(@"Gauge Fetch Result = %@", gaugeModels.description);
            
            [self.guageItemTableViewController reloadData];
            [SVProgressHUD dismiss];
            
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Server did not return latest gauges. Data may not be up to date." preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // Handle the OK button tap
                [SVProgressHUD dismiss];
            }];

            [alertController addAction:okAction];

            // Present the alertController
            [self presentViewController:alertController animated:YES completion:nil];

        }
        
        
        [self.refreshControl endRefreshing];

        
    } withErrorHandler:^(NSError *error) {
        
        // Error
        NSLog(@"ERROR Fetching All Gauge Data: %@", error.localizedDescription);
        [SVProgressHUD dismiss];
        
    }];
    
       
}

- (void)showMapDirectionOptions{
    
    
    NSMutableArray *installedMapAppTitles = [NSMutableArray array];
    
    // Apple maps test
    for (int i = 0; i < 8; i++){
        
        BOOL installed = NO;
        
        if (i == CMMapAppAppleMaps){
            installed = [CMMapLauncher isMapAppInstalled:CMMapAppAppleMaps];
            if (installed){
                [installedMapAppTitles addObject:@"Apple Maps"];
            }
        } else if (i == CMMapAppCitymapper){
            installed = [CMMapLauncher isMapAppInstalled:CMMapAppCitymapper];
            if (installed){
                [installedMapAppTitles addObject:@"City Mapper"];
            }
        } else if (i == CMMapAppGoogleMaps){
            installed = [CMMapLauncher isMapAppInstalled:CMMapAppGoogleMaps];
            if (installed){
                [installedMapAppTitles addObject:@"Google Maps"];
            }
        } else if (i == CMMapAppTheTransitApp){
            installed = [CMMapLauncher isMapAppInstalled:CMMapAppTheTransitApp];
            if (installed){
                [installedMapAppTitles addObject:@"The Transit App"];
            }
        } else if (i == CMMapAppWaze){
            installed = [CMMapLauncher isMapAppInstalled:CMMapAppWaze];
            if (installed){
                [installedMapAppTitles addObject:@"Waze"];
            }
        } else if (i == CMMapAppYandex){
            installed = [CMMapLauncher isMapAppInstalled:CMMapAppYandex];
            if (installed){
                [installedMapAppTitles addObject:@"Yandex"];
            }
        }
        else if (i == CMMapAppUber){
            installed = [CMMapLauncher isMapAppInstalled:CMMapAppUber];
            if (installed){
                [installedMapAppTitles addObject:@"Uber"];
            }
        }
    }
    
    if ([installedMapAppTitles count] > 0){

        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Complete action using..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        
        
        for (NSString *title in installedMapAppTitles){
            
            [actionSheet addButtonWithTitle:title];
            
        }
        
        [actionSheet showInView:self.view];
        
    } else {
        
        [UIAlertView showErrorWithMessage:@"No mapping application could be found." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            // done
        }];
        
    }

    
}

#pragma mark UITableView delegate/datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"PushGraphView" sender:indexPath];
    } else if (indexPath.section == 2) {
        
#if IS_LITE
        
        [RDUpgradeDialog showUpgradeDialogWithMessage:@"Get the full version for driving directions to this site."];
        return;
#endif
        
        [self showMapDirectionOptions];
        
        GA_TRACK_EVENT(@"Tapped Show Directions", self.siteCode, self.title, nil);
        
    } else if (indexPath.section == 1){
        
#if IS_LITE
      
        [RDUpgradeDialog showUpgradeDialogWithMessage:@"Get the full version to enable email notifications from USGS!"];
        return;
#endif
        
        GA_TRACK_EVENT(@"Tapped USGS Email Notifications", self.siteCode, self.title, nil);
        
        [UIAlertView showConfirmationDialogWithTitle:@"Leaving River Data" message:@"You will be re-directed to the USGS Water Alert web page. All email subscription activitations and de-activations are handled through UGSG and not this the River Data application." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            // completion
            if (buttonIndex == 1){
                NSString *url = [NSString stringWithFormat:@"https://accounts.waterdata.usgs.gov/wateralert/my-alerts/#siteNumber=%@", self.siteCode];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }

            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        }];
        
    } else if (indexPath.section == 3){
        
#if IS_LITE
        
        [RDUpgradeDialog showUpgradeDialogWithMessage:@"Get the full version for full weather report for this site."];
        return;
#endif
        
        GA_TRACK_EVENT(@"Tapped NWS", self.siteCode, self.title, nil);
        
        RDSingleGaugeItem *gaugeData = [self.timeSeriesResult objectAtIndex:0];
        NSString *weatherUrl = [NSString stringWithFormat:@"http://mobile.weather.gov/index.php?lat=%f&lon=%f", gaugeData.latitude, gaugeData.longitude];

        TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:weatherUrl]];
        [self.navigationController pushViewController:webBrowser animated:YES];
        
//        [UIAlertView showConfirmationDialogWithTitle:@"Leaving River Data" message:@"You will now be directed to the National Weather Service mobile site." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            
//            // completion
//            if (buttonIndex == 1){
//                RDSingleGaugeItem *gaugeData = [self.timeSeriesResult objectAtIndex:0];
//                
//                NSString *weatherUrl = [NSString stringWithFormat:@"http://mobile.weather.gov/index.php?lat=%f&lon=%f", gaugeData.latitude, gaugeData.longitude];
//                
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weatherUrl]];
//            }
//            
//            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
//        }];

        
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 1){
        return @"USGS Water Alert"; // No title for second section
    }
    else if (section == 2){
        return @"Map / Directions"; // No title for second section
    } else if (section == 3){
        return @"Weather / Forecast";
    }
    
    if (self.timeSeriesResult == nil || [self.timeSeriesResult count] == 0){
        return @"Loading...";
    }
    
    return [NSString stringWithFormat:@"%lu Gauges", (unsigned long)[self.timeSeriesResult count]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0){
        return [self.timeSeriesResult count];
    } else if (section == 1 || section == 2 || section == 3){
        return 1;
    }
    
    return 0;
}

#define HEIGHT_GAUGE_CELL   88
#define HEIGHT_SIMPLE_CELL  60

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){
        static RDSiteItemTableViewCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.guageItemTableViewController dequeueReusableCellWithIdentifier:@"GaugeCell"];
        });
        
        // This is the secret sauce to make a UILable update it's constraints against
        // Where we've set the height contraint to allow the height to be >= to the default height.
        UILabel* detailLabel = (UILabel *)[sizingCell viewWithTag:2];
        detailLabel.numberOfLines = 0;
        detailLabel.preferredMaxLayoutWidth = tableView.bounds.size.width;
        [detailLabel setNeedsUpdateConstraints];
        RDSingleGaugeItem *gaugeData = [self.timeSeriesResult objectAtIndex:indexPath.row];
        detailLabel.text = gaugeData.name;
        
        sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.guageItemTableViewController.frame), CGRectGetHeight(sizingCell.bounds));
        
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        
        CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return  size.height + 1.0f; // Add 1.0f for the cell separator height
    }
    
    return HEIGHT_SIMPLE_CELL;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0){
        return HEIGHT_GAUGE_CELL;
    }
    
    return HEIGHT_SIMPLE_CELL;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = indexPath.section == 0 ? @"GaugeCell" : @"Cell";
    RDSiteItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    /*
     *   If the cell is nil it means no cell was available for reuse and that we should
     *   create a new one.
     */
    if (cell == nil) {
        
        /*
         *   Actually create a new cell (with an identifier so that it can be dequeued).
         */
        
        cell = [[RDSiteItemTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if (indexPath.section == 0){
        
        UILabel* titleLabel = (UILabel *)[cell viewWithTag:1];
        
        UILabel* detailLabel = (UILabel *)[cell viewWithTag:2];
       
        UILabel* timeStampLabel = (UILabel *)[cell viewWithTag:3];

        RDSingleGaugeItem *gaugeData = [self.timeSeriesResult objectAtIndex:indexPath.row];
        
        NSString *unitValue = gaugeData.unitAbbreviation != nil ? [NSString stringWithFormat:@"%@ %@", gaugeData.value, gaugeData.unitAbbreviation] : gaugeData.value;
        
        if ([gaugeData.unitAbbreviation isEqualToString:@"deg C"]){
            float degF = [gaugeData.value floatValue] * (9.0/5) + 32;
            unitValue = [NSString stringWithFormat:@"%@ (%0.1f F)", unitValue, degF];
        }
        
        titleLabel.text = unitValue;
        
        detailLabel.text = gaugeData.name;
        
        NSString *format = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = format; // UTC format for from USGS
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        
        // Conver the input UTC date from NSString to NSDate
        NSDate *utcDate = [dateFormatter dateFromString:gaugeData.dateString];
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:utcDate
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterLongStyle];
        
       
        timeStampLabel.text = [NSString stringWithFormat:@"Last Update: %@", dateString];
        NSInteger daysOld = daysOldFromDate(dateString);
        if (daysOld > 118) {
            timeStampLabel.textColor = UIColor.redColor;
        } else if (daysOld > 7) {
            timeStampLabel.textColor = UIColor.orangeColor;
        }
            
    } else if (indexPath.section == 1){
        
        // email alerts
        cell.textLabel.text = @"Subscribe to this site...";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Site ID: %@", self.siteCode];
        cell.imageView.image = [UIImage imageNamed:@"email_minimal"];
        
    } else if (indexPath.section == 2){
        
        if (self.timeSeriesResult != nil && [self.timeSeriesResult count] > 0){
            
            RDSingleGaugeItem *oneGauge = [self.timeSeriesResult objectAtIndex:0];
            
            cell.textLabel.text = @"Get directions to site...";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Long=%f / Lat=%f", oneGauge.longitude, oneGauge.latitude];
            cell.imageView.image = [UIImage imageNamed:@"globe"];
            
        } else {
            
            cell.textLabel.text = @"Location not loaded.";
            
        }
        
    } else if (indexPath.section == 3){
        
        cell.textLabel.text = @"NWS Forecast";
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:@"cloudirc"];
    }
    
    [cell layoutSubviews];
    
    return cell;
};


// This code calculates the number of days old the dateString is and returns that value as an NSInteger. If the input date is not valid, it returns -1, but you can choose any other suitable value to indicate invalid input.
NSInteger daysOldFromDate(NSString *dateString) {
    // Create a date formatter to parse the input date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy, hh:mm:ss a zzz"];

    // Parse the input date string into an NSDate object
    NSDate *inputDate = [dateFormatter dateFromString:dateString];

    if (inputDate) {
        // Calculate the current date
        NSDate *currentDate = [NSDate date];

        // Calculate the time interval (in seconds) between the input date and the current date
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:inputDate];

        // Calculate the number of days from the time interval
        NSInteger numberOfDays = (NSInteger)(timeInterval / (24 * 60 * 60)); // 24 hours * 60 minutes * 60 seconds

        return numberOfDays;
    }

    // Input date is not valid
    return -1; // You can choose to return a specific value to indicate invalid input
}


#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0){
        return; // cancel
    } else {
        
        RDSingleGaugeItem *gaugeData = [self.timeSeriesResult objectAtIndex:0];
        
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        CMMapApp appType = CMMapAppAppleMaps;
        
        if ([title isEqualToString:@"Apple Maps"]){
            appType = CMMapAppAppleMaps;
        } else if ([title isEqualToString:@"City Mapper"]){
            appType = CMMapAppCitymapper;
        } else if ([title isEqualToString:@"Google Maps"]){
            appType = CMMapAppGoogleMaps;
        } else if ([title isEqualToString:@"The Transit App"]){
            appType = CMMapAppTheTransitApp;
        } else if ([title isEqualToString:@"Waze"]){
            appType = CMMapAppWaze;
        } else if ([title isEqualToString:@"Yandex"]){
            appType = CMMapAppYandex;
        } else if ([title isEqualToString:@"Uber"]){
            appType = CMMapAppUber;
        }

        
        CLLocationCoordinate2D siteLocation = CLLocationCoordinate2DMake(gaugeData.latitude, gaugeData.longitude);
        [CMMapLauncher launchMapApp:appType
                    forDirectionsTo:[CMMapPoint mapPointWithName:self.title
                                                      coordinate:siteLocation]];
    }
    
}




@end
