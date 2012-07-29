//
//  TAPlaceAnnotation.m
//  Transit
//
//  Created by Mark Cafaro on 7/28/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAPlaceAnnotation.h"
#import "OTPPlace.h"

@implementation TAPlaceAnnotation

@synthesize place = _place;
@synthesize coordinate = _coordinate;

- (id)initWithPlace:(OTPPlace *)place
{
    self = [super init];
    if (self) {
        _place = place;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.place.latitude doubleValue], [self.place.longitude doubleValue]);
}

- (NSString *)title
{
    return self.place.name;
}

@end
