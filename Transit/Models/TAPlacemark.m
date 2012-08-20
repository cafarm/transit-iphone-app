//
//  TAPlacemark.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "TAPlacemark.h"

@interface TAPlacemark ()

@property (strong, nonatomic) CLPlacemark *clPlacemark;

@end

@implementation TAPlacemark

@synthesize isCurrentLocation = _isCurrentLocation;

@synthesize name = _name;
@synthesize location = _location;

@synthesize clPlacemark = _clPlacemark;

+ (TAPlacemark *)currentLocation
{
    return [[TAPlacemark alloc] initWithCLPlacemark:nil isCurrentLocation:YES];
}

- (id)initWithCLPlacemark:(CLPlacemark *)placemark isCurrentLocation:(BOOL)isCurrentLocation;
{
    self = [super init];
    if (self) {
        _clPlacemark = placemark;
        _isCurrentLocation = isCurrentLocation;
    }
    return self;
}

- (id)initWithCLPlacemark:(CLPlacemark *)placemark
{
    return [self initWithCLPlacemark:placemark isCurrentLocation:NO];
}

- (NSString *)name
{
    return self.clPlacemark.name;
}

- (CLLocation *)location
{
    return self.clPlacemark.location;
}

@end
