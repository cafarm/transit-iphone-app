//
//  TAPredictionCompletion.h
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACompletion.h"

@class GPAutocompletePrediction;

@interface TAPredictionCompletion : TACompletion

+ (TACompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction;

- (id)initWithText:(NSString *)text detailText:(NSString *)detailText reference:(NSString *)reference;

@property (readonly, nonatomic) NSString *reference;

@end