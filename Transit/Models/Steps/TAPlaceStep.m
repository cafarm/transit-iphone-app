//
//  TAPlaceStep.m
//  Transit
//
//  Created by Mark Cafaro on 9/26/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAPlaceStep.h"

@implementation TAPlaceStep

@synthesize isDestination = _isDestination;

- (id)initWithLegs:(NSArray *)legs previousStep:(TAStep *)previousStep isDestination:(BOOL)isDestination
{
    self = [super initWithLegs:legs previousStep:previousStep];
    if (self) {
        _isDestination = isDestination;
    }
    return self;
}

- (OTPPlace *)place
{
    if (self.isDestination) {
        return ((OTPLeg *)[self.legs lastObject]).to;
    } else {
        return ((OTPLeg *)[self.legs objectAtIndex:0]).from;
    }
}

- (NSString *)placeDescription
{
    return self.place.name;
}

- (NSString *)mainDescription
{
    if (self.isDestination) {
        return [NSString stringWithFormat:@"Arrive at %@", self.place.name];
    } else {
        return self.place.name;
    }
}

- (NSDate *)startDate
{
    OTPLeg *firstTransitLeg = nil;
    for (OTPLeg *leg in self.legs) {
        if (leg.mode != OTPLegTraverseModeWalk) {
            firstTransitLeg = leg;
            break;
        }
    }
    
    return firstTransitLeg.startTime;
}

- (NSString *)startDateDescription
{
    return [NSString stringWithFormat:@"Departs at %@", [[TAStep sharedDateFormatter] stringFromDate:self.startDate]];
}

- (NSDate *)endDate
{
    OTPLeg *lastTransitLeg = nil;
    for (OTPLeg *leg in [self.legs reverseObjectEnumerator]) {
        if (leg.mode != OTPLegTraverseModeWalk) {
            lastTransitLeg = leg;
            break;
        }
    }
    
    return lastTransitLeg.endTime;
}

- (NSString *)endDateDescription
{
    return [NSString stringWithFormat:@"Arrives at %@", [[TAStep sharedDateFormatter] stringFromDate:self.endDate]];
}

@end
