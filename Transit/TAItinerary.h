//
//  TAItinerary.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAParser.h"

@interface TAItinerary : TAParser

@property (readonly, nonatomic) NSMutableArray *legs;
@property (readonly, nonatomic) float orcaRegularFare;
@property (readonly, nonatomic) float cashRegularFare;

@end
