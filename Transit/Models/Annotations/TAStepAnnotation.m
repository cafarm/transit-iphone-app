//
//  TAStepAnnotation.m
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStepAnnotation.h"
#import "TAStep.h"

@implementation TAStepAnnotation

@synthesize step = _step;
@synthesize direction = _direction;

- (id)initWithStep:(TAStep *)step direction:(TAStepAnnotationDirection)direction
{
    self = [super init];
    if (self) {
        _step = step;
        _direction = direction;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.step.place.coordinate;
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"%@", self.step.route];
}

@end
