//
//  TAMapViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAMapViewController.h"
#import "MKMapView+Transit.h"
#import "OTPTripPlan.h"
#import "TATripPlanNavigator.h"
#import "OTPItinerary.h"
#import "OTPLeg.h"
#import "OTPPlace.h"
#import "TAStep.h"
#import "TADirectionsTableViewController.h"
#import "TATransitOptionsViewController.h"
#import "TAStepView.h"
#import "TACurrentStepAnnotation.h"

typedef enum {
    TACurrentLocation,
    TADirectionsList,
    TATransitOptions
} TAMapViewControl;

// TODO: perfect this number
static const MKCoordinateRegion kSeattleRegion = {
    .center = {
        .latitude = 47.6097,
        .longitude = -122.3331
    },
    .span = {
        .latitudeDelta = .5,
        .longitudeDelta = 0
    }
};

@interface TAMapViewController ()

@property (strong, nonatomic) TACurrentStepAnnotation *currentStepAnnotation;

@property (nonatomic) BOOL shouldShowPreferredItinerary;
@property (nonatomic) BOOL shouldOverlayPreferredItinerary;

@end


@implementation TAMapViewController

@synthesize objectManager = _objectManager;
@synthesize tripPlanNavigator = _tripPlanNavigator;

@synthesize startButton = _startButton;
@synthesize overviewButton = _overviewButton;
@synthesize resumeButton = _resumeButton;

@synthesize mapView = _mapView;
@synthesize stepScrollView = _stepScrollView;
@synthesize segmentedControl = _segmentedControl;

@synthesize currentStepAnnotation = _currentStepAnnotation;

@synthesize shouldShowPreferredItinerary = _shouldShowPreferredItinerary;
@synthesize shouldOverlayPreferredItinerary = _shouldOverlayPreferredItinerary;

- (id)initWithObjectManager:(OTPObjectManager *)objectManager tripPlanNavigator:(TATripPlanNavigator *)tripPlanNavigator
{
    self = [super init];
    if (self) {
        _objectManager = objectManager;
        _tripPlanNavigator = tripPlanNavigator;
    }
    return self;
}

- (void)loadView
{    
    _startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                    style:UIBarButtonItemStyleDone target:self
                                                   action:@selector(startCurrentItinerary)];
    
    self.navigationItem.rightBarButtonItem = self.startButton;
    
    // We need a container view because using the MKMapView as the root view freezes all the controls on animation
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:containerView.bounds];
    mapView.showsUserLocation = YES;
    mapView.region = kSeattleRegion;
    mapView.delegate = self;
    _mapView = mapView;
    [containerView addSubview:mapView];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(7, 380, 117, 30)];
    segmentedControl.momentary = YES;
    [segmentedControl insertSegmentWithTitle:@"fol" atIndex:TACurrentLocation animated:NO];
    [segmentedControl insertSegmentWithTitle:@"lst" atIndex:TADirectionsList animated:NO];
    [segmentedControl insertSegmentWithTitle:@"opt" atIndex:TATransitOptions animated:NO];
    [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl = segmentedControl;
    [containerView addSubview:segmentedControl];
    
    TAStepScrollView *stepScrollView = [[TAStepScrollView alloc] initWithFrame:CGRectMake(0, 8, 320, 129)];
    stepScrollView.delegate = self;
    stepScrollView.dataSource = self;
    [stepScrollView reloadData];
    _stepScrollView = stepScrollView;
    [containerView addSubview:stepScrollView];
    
    self.view = containerView;
}

- (void)viewDidLoad
{    
    // We want the map tiles to finish loading before showing (overviewing and overlaying) the preferred itinerary
    self.shouldShowPreferredItinerary = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // TODO: find out how to properly release strong references
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIBarButtonItem *)overviewButton
{
    if (_overviewButton == nil) {
        _overviewButton = [[UIBarButtonItem alloc] initWithTitle:@"Overview"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(overviewCurrentItinerary)];
    }
    return _overviewButton;
}

- (UIBarButtonItem *)resumeButton
{
    if (_resumeButton == nil) {
        _resumeButton = [[UIBarButtonItem alloc] initWithTitle:@"Resume"
                                                         style:UIBarButtonItemStyleDone
                                                        target:self
                                                        action:@selector(resumeCurrentItinerary)];
    }
    return _resumeButton;
}

- (void)overlayCurrentItinerary
{
    [self.mapView addOverlayForItinerary:self.tripPlanNavigator.currentItinerary];
    [self.mapView addAnnotationsForSteps:self.tripPlanNavigator.stepsInCurrentItinerary];
}

- (void)overviewCurrentItinerary
{
    [self overviewCurrentItineraryAnimated:YES];
}

