//
//  RiverDataTests.m
//  RiverDataTests
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RDGaugeModel.h"
#import "USGSHTTPSessionManager.h"

// 3rd Party
#import "TestSemaphor.h"
#import "CHCSVParser.h"

@interface RiverDataTests : XCTestCase

@end

@implementation RiverDataTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testReadStateGaugesAFNetworking{
    
    NSArray *twoLetterStateNames = [[NSArray alloc] initWithObjects:@"AL",
                                    @"AK", @"AZ", @"AR", @"CA",
                                    @"CO", @"CT", @"DE", @"DC",@"FL",@"GA",@"HI",
                                    @"ID",@"IL",@"IN",@"IA",@"KS",@"KY",@"LA",@"ME",@"MD",@"MA",@"MI",@"MN",@"MS",@"MO",
                                    @"MT",@"NE",@"NV",@"NH",@"NJ",@"NM",@"NY",@"NC",@"ND",@"OH",@"OK",@"OR",@"PA",@"PR",@"RI",
                                    @"SC",@"SD",@"TN",@"TX",@"UT",@"VT",@"VA",@"WA",@"WV",@"WI",@"WY", nil];
    
    __block NSString *csvContent = @"";
    
    for (NSString *stateCode in twoLetterStateNames){
        
        USGSHTTPSessionManager *apiMan = [USGSHTTPSessionManager apiInstance];
        
        [apiMan fetchStateGauges:stateCode withFilterNumericSites:NO withCompletionHandler:^(BOOL success, NSArray *gaugeModels) {
            // success
            if (success){

                for (NSArray *gaugeArray in gaugeModels){

                    RDGaugeModel *topItem = gaugeArray[0];

                    // CSV Columns are:
                    // Display Name | Latitude | Longitude | Gauge Count | Agency Code | Site Id | StateCode

                    NSString *csvLine = [NSString stringWithFormat:@"%@\t%f\t%f\t%lu\t%@\t%@\t%@\n", topItem.riverDisplayName, [topItem.latitute floatValue], [topItem.longitude floatValue], (unsigned long)[gaugeArray count], topItem.agencyCode, topItem.siteId, stateCode];

                    csvContent = [csvContent stringByAppendingString:csvLine];

                    RDLog(@"%@", csvLine);
                }

                // pass
                if (gaugeModels == nil || [gaugeModels count] == 0){
                    XCTFail(@"Gauge Models Failed for State: %@", stateCode);
                }
                
            } else {
                XCTFail(@"TEST FAILURE FOR STATE: %@", stateCode);
            }
            
            [[TestSemaphor sharedInstance] lift:stateCode];

        } withErrorHandler:^(NSError *error) {
            // error
            XCTFail(@"TEST FAILURE: %@", error.localizedDescription);
        }];

        
        [[TestSemaphor sharedInstance] waitForKey:stateCode];
        
    }
    
    NSError *error;
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"riverList.txt"];
    [csvContent writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    RDLog(@"River List Written to: %@", file);
    
    if (error){
        XCTFail(@"Error writing CSV:%@", error.localizedDescription);
    }
    
}

@end
