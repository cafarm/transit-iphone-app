//
//  TALeg.m
//  Transit
//
//  Created by Mark Cafaro on 7/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALeg.h"

@implementation TALeg

@synthesize travelMode=_travelMode;
@synthesize distance=_distance;

- (id)initWithTravelMode:(TATravelMode)travelMode distance:(float)distance
{
    self = [super init];
    if (self) {
        _travelMode = travelMode;
        _distance = distance;
    }
    return self;
}

- (NSString *)description
{
    NSString *modeString;
    switch (self.travelMode) {
        case TAWalk:
            modeString = @"Walk";
            break;
        case TABus:
            modeString = @"Bus";
            break;
        case TARail:
            modeString = @"Rail";
            break;
        case TAFerry:
            modeString = @"Ferry";
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %i", modeString, self.distance];
}

@end
