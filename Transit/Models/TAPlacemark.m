//
//  TAPlacemark.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "TAPlacemark.h"

@implementation TAPlacemark

@synthesize name = _name;
@synthesize location = _location;
@synthesize isCurrentLocation = _isCurrentLocation;

+ (TAPlacemark *)currentLocation
{
    return [[TAPlacemark alloc] initWithName:@"Current Location" location:nil isCurrentLocation:YES];
}

+ (TAPlacemark *)placemarkWithCLPlacemark:(CLPlacemark *)clPlacemark
{
    return [[TAPlacemark alloc] initWithName:clPlacemark.name location:clPlacemark.location isCurrentLocation:NO];
}

- (id)initWithName:(NSString *)name location:(CLLocation *)location isCurrentLocation:(BOOL)isCurrentLocation;
{
    self = [super init];
    if (self) {
        _name = name;
        _location = location;
        _isCurrentLocation = isCurrentLocation;
    }
    return self;
}

@end
