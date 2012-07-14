//
//  TAItineraryStore.m
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAItineraryStore.h"
#import "TATravelDate.h"
#import "TAItineraryStoreDelegate.h"

@interface TAItineraryStore ()
{
    NSString *currentLocation;
    CLLocationManager *locationManager;
}

@end

@implementation TAItineraryStore

@synthesize startLocation;
@synthesize endLocation;
@synthesize routingPreference;
@synthesize travelDate;
@synthesize requiresAccessibleTrip;
@synthesize maxWalkDistance;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        routingPreference = TABestRoute;
        travelDate = [[TATravelDate alloc] initWithDate:[NSDate date] departureOrArrival:TADepartAt];
        requiresAccessibleTrip = NO;
        maxWalkDistance = TAHalfMileWalk;
        
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager startUpdatingLocation];
    }
    return self;
}

- (void)fetchItineraries
{
    // TODO: better nil checks on current location
    if ([startLocation caseInsensitiveCompare:@"Current Location"] == NSOrderedSame) {
        startLocation = currentLocation != nil ? currentLocation : @"";
    }
    
    if ([endLocation caseInsensitiveCompare:@"Current Location"] == NSOrderedSame) {
        endLocation = currentLocation != nil ? currentLocation : @"";
    }
    
    NSString *encodedStartLocation = [startLocation stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *encodedEndLocation = [endLocation stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *encodedRoutingPreference;
    switch (routingPreference) {
        case TAFewerTransfers:
            encodedRoutingPreference = @"X";
            break;
        case TALessWalking:
            encodedRoutingPreference = @"W";
        default:
            encodedRoutingPreference = @"T";
            break;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM'%2F'dd'%2F'yy"];
    NSString *encodedDate = [dateFormatter stringFromDate:[travelDate date]];
    
    [dateFormatter setDateFormat:@"HH"];
    NSString *encodedHourTime = [dateFormatter stringFromDate:[travelDate date]];
    
    [dateFormatter setDateFormat:@"mm"];
    NSString *encodedMinuteTime = [dateFormatter stringFromDate:[travelDate date]];
    
    [dateFormatter setDateFormat:@"a"];
    NSString *encodedAMPMTime = [dateFormatter stringFromDate:[travelDate date]];
    
    NSString *encodedDepartAtOrArriveBy;
    if ([travelDate departAtOrArriveBy] == TAArriveBy) {
        encodedDepartAtOrArriveBy = @"A";
    } else {
        encodedDepartAtOrArriveBy = @"D";
    }
    
    NSString *encodedRequiresAccessibileTrip;
    if (requiresAccessibleTrip) {
        encodedRequiresAccessibileTrip = @"Y";
    } else {
        encodedRequiresAccessibileTrip = @"N";
    }
    
    NSString *encodedMaxWalkDistance;
    switch (maxWalkDistance) {
        case TAQuarterMileWalk:
            encodedMaxWalkDistance = @".25";
            break;
        case TAThreeQuarterMileWalk:
            encodedMaxWalkDistance = @".75";
            break;
        case TAOneMileWalk:
            encodedMaxWalkDistance = @"1.0";
        default:
            encodedMaxWalkDistance = @".50";
            break;
    }
    
    // TODO: pull instructions from server
    NSString *formatString = @"%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@&%@";
    NSString *urlString = [NSString stringWithFormat:formatString,
                           @"http://tripplanner.kingcounty.gov/cgi-bin/itin.pl?",
                           @"action=entry",
                           [@"Orig=" stringByAppendingString:encodedStartLocation],
                           [@"Dest=" stringByAppendingString:encodedEndLocation],
                           [@"Min=" stringByAppendingString:encodedRoutingPreference],
                           [@"Date=" stringByAppendingString:encodedDate],
                           [@"hour_time=" stringByAppendingString:encodedHourTime],
                           [@"minute_time=" stringByAppendingString:encodedMinuteTime],
                           [@"ampm_time=" stringByAppendingString:encodedAMPMTime],
                           [@"Arr=" stringByAppendingString:encodedDepartAtOrArriveBy],
                           [@"Atr=" stringByAppendingString:encodedRequiresAccessibileTrip],
                           [@"Walk=" stringByAppendingString:encodedMaxWalkDistance]];
    
    NSLog(@"%@", urlString);
    
    [delegate itineraryStore:self didFetchItineraries:nil];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{    
    // test that this isn't cached data
    NSTimeInterval locationAge = -[[newLocation timestamp] timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
        
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *bestPlacemark = [placemarks objectAtIndex:0];
            currentLocation = [NSString stringWithFormat:@"%@ %@",
                               [bestPlacemark subThoroughfare],
                               [bestPlacemark thoroughfare]];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [delegate itineraryStore:self didFailWithError:error];
}

@end
