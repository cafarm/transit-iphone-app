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
#import "TAPlaceStep.h"
#import "TAWalkStep.h"
#import "TATransitStep.h"
#import "TAStepView.h"
#import "TAStepAnnotation.h"
#import "TACurrentStepAnnotation.h"
#import "TAPlaceStepView.h"
#import "TAWalkStepView.h"
#import "TATransitStepView.h"
#import "OTPClient.h"
#import "MKMapView+Transit.h"

enum {
    TAMapViewSegmentTracking,
    TAMapViewSegmentZoom
};

@interface TADirectionsViewController ()

@property (nonatomic) UIEdgeInsets mapEdgePadding;

@property (nonatomic) BOOL isViewingMap;

@property (nonatomic) BOOL isViewingMapOverview;
@property (nonatomic) MKMapRect savedMapZoom;

@property (nonatomic) BOOL isInitialMapRegionSet;

@property (strong, nonatomic) TACurrentStepAnnotation *currentStepAnnotation;

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

@synthesize mapEdgePadding = _mapEdgePadding;

@synthesize isViewingMap = _isViewingMap;

@synthesize isViewingMapOverview = _isViewingMapOverview;
@synthesize savedMapZoom = _savedMapZoom;

@synthesize currentStepAnnotation = _currentStepAnnotation;

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
    
    self.mapEdgePadding = UIEdgeInsetsMake(78 + 39, 39, 39, 39);
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapView.showsUserLocation = YES;
    [mapView setVisibleMapRectToFitItinerary:self.tripPlanNavigator.currentItinerary edgePadding:self.mapEdgePadding animated:NO];
    mapView.delegate = self;
    [mapContainerView addSubview:mapView];
    self.mapView = mapView;
    
    self.isViewingMap = YES;
    self.isViewingMapOverview = YES;
    self.isInitialMapRegionSet = NO;
    
    UIImageView *stepScrollBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 78)];
    stepScrollBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    stepScrollBackgroundView.image = [UIImage imageNamed:@"StepViewBackground"];
    [mapContainerView addSubview:stepScrollBackgroundView];
    
    TAStepScrollView *stepScrollView = [[TAStepScrollView alloc] initWithFrame:stepScrollBackgroundView.frame];
    stepScrollView.autoresizingMask = stepScrollBackgroundView.autoresizingMask;
    stepScrollView.delegate = self;
    stepScrollView.dataSource = self;
    [mapContainerView addSubview:stepScrollView];
    self.stepScrollView = stepScrollView;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 88, self.view.bounds.size.height - 40, 85, 37)];
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"SilverButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"SilverButtonPressed"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segmentedControl setDividerImage:[UIImage imageNamed:@"SilverBarDivider"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"TrackingOff"] atIndex:TAMapViewSegmentTracking animated:NO];
    [segmentedControl setContentPositionAdjustment:UIOffsetMake(2, 0) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"Zoom"] atIndex:TAMapViewSegmentZoom animated:NO];
    [segmentedControl setContentPositionAdjustment:UIOffsetMake(-2, 0) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
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
    [self.listView reloadData];

    self.currentStepAnnotation = [self.mapView addAnnotationForCurrentStep:self.tripPlanNavigator.currentStep];
}

