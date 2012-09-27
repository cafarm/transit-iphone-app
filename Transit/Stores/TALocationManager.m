//
//  TALocationManager.m
//  Transit
//
//  Created by Mark Cafaro on 8/2/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationManager.h"

CLLocationDistance TALocationManagerRadiusOfInterest = 25000;

// Seattle
static CLLocationDegrees const TADefaultLatitude = 47.6097;
static CLLocationDegrees const TADefaultLongitude = -122.3331;

@interface TALocationManager ()

@property (readwrite, strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) CLLocationManager *clLocationManager;

@end


@implementation TALocationManager

@synthesize delegate = _delegate;

@synthesize currentLocation = _currentLocation;
@synthesize currentRegion = _currentRegion;

@synthesize defaultLocation = _defaultLocation;

@synthesize clLocationManager = _clLocationManager;

+ (CLAuthorizationStatus)authorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

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
                                                   radius:TALocationManagerRadiusOfInterest
                                               identifier:@"currentRegion"];
}

- (CLLocation *)defaultLocation
{
    if (_defaultLocation == nil) {
        _defaultLocation = [[CLLocation alloc] initWithLatitude:TADefaultLatitude longitude:TADefaultLongitude];
    }
    return _defaultLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *mostRecentLocation = [locations lastObject];
    
    // Test that this isn't cached data
    NSTimeInterval locationAge = -[[mostRecentLocation timestamp] timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    // Test that the horizontal accuracy does not indicate and invalid measurment
    if (mostRecentLocation.horizontalAccuracy < 0) {
        return;
    }
    
    self.currentLocation = mostRecentLocation;
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateCurrentLocation:)]) {
        [self.delegate locationManager:self didUpdateCurrentLocation:self.currentLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
        [self.delegate locationManager:self didFailWithError:error];
    }
}

- (void)locationManager:(TALocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([self.delegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)]) {
        [self.delegate locationManager:self didChangeAuthorizationStatus:status];
    }
}

@end
