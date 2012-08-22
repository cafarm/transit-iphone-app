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

- (id)initWithLegs:(NSArray *)legs isDestination:(BOOL)isDestination previousStep:(TAStep *)previousStep;

@property (readonly, strong, nonatomic) NSArray *legs;
@property (readonly, nonatomic) OTPPlace *place;
@property (readonly, nonatomic) OTPPlace *from;
@property (readonly, nonatomic) OTPLeg *fromLeg;
@property (readonly, nonatomic) OTPPlace *to;
@property (readonly, nonatomic) OTPLeg *toLeg;
@property (readonly, nonatomic) NSString *route;
@property (readonly, nonatomic) NSNumber *distance;
@property (readonly, nonatomic) NSNumber *duration;
@property (readonly, nonatomic) BOOL isDestination;
@property (readonly, nonatomic) MKMapRect boundingMapRect;

@property (readonly, nonatomic) TAStep *previousStep;

@end
