//
//  TADirectionsViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TADirectionsViewController.h"
#import "TALocationManager.h"
#import "TATripPlanNavigator.h"
#import "TAWalkStep.h"
#import "TATransitStep.h"
#import "TAStepView.h"
#import "TAStepAnnotation.h"
#import "TACurrentStepAnnotation.h"
#import "TAWalkStepView.h"
#import "TATransitStepView.h"
#import "OTPClient.h"
#import "MKMapView+Transit.h"

typedef enum {
    TAMapViewSegmentTracking,
    TAMapViewSegmentOverview
} TAMapViewSegment;

@interface TADirectionsViewController ()

@property (nonatomic) BOOL isViewingMap;

@property (strong, nonatomic) TACurrentStepAnnotation *currentStepAnnotation;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation TADirectionsViewController

@synthesize otpObjectManager = _otpObjectManager;
@synthesize locationManager = _locationManager;
@synthesize tripPlanNavigator = _tripPlanNavigator;

@synthesize optionsButton = _optionsButton;
@synthesize flipViewButton = _flipViewButton;

@synthesize stepScrollView = _stepScrollView;

@synthesize mapContainerView = _mapContainerView;
@synthesize mapView = _mapView;
@synthesize segmentedControl = _segmentedControl;

@synthesize listView = _listView;

@synthesize isViewingMap = _isViewingMap;

@synthesize currentStepAnnotation = _currentStepAnnotation;

@synthesize dateFormatter = _dateFormatter;

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager locationManager:(TALocationManager *)locationManager tripPlanNavigator:(TATripPlanNavigator *)tripPlanNavigator
{
    self = [super init];
    if (self) {
        _otpObjectManager = otpObjectManager;
        _locationManager = locationManager;
        _tripPlanNavigator = tripPlanNavigator;
    }
    return self;
}

- (void)loadView
{
    self.navigationItem.title = @"Directions";
    
    UIButton *flipViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 30)];
    UIEdgeInsets buttonInsets = UIEdgeInsetsMake(15, 5, 15, 5);
    [flipViewButton setBackgroundImage:[[UIImage imageNamed:@"BlueButton"] resizableImageWithCapInsets:buttonInsets] forState:UIControlStateNormal];
    [flipViewButton setBackgroundImage:[[UIImage imageNamed:@"BlueButtonPressed"] resizableImageWithCapInsets:buttonInsets] forState:UIControlStateSelected];
    [flipViewButton setImage:[UIImage imageNamed:@"List"] forState:UIControlStateNormal];
    [flipViewButton addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    self.flipViewButton = flipViewButton;
    
    UIButton *optionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 30)];
    [optionsButton setBackgroundImage:[[UIImage imageNamed:@"BlueButton"] resizableImageWithCapInsets:buttonInsets] forState:UIControlStateNormal];
    [optionsButton setBackgroundImage:[[UIImage imageNamed:@"BlueButtonPressed"] resizableImageWithCapInsets:buttonInsets] forState:UIControlStateSelected];
    [optionsButton setImage:[UIImage imageNamed:@"Options"] forState:UIControlStateNormal];
    [optionsButton addTarget:self action:@selector(presentTransitOptionsViewController) forControlEvents:UIControlEventTouchUpInside];
    self.optionsButton = optionsButton;
    
    UIBarButtonItem *flipViewButtonItem = [[UIBarButtonItem alloc] initWithCustomView:flipViewButton];
    UIBarButtonItem *optionsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:optionsButton];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:flipViewButtonItem, optionsButtonItem, nil];
    
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = containerView;
    
    // We need a map container view because using the MKMapView as the container view freezes all subviews on animation
    UIView *mapContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    mapContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [containerView addSubview:mapContainerView];
    self.mapContainerView = mapContainerView;
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:mapContainerView.bounds];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapView.showsUserLocation = YES;
    mapView.visibleMapRect = self.tripPlanNavigator.currentItinerary.boundingMapRect;
    mapView.delegate = self;
    self.isViewingMap = YES;
    [mapContainerView addSubview:mapView];
    self.mapView = mapView;
    
    TAStepScrollView *stepScrollView = [[TAStepScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 129)];
    stepScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    stepScrollView.delegate = self;
    stepScrollView.dataSource = self;
    [mapContainerView addSubview:stepScrollView];
    self.stepScrollView = stepScrollView;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(3, 376, 85, 37)];
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"SilverButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"SilverButtonPressed"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segmentedControl setDividerImage:[UIImage imageNamed:@"SilverBarDivider"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"TrackingOff"] atIndex:TAMapViewSegmentTracking animated:NO];
    [segmentedControl setContentPositionAdjustment:UIOffsetMake(2, 0) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"Overview"] atIndex:TAMapViewSegmentOverview animated:NO];
    [segmentedControl setContentPositionAdjustment:UIOffsetMake(-3, 1) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
    [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.momentary = YES;
    [mapContainerView addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
    
    [self setupViewsWithCurrentItinerary];
}

- (void)setupViewsWithCurrentItinerary
{
    [self.mapView addOverlayForItinerary:self.tripPlanNavigator.currentItinerary];
    [self.mapView addAnnotationsForSteps:self.tripPlanNavigator.stepsInCurrentItinerary];
    
    [self.stepScrollView reloadData];

    self.currentStepAnnotation = [self.mapView addAnnotationForCurrentStep:self.tripPlanNavigator.currentStep];
}

- (void)overviewCurrentItineraryAnimated:(BOOL)animate
{
    [self.mapView setVisibleMapRectToFitItinerary:self.tripPlanNavigator.currentItinerary animated:animate];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]]) {		
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [UIColor blueColor];
		polylineView.lineWidth = 13 / 2;
		return polylineView;
	}
	return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[TACurrentStepAnnotation class]]) {
        MKAnnotationView *currentStepView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"currentStepID"];
        if (!currentStepView) {
            currentStepView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentStepID"];
            currentStepView.image = [UIImage imageNamed:@"CurrentStepAnnotation.png"];
            currentStepView.enabled = NO;
        } else {
            currentStepView.annotation = annotation;
        }
        return currentStepView;
    } else if ([annotation isKindOfClass:[TAStepAnnotation class]]) {
        MKAnnotationView *stepView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"stepID"];
        if (!stepView) {
            stepView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"stepID"];
            stepView.canShowCallout = YES;
        } else {
            stepView.annotation = annotation;
        }
        TAStepAnnotation *stepAnnotation = (TAStepAnnotation *)annotation;
        if (stepAnnotation.direction == TAStepAnnotationDirectionLeft) {
            stepView.image = [UIImage imageNamed:@"CalloutLeft"];
            stepView.centerOffset = CGPointMake(-17, -11);
        } else {
            stepView.image = [UIImage imageNamed:@"CalloutRight"];
            stepView.centerOffset = CGPointMake(17, -11);
        }
        return stepView;
    }
    return nil;
}

