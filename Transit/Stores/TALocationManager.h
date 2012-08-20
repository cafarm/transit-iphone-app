//
//  TALocationManager.h
//  Transit
//
//  Created by Mark Cafaro on 8/2/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

extern CLLocationDistance TARadiusOfInterest;

@protocol TALocationManagerDelegate;

@interface TALocationManager : NSObject <CLLocationManagerDelegate>

+ (CLAuthorizationStatus)authorizationStatus;

@property (weak, nonatomic) id<TALocationManagerDelegate> delegate;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@property (assign, nonatomic) CLLocationDistance distanceFilter;
@property (assign, nonatomic) CLLocationAccuracy desiredAccuracy;

@property (readonly, strong, nonatomic) CLLocation *currentLocation;
@property (readonly, strong, nonatomic) CLRegion *currentRegion;

@end


@protocol TALocationManagerDelegate <NSObject>

@optional

- (void)locationManager:(TALocationManager *)manager didUpdateCurrentLocation:(CLLocation *)currentLocation;
- (void)locationManager:(TALocationManager *)manager didFailWithError:(NSError *)error;

- (void)locationManager:(TALocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end
