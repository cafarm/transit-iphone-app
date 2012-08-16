//
//  TALocationCompletion.m
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationCompletion.h"
#import "GPAutocompletePrediction.h"

@implementation TALocationCompletion

@synthesize description = _description;

+ (TALocationCompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction
{
    return [[self alloc] initWithDescription:prediction.description];
}

- (id)initWithDescription:(NSString *)description
{
    self = [super init];
    if (self) {
        _description = description;
    }
    return self;
}

@end
