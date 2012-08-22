//
//  TATransitStep.m
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATransitStep.h"

@implementation TATransitStep

@synthesize mode = _mode;
@synthesize tripShortName = _tripShortName;
@synthesize headSign = _headSign;
@synthesize tripID = _tripID;
@synthesize scheduledDate = _scheduledDate;
@synthesize isArrival = _isArrival;

- (id)initWithLegs:(NSArray *)legs isDestination:(BOOL)isDestination isArrival:(BOOL)isArrival previousStep:(TAStep *)previousStep
{
    self = [super initWithLegs:legs isDestination:isDestination previousStep:previousStep];
    if (self) {
        _isArrival = isArrival;
    }
    return self;
}

- (OTPPlace *)place
{
    if (self.isArrival) {
        return self.to;
    } else {
        return self.from;
    }
}

- (OTPLeg *)placeLeg
{
    return self.place.leg;
}

- (OTPLegTraverseMode)mode
{
    return self.placeLeg.mode;
}

- (NSString *)tripShortName
{
    return self.placeLeg.tripShortName;
}

- (NSString *)headSign
{
    return self.placeLeg.headsign;
}

- (NSString *)tripID
{
    return self.placeLeg.tripID;
}

- (NSDate *)scheduledDate
{
    if (self.isArrival) {
        return self.to.arrival;
    } else {
        return self.from.departure;
    }
}

@end
