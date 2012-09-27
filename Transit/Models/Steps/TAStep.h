//
//  TAStep.h
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "OTPClient.h"

@class OTPItinerary;
@class OTPPlace;
@class OTPAgencyAndID;

@interface TAStep : NSObject

// Returns an array of steps for a given itinerary
// Steps are created for each place in the itinerary except for:
// - End of walking legs
// - Interlined legs
+ (NSArray *)stepsWithItinerary:(OTPItinerary *)itinerary;
+ (NSDateFormatter *)sharedDateFormatter;

- (id)initWithLegs:(NSArray *)legs previousStep:(TAStep *)previousStep;

@property (readonly, strong, nonatomic) NSArray *legs;
@property (readonly, nonatomic) OTPPlace *place;
@property (readonly, nonatomic) NSString *mainDescription;
@property (readonly, nonatomic) NSString *distanceDescription;
@property (readonly, nonatomic) NSString *durationDescription;
@property (readonly, nonatomic) MKMapRect boundingMapRect;

@property (readonly, nonatomic) TAStep *previousStep;

@end
