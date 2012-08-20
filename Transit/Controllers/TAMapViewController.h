//
//  TAMapViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "TAStepScrollView.h"

@class OTPObjectManager;
@class TALocationManager;
@class OTPTripPlan;
@class TATripPlanNavigator;
@class OTPItinerary;

@interface TAMapViewController : UIViewController <MKMapViewDelegate, TAStepScrollViewDelegate, TAStepScrollViewDataSource, UIGestureRecognizerDelegate>

- (id)initWithObjectManager:(OTPObjectManager *)objectManager locationManager:(TALocationManager *)locationManager tripPlanNavigator:(TATripPlanNavigator *)tripPlanNavigator;

@property (readonly, nonatomic) OTPObjectManager *objectManager;
@property (readonly, nonatomic) TALocationManager *locationManager;
@property (strong, nonatomic) TATripPlanNavigator *tripPlanNavigator;

@property (strong, nonatomic) UIBarButtonItem *startButton;
@property (strong, nonatomic) UIBarButtonItem *overviewButton;
@property (strong, nonatomic) UIBarButtonItem *resumeButton;

@property (strong, nonatomic) TAStepScrollView *stepScrollView;

@property (weak, nonatomic) MKMapView *mapView;

@property (weak, nonatomic) UISegmentedControl *overviewSegmentedControl;
@property (weak, nonatomic) UISegmentedControl *stepByStepSegmentedControl;

- (void)overlayCurrentItinerary;

- (void)overviewCurrentItineraryAnimated:(BOOL)animated;
- (void)startCurrentItineraryAnimated:(BOOL)animated;
- (void)resumeCurrentItineraryAnimated:(BOOL)animated;

- (void)followCurrentLocation;
- (void)followCurrentLocationWithHeading;
- (void)stopFollowingCurrentLocation;

- (void)presentDirectionsTableViewController;
- (void)presentTransitOptionsViewController;

@end
