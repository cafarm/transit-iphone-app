//
//  TATransitLeg.h
//  Transit
//
//  Created by Mark Cafaro on 7/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALeg.h"

@interface TATransitLeg : TALeg

@property (readonly, nonatomic) NSString *tripID;
@property (readonly, nonatomic) NSString *routeID;
@property (readonly, nonatomic) NSDate *serviceDate;
@property (readonly, nonatomic) NSString *fromStopID;
@property (readonly, nonatomic) NSString *toStopID;
@property (readonly, nonatomic) NSString *path;
@property (readonly, nonatomic) NSDate *scheduledDepartureTime;
@property (readonly, nonatomic) NSDate *predictedDepartureTime;
@property (readonly, nonatomic) NSDate *scheduledArrivalTime;
@property (readonly, nonatomic) NSDate *predictedArrivalTime;

@end
