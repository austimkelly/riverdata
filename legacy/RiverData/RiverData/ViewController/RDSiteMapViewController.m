//
//  RDSiteMapViewController.m
//  RiverData
//
//  Created by Tim Kelly on 8/1/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "RDSiteMapViewController.h"
#import "RDSiteAnnotation.h"

@interface RDSiteMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation RDSiteMapViewController

@synthesize firstGauge = _firstGauge;
@synthesize riverName = _riverName;

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
    CLLocationCoordinate2D ctrpoint;
    ctrpoint.longitude = self.firstGauge.longitude;
    ctrpoint.latitude = self.firstGauge.latitude;

    self.navigationItem.title = self.riverName;
    
    RDSiteAnnotation *siteAnnotation = [[RDSiteAnnotation alloc] initWithCoordinate:ctrpoint withTitle:self.riverName withSubtitle:[NSString stringWithFormat:@"Long/Lat : %f/%f", self.firstGauge.longitude, self.firstGauge.latitude]];
    [self.mapView addAnnotation:siteAnnotation];
    if ([self.mapView respondsToSelector:@selector(showAnnotations:animated:)]){
        [self.mapView showAnnotations:[NSArray arrayWithObjects:siteAnnotation, nil] animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
