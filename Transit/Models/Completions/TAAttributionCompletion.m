//
//  TAAttributionCompletion.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAAttributionCompletion.h"

@implementation TAAttributionCompletion

@synthesize type = _type;

+ (TAAttributionCompletion *)google
{
    return [[TAAttributionCompletion alloc] initWithType:TAAttributionCompletionTypeGoogle];
}

- (id)initWithType:(TAAttributionCompletionType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

@end