- (void)overviewCurrentItineraryAnimated:(BOOL)animate
{
    [self.mapView setVisibleMapRectToFitItinerary:self.tripPlanNavigator.currentItinerary animated:animate];
    
    if (self.tripPlanNavigator.isCurrentItineraryStarted) {
        [self.navigationItem setRightBarButtonItem:self.resumeButton animated:animate];
    } else {
        [self.navigationItem setRightBarButtonItem:self.startButton animated:animate];
    }
}

- (void)startCurrentItinerary
{
    [self startCurrentItineraryAnimated:YES];
}

- (void)startCurrentItineraryAnimated:(BOOL)animate
{
    [self.tripPlanNavigator startCurrentItinerary];
    
    [self.mapView setVisibleMapRectToFitStep:self.tripPlanNavigator.currentStep animated:animate];
    self.currentStepAnnotation = [self.mapView addAnnotationForCurrentStep:self.tripPlanNavigator.currentStep];
    
    [self.navigationItem setRightBarButtonItem:self.overviewButton animated:animate];
}

- (void)resumeCurrentItinerary
{
    [self resumeCurrentItineraryAnimated:YES];
}

- (void)resumeCurrentItineraryAnimated:(BOOL)animate
{
    [self.mapView setVisibleMapRectToFitStep:self.tripPlanNavigator.currentStep animated:animate];
    
    [self.navigationItem setRightBarButtonItem:self.overviewButton animated:animate];
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
            currentStepView.image = [UIImage imageNamed:@"currentStepAnnotation.png"];
            currentStepView.canShowCallout = NO;
        } else {
            currentStepView.annotation = annotation;
        }
        return currentStepView;
    }
    return nil;
}

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
    TAMapViewControl selectedSegment = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    switch (selectedSegment) {
        case TACurrentLocation:
            if (self.mapView.userTrackingMode == MKUserTrackingModeNone) {
                [self followCurrentLocation];
            } else if (self.mapView.userTrackingMode == MKUserTrackingModeFollow) {
                [self followCurrentLocationWithHeading];
            } else {
                [self stopFollowingCurrentLocation];
            }
            break;
        case TADirectionsList:
            [self presentDirectionsTableViewController];
            break;
        case TATransitOptions:
            [self presentTransitOptionsViewController];
            break;
        default:
            break;
    }
}

- (void)followCurrentLocation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.segmentedControl setTitle:@"hed" forSegmentAtIndex:TACurrentLocation];
}

- (void)followCurrentLocationWithHeading
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [self.segmentedControl setTitle:@"off" forSegmentAtIndex:TACurrentLocation];
}

- (void)stopFollowingCurrentLocation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    [self.segmentedControl setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone) {
        [self.segmentedControl setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if (self.shouldShowPreferredItinerary) {
        self.shouldShowPreferredItinerary = NO;
        
        [self overviewCurrentItineraryAnimated:YES];
        
        // We want the map to complete it's animation before overlaying the preferred itinerary
        self.shouldOverlayPreferredItinerary = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.shouldOverlayPreferredItinerary) {
        [self overlayCurrentItinerary];
        
        self.shouldOverlayPreferredItinerary = NO;
    }
}

- (void)presentDirectionsTableViewController
{
    TADirectionsTableViewController *directionsController = [[TADirectionsTableViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:directionsController];
        
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)presentTransitOptionsViewController
{
    TATransitOptionsViewController *optionsController = [[TATransitOptionsViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:optionsController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (NSInteger)numberOfStepsInScrollView:(TAStepScrollView *)scrollView
{
    return [self.tripPlanNavigator numberOfStepsInCurrentItinerary];
}

- (TAStepView *)stepScrollView:(TAStepScrollView *)scrollView viewForStepAtIndex:(NSInteger)index
{
    static NSString *stepID = @"stepID";
    TAStepView *stepView = [scrollView dequeueReusableStepWithIdentifier:stepID];
    if (!stepView) {
        stepView = [[TAStepView alloc] initWithFrame:CGRectMake(0, 0, 268, 129)];
        stepView.backgroundColor = [UIColor grayColor];
        stepView.reuseIdentifier = stepID;
    }
    return stepView;
}

- (void)stepScrollView:(TAStepScrollView *)scrollView didScrollToStep:(TAStepView *)step atIndex:(NSInteger)index
{
    [self.tripPlanNavigator moveToStepWithIndex:index];
    
    [self.currentStepAnnotation setCoordinate:self.tripPlanNavigator.currentStep.coordinate];
    [self.mapView setVisibleMapRectToFitStep:self.tripPlanNavigator.currentStep animated:YES];
}

@end