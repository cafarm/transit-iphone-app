//
//  TATransitStep.h
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStep.h"

@interface TATransitStep : TAStep

- (id)initWithLegs:(NSArray *)legs isDestination:(BOOL)isDestination isArrival:(BOOL)isArrival previousStep:(TAStep *)previousStep;

@property (readonly, nonatomic) OTPLegTraverseMode mode;
@property (readonly, nonatomic) NSString *tripShortName;
@property (readonly, nonatomic) NSString *headSign;
@property (readonly, nonatomic) NSString *tripID;
@property (readonly, nonatomic) NSDate *scheduledDate;
@property (readonly, nonatomic) BOOL isArrival;

@end
