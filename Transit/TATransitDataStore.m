//
//  TATransitDataStore.m
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATransitDataStore.h"

@implementation TATransitDataStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (TATransitDataStore *)sharedStore
{
    static TATransitDataStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
