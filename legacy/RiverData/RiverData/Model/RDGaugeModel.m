//
//  RDGaugeModel.m
//  RiverData
//
//  Created by Tim Kelly on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import "RDGaugeModel.h"

@implementation RDGaugeModel

@synthesize riverInternalName = _riverInternalName;
@synthesize riverDisplayName = _riverDisplayName;
@synthesize latitute = _latitute;
@synthesize longitude = _longitude;
@synthesize siteId = _siteId;
@synthesize agencyCode = _agencyCode;
@synthesize gaugeDescription = _gaugeDescription;
@synthesize gaugeId = _gaugeId;

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    if (self){
        
        self.riverInternalName = [dict objectForKey:@"name"];
        
        NSDictionary *sourceInfo = [dict objectForKey:@"sourceInfo"];
        if (sourceInfo){
            
            self.riverDisplayName = [sourceInfo objectForKey:@"siteName"];
            
            NSDictionary *geoDict = [[sourceInfo objectForKey:@"geoLocation"] objectForKey:@"geogLocation"];
            if (geoDict){
                
                self.longitude = [NSNumber numberWithFloat:[[geoDict objectForKey:@"longitude"] floatValue]];
                self.latitute = [NSNumber numberWithFloat:[[geoDict objectForKey:@"latitude"] floatValue]];
                
            }
            
            NSArray *siteCodeArray = [sourceInfo objectForKey:@"siteCode"];
            if (siteCodeArray && [siteCodeArray count] > 0){
                
                NSDictionary *siteCodeDict = [siteCodeArray objectAtIndex:0];
                if (siteCodeDict){
                    self.siteId = [siteCodeDict objectForKey:@"value"];
                    self.agencyCode = [siteCodeDict objectForKey:@"agencyCode"];
                }
                
            }
            
            NSDictionary *variableDict = [dict objectForKey:@"variable"];
            if (variableDict){
                
                NSArray *variableCodeArray = [variableDict objectForKey:@"variableCode"];
                if (variableCodeArray != nil && [variableCodeArray count] > 0){
                    
                    NSDictionary *tempDict = [variableCodeArray objectAtIndex:0];
                    self.gaugeId = [tempDict objectForKey:@"value"];
                    
                    self.gaugeDescription = [variableDict objectForKey:@"variableDescription"];
                    
                }
                
                
            }
            
        }
        
    }
    
    return self;
}

- (BOOL)isValidModel{
    
    BOOL isValid = YES;
    
    if (self.riverDisplayName == nil || [self.riverDisplayName length] == 0) isValid = NO;
    
    if (self.siteId == nil || [self.riverDisplayName length] == 0) isValid = NO;
    
    return isValid;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"GAUGE: Display Name:%@, Site ID:%@, Lat:%f, Long:%f Gauge ID:%@, Gauge Display Name:%@", self.riverDisplayName, self.siteId, [self.latitute doubleValue], [self.longitude doubleValue], self.gaugeId, self.gaugeDescription];
    
}

@end
