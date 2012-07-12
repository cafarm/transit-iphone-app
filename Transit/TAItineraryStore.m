//
//  TAItineraryStore.m
//  Transit
//
//  Created by Mark Cafaro on 7/11/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAItineraryStore.h"

@implementation TAItineraryStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (TAItineraryStore *)sharedStore
{
    static TAItineraryStore *itineraryStore = nil;
    if (!itineraryStore) {
        itineraryStore = [[super allocWithZone:nil] init];
    }
    return itineraryStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
