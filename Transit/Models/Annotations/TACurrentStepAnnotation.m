//
//  TACurrentStepAnnotation.m
//  Transit
//
//  Created by Mark Cafaro on 8/11/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACurrentStepAnnotation.h"
#import "TAStep.h"

@implementation TACurrentStepAnnotation

@synthesize step = _step;

@synthesize coordinate = _coordinate;

- (id)initWithStep:(TAStep *)step
{
    self = [super init];
    if (self) {
        _step = step;
        _coordinate = step.coordinate;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

@end
