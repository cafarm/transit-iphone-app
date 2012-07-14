//
//  TATripStore.m
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATripStore.h"
#import "TATrip.h"
#import "TATravelDate.h"
#import "TAConnection.h"

@interface TATripStore ()
{
    NSString *_currentLocation;
    CLLocationManager *_locationManager;
}

@end

@implementation TATripStore

@synthesize startLocation=_startLocation;
@synthesize endLocation=_endLocation;
@synthesize routingPreference=_routingPreference;
@synthesize travelDate=_travelDate;
@synthesize requiresAccessibleTrip=_requiresAccessibleTrip;
@synthesize maxWalkDistance=_maxWalkDistance;
@synthesize delegate=_delegate;

- (id)init
{
    self = [super init];
    if (self) {
        _routingPreference = TABestRoute;
        _travelDate = [[TATravelDate alloc] initWithDate:[NSDate date] departAtOrArriveBy:TADepartAt];
        _requiresAccessibleTrip = NO;
        _maxWalkDistance = TAHalfMileWalk;
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager startUpdatingLocation];
    }
    return self;
}

- (void)planTrip
{
    // TODO: pull encoding instructions from our server
    // TODO: better nil check on current location
    // we may want to block execution until we find the current location
    if ([self.startLocation caseInsensitiveCompare:@"Current Location"] == NSOrderedSame) {
        self.startLocation = _currentLocation != nil ? _currentLocation : @"";
    }
    
    if ([self.endLocation caseInsensitiveCompare:@"Current Location"] == NSOrderedSame) {
        self.endLocation = _currentLocation != nil ? _currentLocation : @"";
    }
    
    // TODO: we'll want to strip city name, state, zip code and punctuation from these addresses
    NSString *encodedStartLocation = [self.startLocation stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *encodedEndLocation = [self.endLocation stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *encodedRoutingPreference;
    switch (self.routingPreference) {
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
    NSString *encodedDate = [dateFormatter stringFromDate:[self.travelDate date]];
    
    [dateFormatter setDateFormat:@"HH"];
    NSString *encodedHourTime = [dateFormatter stringFromDate:[self.travelDate date]];
    
    [dateFormatter setDateFormat:@"mm"];
    NSString *encodedMinuteTime = [dateFormatter stringFromDate:[self.travelDate date]];
    
    [dateFormatter setDateFormat:@"a"];
    NSString *encodedAMPMTime = [dateFormatter stringFromDate:[self.travelDate date]];
    
    NSString *encodedDepartAtOrArriveBy;
    if ([self.travelDate departAtOrArriveBy] == TAArriveBy) {
        encodedDepartAtOrArriveBy = @"A";
    } else {
        encodedDepartAtOrArriveBy = @"D";
    }
    
    NSString *encodedRequiresAccessibileTrip;
    if (self.requiresAccessibleTrip) {
        encodedRequiresAccessibileTrip = @"Y";
    } else {
        encodedRequiresAccessibileTrip = @"N";
    }
    
    NSString *encodedMaxWalkDistance;
    switch (self.maxWalkDistance) {
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
    
    DLog(@"%@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    TATrip *trip = [[TATrip alloc] init];
    
    TAConnection *connection = [[TAConnection alloc] initWithRequest:request];
    [connection setCompletionBlock:^(TATrip *trip, NSError *error) {
        if (!error) {
            [self.delegate tripStore:self didPlanTrip:trip];
        } else {
            [self.delegate tripStore:self didFailWithError:error];
        }
    }];
    [connection setXmlRootObject:trip];
    [connection start];
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
            _currentLocation = [NSString stringWithFormat:@"%@ %@",
                               [bestPlacemark subThoroughfare],
                               [bestPlacemark thoroughfare]];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.delegate tripStore:self didFailWithError:error];
}

@end