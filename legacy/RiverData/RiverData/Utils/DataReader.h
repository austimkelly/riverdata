//
//  DataReader.h
//  Macoun 2013
//
//  Created by Hoefele, Claus(choefele) on 20.09.13.
//  Copyright (c) 2013 Hoefele, Claus(choefele). All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataReaderDelegate;

@interface DataReader : NSObject

@property (nonatomic, weak) id<DataReaderDelegate> delegate;

/** Filter to only include a single specified state.
 @param state: two letter state code. If nil, no filtering applied.
 */
- (instancetype)initWithState:(NSString *)state;

- (void)startReadingTestData;
- (void)startReadingUSGSRiverData:(BOOL)shouldFilterNumbericSites;
- (void)stopReadingData;

@end
