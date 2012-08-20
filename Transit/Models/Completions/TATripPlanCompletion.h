//
//  TATripPlanCompletion.h
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACompletion.h"

@class TAPlacemark;

@interface TATripPlanCompletion : TACompletion <NSCoding>

- (id)initWithFrom:(TAPlacemark *)from to:(TAPlacemark *)to;

@property (readonly, nonatomic) TAPlacemark *from;
@property (readonly, nonatomic) TAPlacemark *to;

@end
