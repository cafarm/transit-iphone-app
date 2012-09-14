//
//  TALocationCompletion.h
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPAutocompletePrediction;

typedef enum {
    TACompletionTypeLocation,
    TACompletionTypeTrip,
} TACompletionType;

@interface TALocationCompletion : NSObject

+ (TALocationCompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction;

- (id)initWithText:(NSString *)text detailText:(NSString *)detailText;

@property (readonly, nonatomic) NSString *text;
@property (readonly, nonatomic) NSString *detailText;

@end
