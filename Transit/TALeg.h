//
//  TALeg.h
//  Transit
//
//  Created by Mark Cafaro on 7/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAParser.h"

typedef enum {
    TAWalk,
    TABus,
    TARail,
    TAFerry
} TATravelMode;

@interface TALeg : TAParser

@property (readonly, nonatomic) TATravelMode travelMode;
@property (readonly, nonatomic) int distance; // meters

- (id)initWithTravelMode:(TATravelMode)travelMode distance:(float)distance;

@end