- (void)overviewCurrentItineraryAnimated:(BOOL)animate
{
    self.savedMapZoom = self.mapView.visibleMapRect;
    [self.mapView setVisibleMapRectToFitItinerary:self.tripPlanNavigator.currentItinerary edgePadding:self.mapEdgePadding animated:animate];
    self.isViewingMapOverview = YES;
    [self.segmentedControl setImage:[UIImage imageNamed:@"Zoom"] forSegmentAtIndex:TAMapViewSegmentZoom];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]]) {
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [UIColor colorWithRed:0/255.0 green:97/255.0 blue:215/255.0 alpha:1.0];
		polylineView.lineWidth = 13 / 2 * screenScale;
		return polylineView;
	}
	return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *view = nil;
    
    if ([annotation isKindOfClass:[TACurrentStepAnnotation class]]) {
        static NSString *currentStepViewID = @"currentStepViewID";
        MKAnnotationView *currentStepView = [mapView dequeueReusableAnnotationViewWithIdentifier:currentStepViewID];
        if (currentStepView == nil) {
            currentStepView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:currentStepViewID];
            currentStepView.image = [UIImage imageNamed:@"CurrentStepAnnotation.png"];
        }
        currentStepView.annotation = annotation;
        
        view = currentStepView;
        
    } else if ([annotation isKindOfClass:[TAStepAnnotation class]]) {
        TAStepAnnotation *stepAnnotation = (TAStepAnnotation *)annotation;
        TAStep *step = stepAnnotation.step;
        
        if ([step isKindOfClass:[TAPlaceStep class]]) {
            static NSString *placeStepViewID = @"placeStepViewID";
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:placeStepViewID];
            if (pinView == nil) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:stepAnnotation reuseIdentifier:placeStepViewID];
                pinView.canShowCallout = YES;
            }

            if (((TAPlaceStep *)step).isDestination) {
                pinView.pinColor = MKPinAnnotationColorRed;
            } else {
                pinView.pinColor = MKPinAnnotationColorGreen;
            }
            
            view = pinView;

        } else {
            static NSString *stepViewID = @"stepViewID";
            MKAnnotationView *stepView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:stepViewID];
            if (!stepView) {
                stepView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stepViewID];
                stepView.canShowCallout = YES;
            }
            stepView.annotation = annotation;
            
            if ([step isKindOfClass:[TAWalkStep class]]) {
                if (stepAnnotation.facing == TAStepAnnotationFacingLeft) {
                    stepView.image = [UIImage imageNamed:@"WalkCalloutLeft"];
                    stepView.centerOffset = CGPointMake(-15, -12);
                } else {
                    stepView.image = [UIImage imageNamed:@"WalkCalloutRight"];
                    stepView.centerOffset = CGPointMake(15, -12);
                }
            } else {
                if (stepAnnotation.facing == TAStepAnnotationFacingLeft) {
                    stepView.image = [UIImage imageNamed:@"BusCalloutLeft"];
                    stepView.centerOffset = CGPointMake(-15, -12);
                } else {
                    stepView.image = [UIImage imageNamed:@"BusCalloutRight"];
                    stepView.centerOffset = CGPointMake(15, -12);
                }
            }
            
            view = stepView;
        }
    }
    return view;
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

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{    
    if (self.isInitialMapRegionSet && self.isViewingMapOverview) {
        [self.segmentedControl setImage:[UIImage imageNamed:@"Overview"] forSegmentAtIndex:TAMapViewSegmentZoom];
        self.isViewingMapOverview = NO;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.isInitialMapRegionSet = YES;
}

- (void)changeView:(id)sender
{
    NSInteger selectedSegment = [(UISegmentedControl *)sender selectedSegmentIndex];
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
        case TAMapViewSegmentZoom:
            if (self.isViewingMapOverview) {
                if (MKMapRectIsEmpty(self.savedMapZoom)) {
                    [self.mapView setVisibleMapRectToFitStep:self.tripPlanNavigator.currentStep edgePadding:self.mapEdgePadding animated:YES];
                } else {
                    [self.mapView setVisibleMapRect:self.savedMapZoom animated:YES];
                }
                [self.segmentedControl setImage:[UIImage imageNamed:@"Overview"] forSegmentAtIndex:TAMapViewSegmentZoom];
                self.isViewingMapOverview = NO;
            } else {
                [self overviewCurrentItineraryAnimated:YES];
            }
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
            listView.delegate = self;
            listView.dataSource = self;
            listView.allowsSelection = NO;
            [self.view addSubview:listView];
            self.listView = listView;
            [self.listView reloadData];
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
    self.savedMapZoom = MKMapRectNull;
}

- (NSInteger)numberOfStepsInScrollView:(TAStepScrollView *)scrollView
{
    return [self.tripPlanNavigator numberOfStepsInCurrentItinerary];
}

- (TAStepView *)stepScrollView:(TAStepScrollView *)scrollView viewForStepAtIndex:(NSInteger)index
{
    TAStep *step = [self.tripPlanNavigator stepWithIndex:index];
    
    TAStepView *stepView = nil;
    
    if ([step isKindOfClass:[TAPlaceStep class]]) {
        static NSString *placeStepViewID = @"placeStepViewID";
        TAPlaceStepView *placeStepView = (TAPlaceStepView *)[scrollView dequeueReusableStepWithIdentifier:placeStepViewID];
        if (placeStepView == nil) {
            placeStepView = [[TAPlaceStepView alloc] initWithReuseIdentifier:placeStepViewID];
        }
        
        TAPlaceStep *placeStep = (TAPlaceStep *)step;
        if (placeStep.isDestination) {
            placeStepView.mainLabel.text = placeStep.mainDescription;
            placeStepView.detailsLabel.text = nil;
        } else {
            placeStepView.mainLabel.text = placeStep.startDateDescription;
            placeStepView.detailsLabel.text = placeStep.endDateDescription;
        }
        
        stepView = placeStepView;
        
    } else if ([step isKindOfClass:[TAWalkStep class]]) {
        static NSString *walkStepViewID = @"walkStepViewID";
        TAWalkStepView *walkStepView = (TAWalkStepView *)[scrollView dequeueReusableStepWithIdentifier:walkStepViewID];
        if (walkStepView == nil) {
            walkStepView = [[TAWalkStepView alloc] initWithReuseIdentifier:walkStepViewID];
        }
        
        TAWalkStep *walkStep = (TAWalkStep *)step;
        
        walkStepView.mainLabel.text = walkStep.mainDescription;
        walkStepView.distanceLabel.text = walkStep.distanceDescription;
        
        stepView = walkStepView;

    } else {
        static NSString *transitStepViewID = @"transitStepViewID";
        TATransitStepView *transitStepView = (TATransitStepView *)[scrollView dequeueReusableStepWithIdentifier:transitStepViewID];
        if (transitStepView == nil) {
            transitStepView = [[TATransitStepView alloc] initWithReuseIdentifier:transitStepViewID];
        }
        
        TATransitStep *transitStep = (TATransitStep *)step;
        
        transitStepView.mainLabel.text = transitStep.mainDescription;
        transitStepView.detailsLabel.text = transitStep.detailsDescription;
        transitStepView.dateLabel.text = transitStep.scheduledDateDescription;
        
        stepView = transitStepView;
    }

    return stepView;
}

- (void)stepScrollView:(TAStepScrollView *)scrollView didScrollToStep:(TAStepView *)step atIndex:(NSInteger)index
{
    if (index == self.tripPlanNavigator.currentStepIndex) {
        return;
    }
    
    [self.tripPlanNavigator moveToStepWithIndex:index];
    
    [self.currentStepAnnotation setCoordinateToStep:self.tripPlanNavigator.currentStep];
    [self.mapView setVisibleMapRectToFitStep:self.tripPlanNavigator.currentStep edgePadding:self.mapEdgePadding animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tripPlanNavigator numberOfStepsInCurrentItinerary];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    } else {
        // Reset cell
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    
    TAStep *step = [self.tripPlanNavigator stepWithIndex:indexPath.row];
    cell.textLabel.text = step.mainDescription;
    
    if ([step isKindOfClass:[TATransitStep class]]) {
        cell.detailTextLabel.text = ((TATransitStep *)step).detailsDescription;
    }
    
    return cell;
}

@end