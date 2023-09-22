//
//  DataReader.m
//  Macoun 2013
//
//  Created by Hoefele, Claus(choefele) on 20.09.13.
//  Copyright (c) 2013 Hoefele, Claus(choefele). All rights reserved.
//

#import "DataReader.h"

#import "DataReaderDelegate.h"
#import "RDPointAnnotation.h"
#import "RDUtils.h"

#import <MapKit/MapKit.h>

#define BATCH_COUNT 500
#define DELAY_BETWEEN_BATCHES 0.3

@interface DataReader()

@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSString *filterOnStateCode; // two letter lower case state code -- if non-nil, will only include annotations for this state


@end

@implementation DataReader

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        
//    }
//    
//    return self;
//}


- (instancetype)initWithState:(NSString *)state
{
    self = [super init];
    if (self) {
        if (state != nil){
            _filterOnStateCode = [state lowercaseString];
           
        }
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}


- (void)startReadingTestData{
    
    // Parse on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // Bottom left
        MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
        annotation0.coordinate = CLLocationCoordinate2DMake(30.254695, -97.832359);
        
        // Top right
        MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
        annotation1.coordinate = CLLocationCoordinate2DMake(30.254695, -97.932311);
        MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
        annotation2.coordinate = CLLocationCoordinate2DMake(30.254695, -97.732322);
        MKPointAnnotation *annotation3 = [[MKPointAnnotation alloc] init];
        annotation3.coordinate = CLLocationCoordinate2DMake(30.254695, -97.632333);
        MKPointAnnotation *annotation4 = [[MKPointAnnotation alloc] init];
        annotation4.coordinate = CLLocationCoordinate2DMake(30.254695, -97.532344);
        MKPointAnnotation *annotation5 = [[MKPointAnnotation alloc] init];
        annotation5.coordinate = CLLocationCoordinate2DMake(30.254695, -97.432355);
        
        NSArray *annotations = @[annotation0, annotation1, annotation2, annotation3, annotation4, annotation5];
        // Dispatch remaining annotations
        [self dispatchAnnotations:annotations];
    });


    
}

/**
 
 Indexes of columns for riverList.txt: tab delimited text file
 
 // Display Name (0) | Latitude (1) | Longitude (2) | Gauge Count (3) | Agency Code (4) | Site Id (5) | StateCode (6)
 
 */
- (void)startReadingUSGSRiverData:(BOOL)shouldFilterNumbericSites{
    
    // Parse on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *file = [NSBundle.mainBundle pathForResource:@"riverList" ofType:@"txt"];
        NSArray *lines = [[NSString stringWithContentsOfFile:file encoding:NSASCIIStringEncoding error:nil] componentsSeparatedByString:@"\n"];
        
        NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:BATCH_COUNT];
        for (NSString *line in lines) {
            NSString *trimmedLine = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            if (trimmedLine.length > 0) {
                
                // Convert CSV into annotation object
                RDPointAnnotation *annotation = [[RDPointAnnotation alloc] init];
                
                NSArray *components = [line componentsSeparatedByString:@"\t"];
                
                if (self.filterOnStateCode != nil){
                    NSString *stateFilter = self.filterOnStateCode;
                    NSString *currState = [[components[6] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] lowercaseString];

                    if (![stateFilter isEqualToString:currState]){
                        continue; // don't include this state
                    }
                }
                
                annotation.coordinate = CLLocationCoordinate2DMake([components[1] doubleValue], [components[2] doubleValue]);
                annotation.title = [components[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                
                annotation.siteId = [components[5] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                annotation.numGauges = [components[3] integerValue];
                annotation.siteCode = [components[4] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                
                if (shouldFilterNumbericSites && [RDUtils hasLeadingNumberInString:annotation.title]){
                    continue;
                }
                
                [annotations addObject:annotation];
                
                if (annotations.count == BATCH_COUNT) {
                    // Dispatch batch of annotations
                    [self dispatchAnnotations:annotations];
                    [annotations removeAllObjects];
                }
            }
        }
        
        // Dispatch remaining annotations
        [self dispatchAnnotations:annotations];
    });

    
}


- (void)stopReadingData
{
    [self.operationQueue cancelAllOperations];
}
        
- (void)dispatchAnnotations:(NSArray *)annotations
{
    // Dispatch on main thread with some delay to simulate network requests
    NSArray *annotationsToDispatch = [annotations copy];
    [self.operationQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate dataReader:self addAnnotations:annotationsToDispatch];
        });
        [NSThread sleepForTimeInterval:DELAY_BETWEEN_BATCHES];
    }];
}

@end
