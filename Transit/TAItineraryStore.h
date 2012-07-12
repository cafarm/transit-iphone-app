//
//  TAItineraryStore.h
//  Transit
//
//  Created by Mark Cafaro on 7/11/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TABestRoute,
    TAFewestTranfers,
    TALessWalking
} TARoutingPreference;

@interface TAItineraryStore : NSObject

@property (nonatomic) TARoutingPreference routingPreference;
@property (strong, nonatomic) NSDate *desiredTime;
@property (strong, nonatomic) NSString *startLocation;
@property (strong, nonatomic) NSString *endLocation;

+ (TAItineraryStore *)sharedStore;

@end
