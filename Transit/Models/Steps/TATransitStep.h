//
//  TATransitStep.h
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStep.h"

@interface TATransitStep : TAStep

- (id)initWithLegs:(NSArray *)legs previousStep:(TAStep *)previousStep isArrival:(BOOL)isArrival;

@property (readonly, nonatomic) OTPLegTraverseMode mode;
@property (readonly, nonatomic) NSString *scheduledDateDescription;
@property (readonly, nonatomic) NSString *scheduledDateShortDescription;
@property (readonly, nonatomic) NSString *detailsDescription;
@property (readonly, nonatomic) BOOL isArrival;

@end
