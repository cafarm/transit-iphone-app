//
//  TALocationManager.m
//  Transit
//
//  Created by Mark Cafaro on 8/2/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationManager.h"

@interface TALocationManager ()

@property (readwrite, strong, nonatomic) CLLocation *currentLocation;
@property (readwrite, strong, nonatomic) CLRegion *currentRegion;

@property (strong, nonatomic) CLLocationManager *clLocationManager;

@end

@implementation TALocationManager

@synthesize delegate = _delegate;

@synthesize currentLocation = _currentLocation;
@synthesize currentRegion = _currentRegion;

@synthesize clLocationManager = _clLocationManager;

- (id)init
{
    self = [super init];
    if (self) {
        _clLocationManager = [[CLLocationManager alloc] init];
        _clLocationManager.delegate = self;
    }
    return self;
}

- (void)startUpdatingLocation
{
    [self.clLocationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    [self.clLocationManager stopUpdatingLocation];
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter
{
    self.clLocationManager.distanceFilter = distanceFilter;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    self.clLocationManager.desiredAccuracy = desiredAccuracy;
}

- (CLRegion *)currentRegion
{
    return [[CLRegion alloc] initCircularRegionWithCenter:self.currentLocation.coordinate
                                                   radius:16000 // ~10 miles
                                               identifier:@"currentRegion"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *mostRecentLocation = [locations lastObject];
    
    // test that this isn't cached data
    NSTimeInterval locationAge = -[[mostRecentLocation timestamp] timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    // test that the horizontal accuracy does not indicate and invalid measurment
    if (mostRecentLocation.horizontalAccuracy < 0) {
        return;
    }
    
    self.currentLocation = mostRecentLocation;
    
    [self.delegate locationManager:self didUpdateCurrentLocation:self.currentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.delegate locationManager:self didFailWithError:error];
}

@end
