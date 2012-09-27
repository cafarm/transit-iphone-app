//
//  TATransitStep.m
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATransitStep.h"
#import "OTPClient.h"
#import "NSDateFormatter+Transit.h"

@implementation TATransitStep

@synthesize mode = _mode;
@synthesize scheduledDateDescription = _scheduledDateDescription;
@synthesize detailsDescription = _detailsDescription;
@synthesize isArrival = _isArrival;

- (id)initWithLegs:(NSArray *)legs previousStep:(TAStep *)previousStep isArrival:(BOOL)isArrival
{
    self = [super initWithLegs:legs previousStep:previousStep];
    if (self) {
        _isArrival = isArrival;
    }
    return self;
}

- (OTPPlace *)place
{
    if (self.isArrival) {
        return ((OTPLeg *)[self.legs lastObject]).to;
    } else {
        return ((OTPLeg *)[self.legs objectAtIndex:0]).from;
    }
}

- (OTPLegTraverseMode)mode
{
    return self.place.leg.mode;
}

- (NSString *)route
{
    return ((OTPLeg *)[self.legs objectAtIndex:0]).route;
}

- (NSString *)headSign
{
    return self.place.leg.headsign;
}

- (NSString *)tripID
{
    return self.place.leg.tripID;
}

- (NSDate *)scheduledDate
{
    if (self.isArrival) {
        return ((OTPLeg *)[self.legs lastObject]).endTime;
    } else {
        return ((OTPLeg *)[self.legs objectAtIndex:0]).startTime;
    }
}

- (NSString *)scheduledDateDescription
{
    NSString *description;
    if (self.isArrival) {
        description = [NSString stringWithFormat:@"Arrives at %@", [[TAStep sharedDateFormatter] stringFromDate:self.scheduledDate]];
    } else {
        description = [NSString stringWithFormat:@"Departs at %@", [[TAStep sharedDateFormatter] stringFromDate:self.scheduledDate]];
    }
    return description;
}

- (NSString *)scheduledDateShortDescription
{
    return [[TAStep sharedDateFormatter] stringFromDate:self.scheduledDate];
}

- (NSString *)mainDescription
{
    NSString *description;
    if (self.isArrival) {
        description = [NSString stringWithFormat:@"Get off %@", self.route];
    } else {
        description = [NSString stringWithFormat:@"Take %@", self.route];
    }
    return description;
}

- (NSString *)detailsDescription
{
    NSString *description;
    if (self.isArrival) {
        description = [NSString stringWithFormat:@"At %@", self.place.name];
    } else {
        description = [NSString stringWithFormat:@"Towards %@", self.headSign];
    }
    return description;
}

@end
