//
//  TALocationSuggestion.h
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPAutocompletePrediction;

@interface TALocationSuggestion : NSObject

+ (TALocationSuggestion *)suggestionWithPrediction:(GPAutocompletePrediction *)prediction;

@end
