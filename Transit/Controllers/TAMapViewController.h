//
//  TAMapViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class OTPObjectManager;
@class OTPTripPlan;
@class OTPItinerary;

@interface TAMapViewController : UIViewController <MKMapViewDelegate>

- (id)initWithObjectManager:(OTPObjectManager *)objectManager tripPlan:(OTPTripPlan *)tripPlan;

@property (strong, nonatomic) OTPObjectManager *objectManager;
@property (strong, nonatomic) OTPTripPlan *tripPlan;

@property (weak, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) UIBarButtonItem *startButton;
@property (strong, nonatomic) UIBarButtonItem *overviewButton;
@property (strong, nonatomic) UIBarButtonItem *resumeButton;

- (void)overlayPreferredItinerary;

- (void)overviewPreferredItineraryAnimated:(BOOL)animated;
- (void)startPreferredItineraryAnimated:(BOOL)animated;
- (void)resumePreferredItineraryAnimated:(BOOL)animated;

- (void)followCurrentLocation;
- (void)followCurrentLocationWithHeading;
- (void)stopFollowingCurrentLocation;

- (void)presentDirectionsTableViewController;
- (void)presentTransitOptionsViewController;

@end
