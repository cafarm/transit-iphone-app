//
//  TAStepAnnotation.m
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStepAnnotation.h"
#import "TAStep.h"
#import "TAPlaceStep.h"
#import "TAWalkStep.h"
#import "TATransitStep.h"

@implementation TAStepAnnotation

@synthesize step = _step;
@synthesize facing = _facing;

- (id)initWithStep:(TAStep *)step direction:(TAStepAnnotationFacing)facing
{
    self = [super init];
    if (self) {
        _step = step;
        _facing = facing;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.step.place.coordinate;
}

- (NSString *)title
{
    NSString *title;
    if ([self.step isKindOfClass:[TAPlaceStep class]]) {
        title = ((TAPlaceStep *)self.step).placeDescription;
    } else {
        title = self.step.mainDescription;
    }
    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle = nil;
    if ([self.step isKindOfClass:[TAWalkStep class]]) {
        subtitle = ((TAWalkStep *)self.step).distanceDescription;
    } else if ([self.step isKindOfClass:[TATransitStep class]]) {
        subtitle = ((TATransitStep *)self.step).scheduledDateDescription;
    }
    return subtitle;
}

@end
