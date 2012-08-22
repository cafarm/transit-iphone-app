//
//  TATripPlanNavigator.h
//  Transit
//
//  Created by Mark Cafaro on 8/6/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTPTripPlan;
@class OTPItinerary;
@class OTPLeg;
@class TAStep;

@interface TATripPlanNavigator : NSObject

// Inits at the first itinerary, first leg, first place
- (id)initWithTripPlan:(OTPTripPlan *)tripPlan;

@property (readonly, strong, nonatomic) OTPTripPlan *tripPlan;

// Itinerary
@property (readonly, strong, nonatomic) OTPItinerary *currentItinerary;
- (void)startCurrentItinerary;
@property (readonly, nonatomic) BOOL isCurrentItineraryStarted;

// Sets current leg and place to first leg and place in new itinerary
- (OTPItinerary *)moveToItineraryWithIndex:(NSUInteger)index;

// Steps
// A step exists for each place in the itinerary except for the end of walking legs where a step is not useful to a traveler
@property (readonly, strong, nonatomic) TAStep *currentStep;
@property (readonly, nonatomic) NSUInteger currentStepIndex;
@property (readonly, strong, nonatomic) NSArray *stepsInCurrentItinerary;
- (NSUInteger)numberOfStepsInCurrentItinerary;
- (TAStep *)stepWithIndex:(NSInteger)index;
- (TAStep *)moveToStepWithIndex:(NSInteger)index;
- (void)moveToStep:(TAStep *)step;

@end
