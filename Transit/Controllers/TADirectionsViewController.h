//
//  TADirectionsViewController.h
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

@interface TADirectionsViewController : UIViewController <MKMapViewDelegate, TAStepScrollViewDelegate, TAStepScrollViewDataSource, UIGestureRecognizerDelegate>

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager
               locationManager:(TALocationManager *)locationManager
             tripPlanNavigator:(TATripPlanNavigator *)tripPlanNavigator;

@property (readonly, nonatomic) OTPObjectManager *otpObjectManager;
@property (readonly, nonatomic) TALocationManager *locationManager;
@property (readonly, nonatomic) TATripPlanNavigator *tripPlanNavigator;

@property (weak, nonatomic) UIButton *optionsButton;
@property (weak, nonatomic) UIButton *flipViewButton;

@property (weak, nonatomic) TAStepScrollView *stepScrollView;

@property (weak, nonatomic) UIView *mapContainerView;
@property (weak, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) UISegmentedControl *segmentedControl;

@property (weak, nonatomic) UITableView *listView;

- (void)overlayCurrentItinerary;

- (void)overviewCurrentItineraryAnimated:(BOOL)animated;

- (void)followCurrentLocation;
- (void)followCurrentLocationWithHeading;
- (void)stopFollowingCurrentLocation;

- (void)flipView;

- (void)presentTransitOptionsViewController;

@end
