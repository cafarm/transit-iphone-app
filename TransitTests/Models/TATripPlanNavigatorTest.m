//
//  TATripPlanNavigatorTest.m
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "TATripPlanNavigator.h"
#import "OTPTripPlan.h"
#import "OTPItinerary.h"
#import "OTPLeg.h"
#import "OTPPlace.h"
#import "TAStep.h"

@interface TATripPlanNavigatorTest : SenTestCase

@end

@implementation TATripPlanNavigatorTest

- (OTPTripPlan *)tripPlan
{
    OTPTripPlan *tripPlan = [[OTPTripPlan alloc] init];
    
    NSMutableArray *itineraries = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        OTPItinerary *itinerary = [[OTPItinerary alloc] init];
        
        NSMutableArray *legs = [NSMutableArray array];
        for (int j = 0; j < 10; j++) {
            OTPLeg *leg = [[OTPLeg alloc] init];
            leg.from = [[OTPPlace alloc] init];
            leg.to = [[OTPPlace alloc] init];
            
            if (j % 2 == 0) {
                leg.mode = OTPWalk;
            } else {
                leg.mode = OTPBus;
            }
            
            leg.itinerary = itinerary;
            [legs addObject:leg];
        }
        
        itinerary.tripPlan = tripPlan;
        itinerary.legs = legs;
        [itineraries addObject:itinerary];
    }
    
    tripPlan.itineraries = itineraries;
    
    return tripPlan;
}

- (void)testInitCurrentItinerary
{
    OTPTripPlan *tripPlan = [self tripPlan];
    TATripPlanNavigator *navigator = [[TATripPlanNavigator alloc] initWithTripPlan:tripPlan];
    STAssertEquals(navigator.currentItinerary, [tripPlan.itineraries objectAtIndex:0], nil);
}

- (void)testInitCurrentLeg
{
    OTPTripPlan *tripPlan = [self tripPlan];
    TATripPlanNavigator *navigator = [[TATripPlanNavigator alloc] initWithTripPlan:tripPlan];
    STAssertEquals(navigator.currentLeg, [((OTPItinerary *)[tripPlan.itineraries objectAtIndex:0]).legs objectAtIndex:0], nil);
}

- (void)testInitCurrentStep
{
    OTPTripPlan *tripPlan = [self tripPlan];
    OTPLeg *expectedLeg = [((OTPItinerary *)[tripPlan.itineraries objectAtIndex:0]).legs objectAtIndex:0];
    TATripPlanNavigator *navigator = [[TATripPlanNavigator alloc] initWithTripPlan:tripPlan];
    STAssertEquals(navigator.currentStep.leg, expectedLeg, nil);
    STAssertEquals(navigator.currentStep.place, expectedLeg.from, nil);
}

- (void)testMoveToItineraryWithIndex
{
    OTPTripPlan *tripPlan = [self tripPlan];
    TATripPlanNavigator *navigator = [[TATripPlanNavigator alloc] initWithTripPlan:tripPlan];
    [navigator moveToItineraryWithIndex:2];
    STAssertEquals(navigator.currentItinerary, [tripPlan.itineraries objectAtIndex:2], nil);
}

- (void)testNumberOfStepsInCurrentItinerary
{
    OTPTripPlan *tripPlan = [self tripPlan];
    TATripPlanNavigator *navigator = [[TATripPlanNavigator alloc] initWithTripPlan:tripPlan];
    STAssertEquals([navigator numberOfStepsInCurrentItinerary], 15u, nil);
}

- (void)testMoveToStepWithIndex
{
    OTPTripPlan *tripPlan = [self tripPlan];
    OTPLeg *expectedLeg = [((OTPItinerary *)[tripPlan.itineraries objectAtIndex:0]).legs objectAtIndex:9];
    TATripPlanNavigator *navigator = [[TATripPlanNavigator alloc] initWithTripPlan:tripPlan];
    TAStep *step = [navigator moveToStepWithIndex:14];
    STAssertEquals(step.leg, expectedLeg, nil);
    STAssertEquals(step.place, expectedLeg.to, nil);
}

@end
