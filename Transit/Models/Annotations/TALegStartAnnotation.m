//
//  TALegStartAnnotation.m
//  Transit
//
//  Created by Mark Cafaro on 8/2/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALegStartAnnotation.h"
#import "OTPLeg.h"
#import "OTPPlace.h"

@implementation TALegStartAnnotation

@synthesize leg = _leg;

@synthesize coordinate = _coordinate;

- (id)initWithLeg:(OTPLeg *)leg
{
    self = [super init];
    if (self) {
        _leg = leg;
        _coordinate = CLLocationCoordinate2DMake([leg.from.latitude doubleValue], [leg.from.longitude doubleValue]);
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (NSString *)title
{
    return self.leg.from.name;
}

@end
