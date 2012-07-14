//
//  TATravelDate.m
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATravelDate.h"

@implementation TATravelDate

@synthesize date;
@synthesize departAtOrArriveBy;

- (id)initWithDate:(NSDate *)aDate departureOrArrival:(TADepartAtOrArriveBy)departureOrArrival
{
    self = [super init];
    if (self) {
        date = aDate;
        departAtOrArriveBy = departureOrArrival;
    }
    return self;
}

@end
