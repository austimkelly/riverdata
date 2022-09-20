        //
//  RDSiteMapViewViewController.m
//  RiverData
//
//  Created by Tim Kelly on 12/4/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "RDSiteMapViewViewController.h"
#import "RDSiteAnnotation.h"
#import "ClusterAnnotationView.h"
#import "Settings.h"
#import "DataReader.h"
#import "DataReaderDelegate.h"
#import "RDPointAnnotation.h"
#import "RDGaugeViewController.h"
#import "RDUserDefaults.h"

#ifdef IS_LITE
#import "RDUpgradeDialog.h"
#endif

// 3rd Party
#import "CCHMapClusterer.h"
#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHNearCenterMapClusterer.h"
#import "CCHCenterOfMassMapClusterer.h"
#import "CCHFadeInOutMapAnimator.h"
#import "UIAlertView+Blocks.h"

@interface RDSiteMapViewViewController () <DataReaderDelegate, CCHMapClusterControllerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) DataReader *dataReader;
@property (nonatomic) Settings *settings;
@property (nonatomic) CCHMapClusterController *mapClusterControllerRed;
@property (nonatomic) NSUInteger count;
@property (nonatomic) id<CCHMapClusterer> mapClusterer;
@property (nonatomic) id<CCHMapAnimator> mapAnimator;

@property (assign, nonatomic) float initialMapLongitude;
@property (assign, nonatomic) float initialMapLatitude;

@end

@implementation RDSiteMapViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initMapCluster];
    
    NSLog(@"MapView Frame = %f, %f", self.mapView.frame.size.width, self.mapView.frame.size.height);
    
    self.navigationItem.title = @"USGS Sites";
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [UIView transitionWithView:self.navigationController.view duration:1.00 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            // nothing to do, just doing a cross disolve as the navigation controller is popped
        } completion:^(BOOL finished) {
            // completion
        }];
    }
    
    [super viewWillDisappear:animated];
    
}



- (void)initMapCluster{
    
    // Set up map clustering
    self.mapClusterControllerRed = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterControllerRed.delegate = self;
    
    // Read annotations
    self.dataReader = [[DataReader alloc] initWithState:self.filterOnTwoLetterStateCode];
    self.dataReader.delegate = self;
    
    self.count = 0;
    self.settings = [[Settings alloc] init];
    [self updateWithSettings:self.settings];
}

- (void)updateWithSettings:(Settings *)settings
{
    self.settings = settings;
    
    // Map cluster controller settings
    self.mapClusterControllerRed.debuggingEnabled = settings.isDebuggingEnabled;
    self.mapClusterControllerRed.cellSize = settings.cellSize;
    self.mapClusterControllerRed.marginFactor = settings.marginFactor;
    
    if (settings.clusterer == SettingsClustererCenterOfMass) {
        self.mapClusterer = [[CCHCenterOfMassMapClusterer alloc] init];
    } else if (settings.clusterer == SettingsClustererNearCenter) {
        self.mapClusterer = [[CCHNearCenterMapClusterer alloc] init];
    }
    self.mapClusterControllerRed.clusterer = self.mapClusterer;
    self.mapClusterControllerRed.maxZoomLevelForClustering = settings.maxZoomLevelForClustering;
    self.mapClusterControllerRed.minUniqueLocationsForClustering = settings.minUniqueLocationsForClustering;
    
//    if (settings.animator == SettingsAnimatorFadeInOut) {
//        self.mapAnimator = [[CCHFadeInOutMapAnimator alloc] init];
//    }
//    
//    self.mapClusterControllerRed.animator = self.mapAnimator;
    
    // Restart data reader
    self.count = 0;
    [self.dataReader stopReadingData];
    
    [self.dataReader startReadingUSGSRiverData:[RDUserDefaults getFilterNumericSites]];
    
    // Remove all current items from the map
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        [self.mapView removeOverlay:overlay];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CCHMapClusterControllerDelegate

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = mapClusterAnnotation.annotations.count;
    NSString *unit;
    
    if (numAnnotations > 1){
        unit = [NSString stringWithFormat:@"%lu sites in this area", (unsigned long)numAnnotations];
    } else {
        RDPointAnnotation *point = [mapClusterAnnotation.annotations anyObject];
        int numGauges = (int)point.numGauges;
        if (numGauges == 1){
            unit = [NSString stringWithFormat:@"%d gauge at this site.", numGauges];
        } else {
            unit = [NSString stringWithFormat:@"%d gauges at this site.", numGauges];
        }
        
    }
    return unit;
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = MIN(mapClusterAnnotation.annotations.count, 5);
    if (numAnnotations > 1){
        return @"Zoom in for more...";
    } else {
        NSArray *annotations = [mapClusterAnnotation.annotations.allObjects subarrayWithRange:NSMakeRange(0, numAnnotations)];
        NSArray *titles = [annotations valueForKey:@"title"];
        return [titles componentsJoinedByString:@", "];
    }
}

