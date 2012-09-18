//
//  TAPlaceCompletion.h
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACompletion.h"

@class GPAutocompletePrediction;

@interface TAPlaceCompletion : TACompletion

+ (TACompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction;

- (id)initWithMainTerm:(NSString *)mainTerm subTerms:(NSString *)subTerms reference:(NSString *)reference;

@property (readonly, nonatomic) NSString *mainTerm;
@property (readonly, nonatomic) NSString *subTerms;
@property (readonly, nonatomic) NSString *reference;

@end