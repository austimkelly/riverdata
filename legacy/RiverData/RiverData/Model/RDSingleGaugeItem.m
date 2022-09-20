//
//  RDSingleGaugeItem.m
//  RiverData
//
//  Created by Tim Myxer on 9/29/13.
//  Copyright (c) 2013 Tim Kelly. All rights reserved.
//

#import "RDSingleGaugeItem.h"

@implementation RDSingleGaugeItem

@synthesize value = _value;
@synthesize name = _name;
@synthesize dateString = _dateString;
@synthesize timeSeriesId = _timeSeriesId;
@synthesize parentGaugeId = _parentGaugeId;
@synthesize unitAbbreviation = _unitAbbreviation;
@synthesize longitude = _longitude;
@synthesize latitude = _latitude;

- (id)initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];
    
    RDLog(@"Dict: %@", dict);
    
    NSArray *values = [dict objectForKey:@"values"];
    
    if (values && [values count] > 0){
        
        NSDictionary *itemValue = [values objectAtIndex:0];
        if (itemValue){
            
            NSArray *innerValue = [itemValue objectForKey:@"value"];
            if (innerValue && [innerValue count] > 0){
                NSDictionary *innerValDict = [innerValue objectAtIndex:0];
                if (innerValDict){
                    self.value = [innerValDict objectForKey:@"value"];
                    self.dateString = [innerValDict objectForKey:@"dateTime"];
                }
            }
            
            NSDictionary *sourceInfo = [dict objectForKey:@"variable"];
            self.name = [sourceInfo objectForKey:@"variableDescription"];
            NSArray *variableCodeArray = [sourceInfo objectForKey:@"variableCode"];
            if (variableCodeArray){
                NSDictionary *variableCodeDict = [variableCodeArray objectAtIndex:0];
                self.timeSeriesId = [variableCodeDict objectForKey:@"value"];
            }
            NSDictionary  *unit = [sourceInfo objectForKey:@"unit"];
            if (unit){
                self.unitAbbreviation = [unit objectForKey:@"unitCode"];
            }
        }
        
        NSDictionary *sourceInfo = [dict objectForKey:@"sourceInfo"];
        if (sourceInfo){
            
            self.parentGaugeId = [[[sourceInfo objectForKey:@"siteCode"] objectAtIndex:0] objectForKey:@"value"];
            if ([sourceInfo objectForKey:@"geoLocation"] != nil){
                NSDictionary *geo1 = [sourceInfo objectForKey:@"geoLocation"];
                if (geo1){
                    NSDictionary *geo2 = [geo1 objectForKey:@"geogLocation"];
                    if (geo2){
                        self.longitude = [[geo2 objectForKey:@"longitude"] doubleValue];
                        self.latitude = [[geo2 objectForKey:@"latitude"] doubleValue];
                        
                    }
                }
            }
        }
    }
    
    return self;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"GAUGE ITEM: Name:%@, Value:%@, Date:%@", _name, _value, _dateString];
    
}

- (BOOL)isValidData{
    
    BOOL isValid = YES;
    
    if (self.value == nil || [self.value length] == 0) isValid = NO;
    if (self.name == nil || [self.name length] == 0) isValid = NO;
    if (self.timeSeriesId == nil || [self.timeSeriesId length] == 0) isValid = NO;
    if (self.parentGaugeId == nil || [self.parentGaugeId length] == 0) isValid = NO;
    
    return isValid;
}

@end
