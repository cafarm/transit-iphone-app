//
//  UITableViewCell+Transit.h
//  Transit
//
//  Created by Mark Cafaro on 8/20/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TACurrentLocationCompletion;
@class TATripPlanCompletion;
@class TAPlaceCompletion;
@class TAAttributionCompletion;

@interface UITableViewCell (Transit)

+ (void)styleCurrentLocationCompletionCell:(UITableViewCell *)cell withCompletion:(TACurrentLocationCompletion *)completion;

+ (void)styleTripPlanCompletionCell:(UITableViewCell *)cell withCompletion:(TATripPlanCompletion *)completion;

+ (void)stylePlaceCompletionCell:(UITableViewCell *)cell withCompletion:(TAPlaceCompletion *)completion;

+ (void)styleAttributionCompletionCell:(UITableViewCell *)cell withCompletion:(TAAttributionCompletion *)completion;

@end
