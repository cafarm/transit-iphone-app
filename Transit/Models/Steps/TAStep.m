//
//  TAStep.m
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStep.h"
#import "TAWalkStep.h"
#import "TATransitStep.h"
#import "OTPClient.h"

@implementation TAStep

@synthesize legs = _legs;
@synthesize place = _place;
@synthesize from = _from;
@synthesize fromLeg = _fromLeg;
@synthesize to = _to;
@synthesize toLeg = _toLeg;
@synthesize route = _route;
@synthesize distance = _distance;
@synthesize duration = _duration;
@synthesize isDestination = _isDestination;
@synthesize boundingMapRect = _boundingMapRect;

@synthesize previousStep = _previousStep;

+ (NSArray *)stepsWithItinerary:(OTPItinerary *)itinerary
{
    // Init for max capacity
    NSMutableArray *steps = [NSMutableArray arrayWithCapacity:([itinerary.legs count] * 2)];
        
    for (int legIndex = 0; legIndex < [itinerary.legs count]; legIndex++) {
        OTPLeg *currentLeg = [itinerary.legs objectAtIndex:legIndex];
        
        TAStep *fromStep = nil;
        if (!currentLeg.isInterlinedWithPreviousLeg) {
            // We're on a new set of legs, we always need a "from" step in that case
            if (currentLeg.mode == OTPLegTraverseModeWalk) {
                fromStep = [[TAWalkStep alloc] initWithLegs:[NSMutableArray arrayWithObject:currentLeg]
                                              isDestination:NO
                                               previousStep:[steps lastObject]];
            } else {
                fromStep = [[TATransitStep alloc] initWithLegs:[NSMutableArray arrayWithObject:currentLeg]
                                                 isDestination:NO
                                                     isArrival:NO
                                                  previousStep:[steps lastObject]];
            }
            
            [steps addObject:fromStep];
        } else {
            // We're in an interlined leg where we just want to add our leg to the original "from" step for this set 
            fromStep = [steps lastObject];
            [(NSMutableArray *)fromStep.legs addObject:currentLeg];
        }
        
        OTPLeg *nextLeg = nil;
        if (legIndex + 1 < [itinerary.legs count]) {
            nextLeg = [itinerary.legs objectAtIndex:legIndex + 1];
        }
        
        // If we're on the last leg or we're ending a leg set and it wasn't a walking leg set, add a "to" step
        if (nextLeg == nil || (!nextLeg.isInterlinedWithPreviousLeg && currentLeg.mode != OTPLegTraverseModeWalk)) {
            
            TAStep *toStep = nil;
            if (currentLeg.mode == OTPLegTraverseModeWalk) {
                toStep = [[TAWalkStep alloc] initWithLegs:fromStep.legs
                                            isDestination:(nextLeg == nil)
                                             previousStep:[steps lastObject]];
            } else {
                toStep = [[TATransitStep alloc] initWithLegs:fromStep.legs
                                               isDestination:(nextLeg == nil)
                                                   isArrival:YES
                                                previousStep:[steps lastObject]];
            }
            [steps addObject:toStep];
        }
    }
    return steps;
}

- (id)initWithLegs:(NSMutableArray *)legs isDestination:(BOOL)isDestination previousStep:(TAStep *)previousStep
{
    self = [super init];
    if (self) {
        _legs = legs;
        _isDestination = isDestination;
        _previousStep = previousStep;
        
        // We'll lazy load the bounding map rect
        _boundingMapRect = MKMapRectNull;
    }
    return self;
}

- (OTPPlace *)place
{
    // Override me!
    return nil;
}

- (OTPPlace *)from
{
    return self.fromLeg.from;
}

- (OTPLeg *)fromLeg
{
    return (OTPLeg *)[self.legs objectAtIndex:0];
}

- (OTPPlace *)to
{
    return self.toLeg.to;
}

- (OTPLeg *)toLeg
{
    return (OTPLeg *)[self.legs lastObject];
}

- (NSString *)route
{
    return self.fromLeg.route;
}

- (NSString *)tripShortName
{
    return self.fromLeg.tripShortName;
}

- (NSString *)headSign
{
    return self.fromLeg.headsign;
}

- (NSString *)tripID
{
    return self.fromLeg.tripID;
}

- (NSNumber *)distance
{
    if (_distance == nil) {
        NSUInteger distance = 0;
        for (OTPLeg *leg in self.legs) {
            distance += [leg.distance unsignedIntegerValue];
        }
        _distance = [NSNumber numberWithUnsignedInteger:distance];
    }
    return _distance;
}

- (NSNumber *)duration
{
    if (_duration == nil) {
        NSUInteger duration = 0;
        for (OTPLeg *leg in self.legs) {
            duration += [leg.duration unsignedIntegerValue];
        }
        _duration = [NSNumber numberWithUnsignedInteger:duration];
    }
    return _duration;
}

- (MKMapRect)boundingMapRect
{
    if (MKMapRectIsNull(_boundingMapRect)) {
        for (OTPLeg *leg in self.legs) {
            if (MKMapRectIsNull(_boundingMapRect)) {
                _boundingMapRect = [leg boundingMapRect];
            } else {
                _boundingMapRect = MKMapRectUnion(_boundingMapRect, [leg boundingMapRect]);
            }
        }
    }
    return _boundingMapRect;
}

@end