- (id)mapClusterController:(CCHMapClusterController *)mapClusterController extraDataForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation{
    
    if (mapClusterAnnotation.annotations.count == 1){
        RDPointAnnotation *annotation = [mapClusterAnnotation.annotations anyObject];
        
        return annotation;
    }
    else {
        return nil;
    }
    
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[self.mapView viewForAnnotation:mapClusterAnnotation];
    clusterAnnotationView.count = mapClusterAnnotation.annotations.count;
    clusterAnnotationView.uniqueLocation = mapClusterAnnotation.isUniqueLocation;
    clusterAnnotationView.pointAnnotation = ((RDPointAnnotation *)mapClusterAnnotation.extraData);
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        static NSString *identifier = @"clusterAnnotation";
        
        ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (clusterAnnotationView) {
            clusterAnnotationView.annotation = annotation;
        } else {
            clusterAnnotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            clusterAnnotationView.canShowCallout = YES;
        }
        
        CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotation;
        clusterAnnotationView.count = clusterAnnotation.annotations.count;
        clusterAnnotationView.uniqueLocation = clusterAnnotation.isUniqueLocation;
        annotationView = clusterAnnotationView;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
//    if(![view.annotation isKindOfClass:[MKUserLocation class]]) {
//        CGSize  calloutSize = CGSizeMake(100.0, 80.0);
//        UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-calloutSize.height, calloutSize.width, calloutSize.height)];
//        calloutView.backgroundColor = [UIColor whiteColor];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        button.frame = CGRectMake(5.0, 5.0, calloutSize.width - 10.0, calloutSize.height - 10.0);
//        [button setTitle:@"OK" forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(checkin) forControlEvents:UIControlEventTouchUpInside];
//        [calloutView addSubview:button];
//        [view.superview addSubview:calloutView];
//        calloutView.backgroundColor = [UIColor redColor];
//    }
    
    if ([view isKindOfClass:[ClusterAnnotationView class]]){
        if (((ClusterAnnotationView *)view).count == 1){
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
    }
    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    //view is of type ClusterAnnotationView so we need to pack the data in tehre to be able to navigate to the site id
    
    if ([view isKindOfClass:[ClusterAnnotationView class]]){
        
#if IS_LITE
        
        [RDUpgradeDialog showUpgradeDialogWithMessage:@"Get the full version for site navigation from maps!"];
        
        return;
#endif
        
        RDPointAnnotation *point = ((ClusterAnnotationView *)view).pointAnnotation;
        
        if (point != nil){
        
            NSLog(@"Navigate to site id: %@", point);
            
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            RDGaugeViewController *gaugeVC = (RDGaugeViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SiteSummaryVC"];
            gaugeVC.siteCode = point.siteId;
            gaugeVC.naviTitle = point.title;
            
            [self.navigationController pushViewController:gaugeVC animated:YES];
            
        } else {
            // e.g. Cahaba River at Centerville AL
            [UIAlertView showErrorWithMessage:@"Sorry, the site did not respond. Please try again later." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                // nothing to do
            }];
            
        }
    }
}

//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
//    MKAnnotationView *aV;
//    for (aV in views) {
//        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
//            MKAnnotationView* annotationView = aV;
//            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        }
//    }
//}

#pragma mark DataReaderDelegate

- (void)dataReader:(DataReader *)dataReader addAnnotations:(NSArray *)annotations
{
    
    if (self.initialMapLatitude == 0.0 || self.initialMapLongitude == 0.0){
        
        MKCoordinateRegion region;
        
        int iPhoneLongLatOffset = 20;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            iPhoneLongLatOffset = 0;
        }
        
        if (self.filterOnTwoLetterStateCode == nil){
            
            // unfiltered, center in middle of us
            self.initialMapLatitude = 39.833333;
            self.initialMapLongitude = -98.583333;
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.initialMapLatitude -iPhoneLongLatOffset, self.initialMapLongitude + iPhoneLongLatOffset);
            region = MKCoordinateRegionMakeWithDistance(location, 7000000, 7000000);
            
        } else {
            
            // filter on single state, center on that state.
            float sumLat = 0.0f;
            float sumLong = 0.0f;
            for (RDPointAnnotation *annotation in annotations){
                sumLong += annotation.coordinate.longitude;
                sumLat += annotation.coordinate.latitude;
            }

            self.initialMapLongitude = sumLong / [annotations count] + iPhoneLongLatOffset;
            self.initialMapLatitude = sumLat / [annotations count] - iPhoneLongLatOffset;

            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.initialMapLatitude, self.initialMapLongitude);
            region = MKCoordinateRegionMakeWithDistance(location, 9900000, 990000);
        }
        
        self.mapView.region = region;
    }
    
    [self.mapClusterControllerRed addAnnotations:annotations withCompletionHandler:NULL];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
