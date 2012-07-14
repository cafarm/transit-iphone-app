//
//  TAItineraryStore.h
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class TATravelDate;
@protocol TAItineraryStoreDelegate;

typedef enum {
    TABestRoute,
    TAFewerTransfers,
    TALessWalking
} TARoutingPreference;

typedef enum {
    TAQuarterMileWalk,
    TAHalfMileWalk,
    TAThreeQuarterMileWalk,
    TAOneMileWalk
} TAMaxWalkDistance;

@interface TAItineraryStore : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic)NSString *startLocation;
@property (strong, nonatomic)NSString *endLocation;
@property (nonatomic)TARoutingPreference routingPreference;
@property (strong, nonatomic)TATravelDate *travelDate;
@property (nonatomic)BOOL requiresAccessibleTrip;
@property (nonatomic)TAMaxWalkDistance maxWalkDistance;
@property (weak, nonatomic)id<TAItineraryStoreDelegate> delegate;

- (void)fetchItineraries;

@end