// FIXME: Why doesn't this work to put the current step annotation into the back?
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView * view in views) {
        if ([view isKindOfClass:[MKPinAnnotationView class]]) {
            [view.superview bringSubviewToFront:view];
        } else {
            [view.superview sendSubviewToBack:view];
        }
    }
}

- (void)changeView:(id)sender
{
    TAMapViewSegment selectedSegment = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    switch (selectedSegment) {
        case TAMapViewSegmentTracking:
            if (self.mapView.userTrackingMode == MKUserTrackingModeNone) {
                [self.segmentedControl setImage:[UIImage imageNamed:@"TrackingLocation"] forSegmentAtIndex:TAMapViewSegmentTracking];
                [self followCurrentLocation];
            } else if (self.mapView.userTrackingMode == MKUserTrackingModeFollow) {
                [self.segmentedControl setImage:[UIImage imageNamed:@"TrackingHeading"] forSegmentAtIndex:TAMapViewSegmentTracking];
                [self followCurrentLocationWithHeading];
            } else {
                [self.segmentedControl setImage:[UIImage imageNamed:@"TrackingOff"] forSegmentAtIndex:TAMapViewSegmentTracking];
                [self stopFollowingCurrentLocation];
            }
            break;
        case TAMapViewSegmentOverview:
            [self overviewCurrentItineraryAnimated:YES];
            break;
        default:
            break;
    }
}

- (void)followCurrentLocation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)followCurrentLocationWithHeading
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (void)stopFollowingCurrentLocation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone) {
        [self.segmentedControl setImage:[UIImage imageNamed:@"TrackingOff"] forSegmentAtIndex:TAMapViewSegmentTracking];
    }
}

- (void)flipView
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // Flip main view
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(flipDidStop:finished:context:)];
    
    if (self.isViewingMap) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        if (self.listView == nil) {
            UITableView *listView = [[UITableView alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:listView];
            self.listView = listView;
        }
        self.listView.hidden = NO;
        self.mapView.hidden = YES;
        
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        self.mapView.hidden = NO;
        self.listView.hidden = YES;
    }
    
    [UIView commitAnimations];
    
    // Flip button
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelegate:self];
    
    if (self.isViewingMap) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.flipViewButton cache:YES];
        [self.flipViewButton setImage:[UIImage imageNamed:@"Map"] forState:UIControlStateNormal];
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.flipViewButton cache:YES];
        [self.flipViewButton setImage:[UIImage imageNamed:@"List"] forState:UIControlStateNormal];
    }
    
    [UIView commitAnimations];
    
    self.isViewingMap = !self.isViewingMap;
}

