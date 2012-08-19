//
//  TAAttributionCompletion.h
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACompletion.h"

typedef enum {
    TAAttributionCompletionTypeGoogle
} TAAttributionCompletionType;

@interface TAAttributionCompletion : TACompletion

+ (TAAttributionCompletion *)google;

- (id)initWithType:(TAAttributionCompletionType)type;

@property (readonly, nonatomic)TAAttributionCompletionType type;

@end
