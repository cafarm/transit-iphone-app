//
//  TAPlaceStep.h
//  Transit
//
//  Created by Mark Cafaro on 9/26/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStep.h"

@interface TAPlaceStep : TAStep

- (id)initWithLegs:(NSArray *)legs previousStep:(TAStep *)previousStep isDestination:(BOOL)isDestination;

@property (readonly, nonatomic) BOOL isDestination;
@property (readonly, nonatomic) NSString *placeDescription;
@property (readonly, nonatomic) NSString *startDateDescription;
@property (readonly, nonatomic) NSString *endDateDescription;

@end
