//
//  RDRiverGraphViewViewController.m
//  RiverData
//
//  Created by Tim Myxer on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import "RDRiverGraphViewViewController.h"

#if IS_LITE
#import "RDUpgradeDialog.h"
#endif

// 3rd Party
#import "UIImageView+WebCache.h"
#import "UIView+Toast.h"
#import "UIImageView+PlayGIF.h"

@interface RDRiverGraphViewViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet UISlider *chartDaySlider;
@property (weak, nonatomic) IBOutlet UILabel *chartDaysText;
@property (weak, nonatomic) IBOutlet UIScrollView *chartScrollView;

@end

@implementation RDRiverGraphViewViewController

@synthesize timeSeriesItem = _timeSeriesItem;
@synthesize siteName = _siteName;

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
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    //self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    NSString *measurementTypeDisplayName = self.timeSeriesItem.name;
    
    measurementTypeDisplayName = [[measurementTypeDisplayName componentsSeparatedByString:@","] objectAtIndex:0];
    
    self.navigationItem.title = measurementTypeDisplayName;
    
    // Images from USGS are typically 576w x 400h
    //self.chartScrollView.contentSize = CGSizeMake(1280, 888);
    self.chartScrollView.delegate = self;
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    // Add doubleTap recognizer to the scrollView
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.chartScrollView addGestureRecognizer:doubleTapRecognizer];
    
    // Add two finger recognizer to the scrollView
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.chartScrollView addGestureRecognizer:twoFingerTapRecognizer];

    
    [self fetchChartImage];
    
}

- (void)shareAction{
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (self.timeSeriesItem.name) {
        NSString *displayText = [NSString stringWithFormat:@"%@ @ %@ %@ (%@)", self.siteName, self.timeSeriesItem.value, self.timeSeriesItem.unitAbbreviation, self.timeSeriesItem.name];
        [sharingItems addObject:displayText];
    }
    
    if (self.chartImageView.image) {
        [sharingItems addObject:self.chartImageView.image];
    }
   
    // Add tiny URL to app
    // https://itunes.apple.com/us/app/river-data/id552825440?mt=8
    [sharingItems addObject:@"River Data for iOS: http://bit.ly/1p1EDXI"];
    
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:activityController animated:YES completion:^{
            // completion
            
        }];
    }
    //if iPad
    else
    {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        //NSLog(@"%f",self.view.frame.size.width/2);
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    
    
}

- (void)fetchChartImage{
    
    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"giphy.gif" ofType:nil]];
    
    UIImageView *gifView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.chartImageView.frame.size.width, self.chartImageView.frame.size.height)];
    gifView.backgroundColor = [UIColor darkGrayColor];
    gifView.gifData = gifData;
    
    NSInteger days = (int)self.chartDaySlider.value;
    
    NSString *urlString = [NSString stringWithFormat:@"http://waterdata.usgs.gov/nwisweb/graph?agency_cd=USGS&site_no=%@&parm_cd=%@&period=%d", self.timeSeriesItem.parentGaugeId, self.timeSeriesItem.timeSeriesId, (int)days];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    //[self.chartImageView makeToastActivity];
    
    // clear out all the old subviews
    for (UIView *view in [self.chartImageView subviews]){
        [view removeFromSuperview];
    }
    
    [self.chartImageView addSubview:gifView];
    
    [gifView startGIF];
    
    [self.chartImageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        RDLog(@"Image Load Complete...");
        //[self.chartImageView hideToastActivity];
        [gifView stopAnimating];
        [gifView removeFromSuperview];
    }];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UISlider control events
- (IBAction)sliderValueChanged:(id)sender {
    
     //RDLog(@"Slider Value Changed: %f", self.chartDaySlider.value);
    
    self.chartDaysText.text = [NSString stringWithFormat:@"Chart Days: %d", (int)self.chartDaySlider.value];
    
}
- (IBAction)sliderStoppedSliding:(id)sender {
    
#if IS_LITE
    [RDUpgradeDialog showUpgradeDialogWithMessage:@"Updade to the the full version of River Data for full historical data."];
    return;
#endif
    
     [self fetchChartImage];
    
}



#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.chartImageView;
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView {
//    CGRect cFrame = self.contentView.frame;
//    cFrame.origin = CGPointZero;
//    self.contentView.frame = cFrame;
    ////// [self centerScrollViewContents];
}


#pragma mark -
#pragma mark - ScrollView gesture methods
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:self.chartImageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.chartScrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.chartScrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.chartScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.chartScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.chartScrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.chartScrollView.minimumZoomScale);
    [self.chartScrollView setZoomScale:newZoomScale animated:YES];
}

#pragma mark -
#pragma mark - Rotation

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // When the orientation is changed the contentSize is reset when the frame changes. Setting this back to the relevant image size
    self.chartScrollView.contentSize = self.chartImageView.image.size;
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}



@end