- (void)flipDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)presentTransitOptionsViewController
{
    TATransitOptionsViewController *optionsController = [[TATransitOptionsViewController alloc] initWithOTPObjectManager:self.otpObjectManager tripPlanNavigator:self.tripPlanNavigator];
    optionsController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:optionsController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)transitOptionsViewControllerDidSetNewOptions:(TATransitOptionsViewController *)controller
{
    [self.mapView removeAllAnnotations];
    [self.mapView removeAllOverlays];
    
    [self setupViewsWithCurrentItinerary];
    [self overviewCurrentItineraryAnimated:NO];
}

- (NSInteger)numberOfStepsInScrollView:(TAStepScrollView *)scrollView
{
    return [self.tripPlanNavigator numberOfStepsInCurrentItinerary];
}

- (TAStepView *)stepScrollView:(TAStepScrollView *)scrollView viewForStepAtIndex:(NSInteger)index
{
    TAStep *step = [self.tripPlanNavigator stepWithIndex:index];
    
    TAStepView *stepView = nil;
    
    
    if ([step isKindOfClass:[TAWalkStep class]]) {
        TAWalkStepView *walkStepView = (TAWalkStepView *)[scrollView dequeueReusableStepWithIdentifier:@"walkStepViewID"];
        if (walkStepView == nil) {
            walkStepView = [[TAWalkStepView alloc] initWithReuseIdentifier:@"walkStepViewID"];
        }
        
        TAWalkStep *walkStep = (TAWalkStep *)step;
        
        NSString *detailsText;
        NSDictionary *detailsAttributes = [walkStepView.detailsLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
        NSString *distanceText;
        NSDictionary *distanceAttributes = [walkStepView.distanceLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
        if (walkStep.isDestination) {
            detailsText = [NSString stringWithFormat:@"ARRIVE AT %@", [walkStep.place.name uppercaseString]];
            distanceText = @" ";
        } else {
            detailsText = [NSString stringWithFormat:@"WALK TO %@", [walkStep.to.name uppercaseString]];
            distanceText = [NSString stringWithFormat:@"%.01f miles", [walkStep.distance floatValue] * 0.000621371f];
        }
        
        walkStepView.detailsLabel.attributedText = [[NSAttributedString alloc] initWithString:detailsText attributes:detailsAttributes];
        walkStepView.distanceLabel.attributedText = [[NSAttributedString alloc] initWithString:distanceText attributes:distanceAttributes];
        [walkStepView setNeedsLayout];
        
        stepView = walkStepView;

    } else {
        TATransitStepView *transitStepView = (TATransitStepView *)[scrollView dequeueReusableStepWithIdentifier:@"transitStepViewID"];
        if (transitStepView == nil) {
            transitStepView = [[TATransitStepView alloc] initWithReuseIdentifier:@"transitStepViewID"];
        }
        
        TATransitStep *transitStep = (TATransitStep *)step;
        
        NSString *routeText;
        NSDictionary *routeAttributes = [transitStepView.routeLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
        NSString *detailsText;
        NSDictionary *detailsAttributes = [transitStepView.detailsLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
        NSString *dateText;
        NSDictionary *dateAttributes = [transitStepView.dateLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
        self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
        self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
        if (transitStep.isArrival) {
            routeText = [NSString stringWithFormat:@"Get off %@", transitStep.route];
            detailsText = [NSString stringWithFormat:@"AT %@", [transitStep.place.name uppercaseString]];
            dateText = [NSString stringWithFormat:@"Arrives at %@", [self.dateFormatter stringFromDate:transitStep.scheduledDate]];
        } else {
            routeText = [NSString stringWithFormat:@"Take %@", transitStep.route];
            detailsText = [NSString stringWithFormat:@"TOWARDS %@", [transitStep.headSign uppercaseString]];
            dateText = [NSString stringWithFormat:@"Departs at %@", [self.dateFormatter stringFromDate:transitStep.scheduledDate]];
        }
        transitStepView.routeLabel.attributedText = [[NSAttributedString alloc] initWithString:routeText attributes:routeAttributes];
        transitStepView.detailsLabel.attributedText = [[NSAttributedString alloc] initWithString:detailsText attributes:detailsAttributes];
        transitStepView.dateLabel.attributedText = [[NSAttributedString alloc] initWithString:dateText attributes:dateAttributes];
        [transitStepView setNeedsLayout];
        
        stepView = transitStepView;
    }

    return stepView;
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)stepScrollView:(TAStepScrollView *)scrollView didScrollToStep:(TAStepView *)step atIndex:(NSInteger)index
{
    if (index == self.tripPlanNavigator.currentStepIndex) {
        return;
    }
    
    [self.tripPlanNavigator moveToStepWithIndex:index];
    
    [self.currentStepAnnotation setCoordinateToStep:self.tripPlanNavigator.currentStep];
    [self.mapView setVisibleMapRectToFitStep:self.tripPlanNavigator.currentStep animated:YES];
}

@end