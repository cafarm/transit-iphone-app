//
//  TATravelDate.m
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATravelDate.h"

@implementation TATravelDate

@synthesize date=_date;
@synthesize departAtOrArriveBy=_departAtOrArriveBy;

- (id)initWithDate:(NSDate *)date departAtOrArriveBy:(TADepartAtOrArriveBy)departAtOrArriveBy
{
    self = [super init];
    if (self) {
        _date = date;
        _departAtOrArriveBy = departAtOrArriveBy;
    }
    return self;
}

@end
