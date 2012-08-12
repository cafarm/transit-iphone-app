//
//  TAStep.h
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "OTPLeg.h"

@class OTPItinerary;
@class OTPPlace;
@class OTPAgencyAndID;

typedef enum {
    TAFrom,
    TATo
} TAFromOrTo;

@interface TAStep : NSObject

// Returns an array of steps for a given itinerary
// Steps are created for each place in the itinerary except for:
// - End of walking legs
// - Interlined legs
+ (NSArray *)stepsWithItinerary:(OTPItinerary *)itinerary;

- (id)initWithLegs:(NSArray *)legs fromOrTo:(TAFromOrTo)fromOrTo previousStep:(TAStep *)previousStep;

@property (readonly, strong, nonatomic) NSMutableArray *legs;
@property (readonly, nonatomic) OTPPlace *place;
@property (readonly, nonatomic) OTPLeg *placeLeg;

@property (readonly, nonatomic) TAFromOrTo fromOrTo;

@property (readonly, nonatomic) TAStep *previousStep;

@property (readonly, nonatomic) OTPTraverseMode mode;
@property (readonly, nonatomic) NSString *route;
@property (readonly, nonatomic) NSString *fromRoute;
@property (readonly, nonatomic) NSString *tripShortName;
@property (readonly, nonatomic) NSString *headSign;
@property (readonly, nonatomic) NSString *tripID;
@property (readonly, nonatomic) NSNumber *distance;
@property (readonly, nonatomic) NSNumber *duration;

@property (readonly, nonatomic) NSString *placeName;
@property (readonly, nonatomic) OTPAgencyAndID *stopID;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (readonly, nonatomic) NSDate *scheduledArrival;
@property (readonly, nonatomic) NSDate *scheduledDeparture;

@end
