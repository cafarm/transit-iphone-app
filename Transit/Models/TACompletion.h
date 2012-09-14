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
    TACompletionTypeGoogleLogo
} TACompletionType;

@interface TACompletion : NSObject

+ (TACompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction;

+ (TACompletion *)googleLogo;

- (id)initWithType:(TACompletionType)type text:(NSString *)text detailText:(NSString *)detailText;

@property (nonatomic) TACompletionType type;
@property (readonly, nonatomic) NSString *text;
@property (readonly, nonatomic) NSString *detailText;

@end
