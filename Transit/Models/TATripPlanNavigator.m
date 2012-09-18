//
//  TATripPlanNavigator.m
//  Transit
//
//  Created by Mark Cafaro on 8/6/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATripPlanNavigator.h"
#import "TAStep.h"
#import "OTPClient.h"

@interface TATripPlanNavigator ()

@property (readwrite, strong, nonatomic) TAStep *currentStep;
@property (readwrite, strong, nonatomic) NSArray *stepsInCurrentItinerary;

@end


@implementation TATripPlanNavigator

@synthesize tripPlan = _tripPlan;

@synthesize currentItinerary = _currentItinerary;
@synthesize currentItineraryIndex = _currentItineraryIndex;
@synthesize itineraries = _itineraries;

@synthesize currentStep = _currentStep;
@synthesize currentStepIndex = _currentStepIndex;
@synthesize stepsInCurrentItinerary = _stepsInCurrentItinerary;

- (id)initWithTripPlan:(OTPTripPlan *)tripPlan
{
    self = [super init];
    if (self) {
        _tripPlan = tripPlan;
        
        _stepsInCurrentItinerary = [TAStep stepsWithItinerary:[tripPlan.itineraries objectAtIndex:0]];
        _currentStep = [_stepsInCurrentItinerary objectAtIndex:0];
    }
    return self;
}

- (void)setTripPlan:(OTPTripPlan *)tripPlan
{
    _tripPlan = tripPlan;
    [self moveToItineraryWithIndex:0];
}

- (OTPItinerary *)currentItinerary
{
    return self.currentStep.place.leg.itinerary;
}

- (NSUInteger)currentItineraryIndex
{
    return [self.itineraries indexOfObject:self.currentItinerary];
}

- (NSArray *)itineraries
{
    return self.tripPlan.itineraries;
}

- (OTPItinerary *)moveToItineraryWithIndex:(NSUInteger)index
{    
    OTPItinerary *itinerary = [self.tripPlan.itineraries objectAtIndex:index];
    
    // Create steps for new itinerary
    self.stepsInCurrentItinerary = [TAStep stepsWithItinerary:itinerary];
    
    // Set current step to first step in new itinerary 
    self.currentStep = [self.stepsInCurrentItinerary objectAtIndex:0];
    
    return itinerary;
}

- (NSUInteger)currentStepIndex
{
    return [self.stepsInCurrentItinerary indexOfObject:self.currentStep];
}

- (NSUInteger)numberOfStepsInCurrentItinerary
{
    return [self.stepsInCurrentItinerary count];
}

- (TAStep *)stepWithIndex:(NSInteger)index
{
    return [self.stepsInCurrentItinerary objectAtIndex:index];
}

- (TAStep *)moveToStepWithIndex:(NSInteger)index
{
    self.currentStep = [self.stepsInCurrentItinerary objectAtIndex:index];
    
    return self.currentStep;
}

- (void)moveToStep:(TAStep *)step
{
    NSAssert([self.stepsInCurrentItinerary containsObject:step], @"Step must be in current itinerary");
    
    self.currentStep = step;
}

@end
