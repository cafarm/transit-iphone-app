//
//  TAMapViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class OTPTripPlan;

@interface TAMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) OTPTripPlan *tripPlan;
@property (nonatomic) int selectedItineraryIndex;

- (void)overlaySelectedItinerary;

- (void)followCurrentLocation;
- (void)followCurrentLocationWithHeading;
- (void)stopFollowingCurrentLocation;

- (void)presentDirectionsTable;
- (void)presentTransitOptions;

- (void)startStepByStepMap;

@end
