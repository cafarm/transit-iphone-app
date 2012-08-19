//
//  TAPlacemark.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAPlacemark.h"

@implementation TAPlacemark

@synthesize isCurrentLocation = _isCurrentLocation;

+ (TAPlacemark *)currentLocation
{
    return [[TAPlacemark alloc] initCurrentLocation];
}

- (id)initCurrentLocation
{
    self = [super init];
    if (self) {
        _isCurrentLocation = YES;
    }
    return self;
}

@end
