//
//  TAStep.m
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStep.h"
#import "TAPlaceStep.h"
#import "TAWalkStep.h"
#import "TATransitStep.h"
#import "OTPClient.h"

@interface TAStep ()
    @property (readonly, nonatomic) NSNumber *distance;
    @property (readonly, nonatomic) NSNumber *duration;
@end


@implementation TAStep

@synthesize legs = _legs;
@synthesize place = _place;
@synthesize mainDescription = _mainDescription;
@synthesize distanceDescription = _distanceDescription;
@synthesize durationDescription = _durationDescription;
@synthesize boundingMapRect = _boundingMapRect;

@synthesize distance = _distance;
@synthesize duration = _duration;

@synthesize previousStep = _previousStep;

+ (NSArray *)stepsWithItinerary:(OTPItinerary *)itinerary
{
    // Init for max capacity
    NSMutableArray *steps = [NSMutableArray arrayWithCapacity:([itinerary.legs count] * 2 + 2)];
    
    // Add a start place step
    TAPlaceStep *startStep = [[TAPlaceStep alloc] initWithLegs:itinerary.legs previousStep:nil isDestination:NO];
    [steps addObject:startStep];
        
    for (int legIndex = 0; legIndex < [itinerary.legs count]; legIndex++) {
        OTPLeg *currentLeg = [itinerary.legs objectAtIndex:legIndex];
        
        TAStep *fromStep = nil;
        if (!currentLeg.isInterlinedWithPreviousLeg) {
            // We're on a new set of legs, we always need a "from" step in that case
            if (currentLeg.mode == OTPLegTraverseModeWalk) {
                fromStep = [[TAWalkStep alloc] initWithLegs:[NSMutableArray arrayWithObject:currentLeg]
                                               previousStep:[steps lastObject]];
            } else {
                fromStep = [[TATransitStep alloc] initWithLegs:[NSMutableArray arrayWithObject:currentLeg]
                                                  previousStep:[steps lastObject]
                                                     isArrival:NO];
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
        
        // If we're on the last leg or we're ending a leg set and we're not on a walking leg, add a "to" step
        if ((nextLeg == nil || !nextLeg.isInterlinedWithPreviousLeg) && currentLeg.mode != OTPLegTraverseModeWalk) {
            
            TAStep *toStep = [[TATransitStep alloc] initWithLegs:fromStep.legs
                                                    previousStep:[steps lastObject]
                                                       isArrival:YES];
            [steps addObject:toStep];
        }
    }
    
    // Add a end place step
    TAPlaceStep *endStep = [[TAPlaceStep alloc] initWithLegs:itinerary.legs previousStep:[steps lastObject] isDestination:YES];
    [steps addObject:endStep];
    
    return steps;
}

+ (NSDateFormatter *)sharedDateFormatter
{
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return dateFormatter;
}

- (id)initWithLegs:(NSMutableArray *)legs previousStep:(TAStep *)previousStep
{
    self = [super init];
    if (self) {
        _legs = legs;
        _previousStep = previousStep;
    }
    return self;
}

- (OTPPlace *)place
{
    // Override me!
    return nil;
}

- (NSString *)mainDescription
{
    // Override me!
    return nil;
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

- (NSString *)distanceDescription
{
    return [NSString stringWithFormat:@"%.01f miles", [self.distance floatValue] * 0.000621371f];
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

- (NSString *)durationDescription
{
    NSInteger duration = [self.duration unsignedIntValue] / 1000 / 60;
    return [NSString stringWithFormat:@"%u mins", duration];
}

- (MKMapRect)boundingMapRect
{
    if (MKMapRectIsEmpty(_boundingMapRect)) {
        for (OTPLeg *leg in self.legs) {
            if (MKMapRectIsEmpty(_boundingMapRect)) {
                _boundingMapRect = [leg boundingMapRect];
            } else {
                _boundingMapRect = MKMapRectUnion(_boundingMapRect, [leg boundingMapRect]);
            }
        }
    }
    return _boundingMapRect;
}

@end
