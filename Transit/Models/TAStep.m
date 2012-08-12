//
//  TAStep.m
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStep.h"
#import "OTPItinerary.h"
#import "OTPPlace.h"

@interface TAStep ()

@property (readwrite, strong, nonatomic) NSMutableArray *legs;

@end


@implementation TAStep

@synthesize legs = _legs;
@synthesize place = _place;
@synthesize placeLeg = _placeLeg;

@synthesize fromOrTo = _fromOrTo;

@synthesize previousStep = _previousStep;

@synthesize boundingMapRect = _boundingMapRect;

+ (NSArray *)stepsWithItinerary:(OTPItinerary *)itinerary
{
    // Init for max capacity
    NSMutableArray *steps = [NSMutableArray arrayWithCapacity:([itinerary.legs count] * 2)];
        
    for (int legIndex = 0; legIndex < [itinerary.legs count]; legIndex++) {
        OTPLeg *currentLeg = [itinerary.legs objectAtIndex:legIndex];
        
        TAStep *fromStep = nil;
        if (!currentLeg.isInterlinedWithPreviousLeg) {
            // We're on a new set of legs, we always need a "from" step in that case
            fromStep = [[TAStep alloc] initWithLegs:[NSMutableArray arrayWithObject:currentLeg]
                                           fromOrTo:TAFrom
                                       previousStep:[steps lastObject]];
            [steps addObject:fromStep];
        } else {
            // We're in an interlined leg where we just want to add our leg to the original "from" step for this set 
            fromStep = [steps lastObject];
            [fromStep.legs addObject:currentLeg];
        }
        
        OTPLeg *nextLeg = nil;
        if (legIndex + 1 < [itinerary.legs count]) {
            nextLeg = [itinerary.legs objectAtIndex:legIndex + 1];
        }
        
        // If we're on the last leg or we're ending a leg set and it wasn't a walking leg set, add a "to" step
        if (nextLeg == nil || (!nextLeg.isInterlinedWithPreviousLeg && currentLeg.mode != OTPWalk)) {
            
            TAStep *toStep = [[TAStep alloc] initWithLegs:fromStep.legs
                                                 fromOrTo:TATo
                                             previousStep:[steps lastObject]];
            [steps addObject:toStep];
        }
    }
    return steps;
}

- (id)initWithLegs:(NSMutableArray *)legs fromOrTo:(TAFromOrTo)fromOrTo previousStep:(TAStep *)previousStep
{
    self = [super init];
    if (self) {
        _legs = legs;
        _fromOrTo = fromOrTo;
        
        _previousStep = previousStep;
        
        _boundingMapRect = MKMapRectNull;
    }
    return self;
}

// The leg that contains the actual step's place
- (OTPLeg *)placeLeg
{
    if (_placeLeg == nil) {
        if (self.fromOrTo == TAFrom) {
            return [self.legs objectAtIndex:0];
        } else {
            return [self.legs lastObject];
        }
    }
    return _placeLeg;
}

- (OTPPlace *)place
{
    if (_place == nil) {
        if (self.fromOrTo == TAFrom) {
            return self.placeLeg.from;
        } else {
            return self.placeLeg.to;
        }
    }
    return _place;
}

- (OTPTraverseMode)mode
{
    return self.placeLeg.mode;
}

- (NSString *)route
{
    return self.placeLeg.route;
}

- (NSString *)fromRoute
{
    return ((OTPLeg *)[self.legs objectAtIndex:0]).route;
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

- (NSNumber *)distance
{
    return self.placeLeg.distance;
}

- (NSNumber *)duration
{
    return self.placeLeg.duration;
}

- (NSString *)placeName
{
    return self.place.name;
}

- (OTPAgencyAndID *)stopID
{
    return self.place.stopID;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.place.coordinate;
}

- (NSDate *)scheduledArrival
{
    return self.place.arrival;
}

- (NSDate *)scheduledDeparture
{
    return self.place.departure;
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
