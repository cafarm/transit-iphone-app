//
//  TAMapViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAMapViewController.h"
#import "TALocationManager.h"
#import "TATripPlanNavigator.h"
#import "TAWalkStep.h"
#import "TATransitStep.h"
#import "TADirectionsTableViewController.h"
#import "TATransitOptionsViewController.h"
#import "TAStepView.h"
#import "TAStepAnnotation.h"
#import "TACurrentStepAnnotation.h"
#import "TAWalkStepView.h"
#import "TATransitStepView.h"
#import "OTPClient.h"
#import "MKMapView+Transit.h"

typedef enum {
    TACurrentLocation,
    TADirectionsList,
    TATransitOptions
} TAMapViewControl;

@interface TAMapViewController ()

@property (strong, nonatomic) TACurrentStepAnnotation *currentStepAnnotation;

@property (nonatomic) BOOL isViewingStepByStep;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation TAMapViewController

@synthesize objectManager = _objectManager;
@synthesize locationManager = _locationManager;
@synthesize tripPlanNavigator = _tripPlanNavigator;

@synthesize startButton = _startButton;
@synthesize overviewButton = _overviewButton;
@synthesize resumeButton = _resumeButton;

@synthesize stepScrollView = _stepScrollView;

@synthesize mapView = _mapView;

@synthesize overviewSegmentedControl = _overviewSegmentedControl;
@synthesize stepByStepSegmentedControl = _stepByStepSegmentedControl;

@synthesize currentStepAnnotation = _currentStepAnnotation;

@synthesize isViewingStepByStep = _isViewingStepByStep;

@synthesize dateFormatter = _dateFormatter;

- (id)initWithObjectManager:(OTPObjectManager *)objectManager locationManager:(TALocationManager *)locationManager tripPlanNavigator:(TATripPlanNavigator *)tripPlanNavigator
{
    self = [super init];
    if (self) {
        _objectManager = objectManager;
        _locationManager = locationManager;
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
    mapView.visibleMapRect = self.tripPlanNavigator.currentItinerary.boundingMapRect;
    mapView.delegate = self;
    _mapView = mapView;
    [containerView addSubview:mapView];
    
    UISegmentedControl *overviewSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(7, 380, 117, 30)];
    overviewSegmentedControl.momentary = YES;
    [overviewSegmentedControl insertSegmentWithTitle:@"fol" atIndex:TACurrentLocation animated:NO];
    [overviewSegmentedControl insertSegmentWithTitle:@"lst" atIndex:TADirectionsList animated:NO];
    [overviewSegmentedControl insertSegmentWithTitle:@"opt" atIndex:TATransitOptions animated:NO];
    [overviewSegmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    _overviewSegmentedControl = overviewSegmentedControl;
    [containerView addSubview:overviewSegmentedControl];
    
    UISegmentedControl *stepByStepSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(7, 380, 39, 30)];
    stepByStepSegmentedControl.momentary = YES;
    [stepByStepSegmentedControl insertSegmentWithTitle:@"fol" atIndex:TACurrentLocation animated:NO];
    [stepByStepSegmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    stepByStepSegmentedControl.hidden = YES;
    _stepByStepSegmentedControl = stepByStepSegmentedControl;
    [containerView addSubview:stepByStepSegmentedControl];
    
    self.view = containerView;
}

- (void)viewDidLoad
{
    [self overlayCurrentItinerary];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    BOOL isMovingFromParentViewController = self.isMovingFromParentViewController;
    [self hideStepScrollViewWithCompletion:^(BOOL finished) {
        // Don't remove the stepScrollView if we're presenting a view controller
        if (isMovingFromParentViewController) {
            [self.stepScrollView removeFromSuperview];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // TODO: find out how to properly release strong references
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

- (TAStepScrollView *)stepScrollView
{
    if (_stepScrollView == nil) {
        _stepScrollView = [[TAStepScrollView alloc] initWithFrame:CGRectMake(0, -129, 320, 129)];
        _stepScrollView.delegate = self;
        _stepScrollView.dataSource = self;
        [_stepScrollView reloadData];
    }
    return _stepScrollView;
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
    [self hideStepScrollViewWithCompletion:^(BOOL finished) {
        [self.mapView viewForAnnotation:self.currentStepAnnotation].hidden = YES;
        
        // TODO: Animate this transition?
        self.stepByStepSegmentedControl.hidden = YES;
        self.overviewSegmentedControl.hidden = NO;

        [self.mapView setVisibleMapRectToFitItinerary:self.tripPlanNavigator.currentItinerary animated:animate];
        self.isViewingStepByStep = NO;
        
        if (self.tripPlanNavigator.isCurrentItineraryStarted) {
            [self.navigationItem setRightBarButtonItem:self.resumeButton animated:animate];
        } else {
            [self.navigationItem setRightBarButtonItem:self.startButton animated:animate];
        }
    }];
}

- (void)startCurrentItinerary
{
    [self startCurrentItineraryAnimated:YES];
}

- (void)startCurrentItineraryAnimated:(BOOL)animate
{
    [self.tripPlanNavigator startCurrentItinerary];
    
    self.currentStepAnnotation = [self.mapView addAnnotationForCurrentStep:self.tripPlanNavigator.currentStep];
    
    [self.navigationController.view addSubview:self.stepScrollView];
    [self showStepScrollViewWithCompletion:^(BOOL finished) {
        [self resumeCurrentItineraryAnimated:animate];
    }];
}

- (void)resumeCurrentItinerary
{
    [self resumeCurrentItineraryAnimated:YES];
}

- (void)resumeCurrentItineraryAnimated:(BOOL)animate
{    
    [self showStepScrollViewWithCompletion:^(BOOL finished) {
        [self.mapView viewForAnnotation:self.currentStepAnnotation].hidden = NO;

        self.overviewSegmentedControl.hidden = YES;
        self.stepByStepSegmentedControl.hidden = NO;
        
        [self.mapView setVisibleMapRectToFitStep:self.tripPlanNavigator.currentStep animated:animate];
        self.isViewingStepByStep = YES;
        
        [self.navigationItem setRightBarButtonItem:self.overviewButton animated:animate];
    }];
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
            currentStepView.enabled = NO;
            currentStepView.hidden = YES;
        } else {
            currentStepView.annotation = annotation;
        }
        return currentStepView;
    } else if ([annotation isKindOfClass:[TAStepAnnotation class]]) {
        MKPinAnnotationView *stepView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"stepID"];
        if (!stepView) {
            stepView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"stepID"];
            stepView.pinColor = MKPinAnnotationColorPurple;
            stepView.canShowCallout = YES;
        } else {
            stepView.annotation = annotation;
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.isViewingStepByStep) {
        NSSet *visibleAnnotations = [mapView annotationsInMapRect:mapView.visibleMapRect];
        if (![visibleAnnotations containsObject:self.currentStepAnnotation]) {
            for (id<MKAnnotation> annotation in visibleAnnotations) {
                if ([annotation isKindOfClass:[TAStepAnnotation class]]) {
                    TAStep *step = ((TAStepAnnotation *)annotation).step;
                    [self.tripPlanNavigator moveToStep:step];
                    [self.stepScrollView scrollToStepAtIndex:self.tripPlanNavigator.currentStepIndex animated:YES];
                    [self.currentStepAnnotation setCoordinateToStep:step];
                    break;
                }
            }
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
    [self.overviewSegmentedControl setTitle:@"hed" forSegmentAtIndex:TACurrentLocation];
}

- (void)followCurrentLocationWithHeading
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [self.overviewSegmentedControl setTitle:@"off" forSegmentAtIndex:TACurrentLocation];
}

- (void)stopFollowingCurrentLocation
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    [self.overviewSegmentedControl setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone) {
        [self.overviewSegmentedControl setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
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

- (void)showStepScrollViewWithCompletion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.24 animations:^{
        self.stepScrollView.frame = CGRectMake(0, 72, 320, 129);
    } completion:^(BOOL finished) {
        completion(finished);
    }];
}

- (void)hideStepScrollViewWithCompletion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.24 animations:^{
        self.stepScrollView.frame = CGRectMake(0, -129, 320, 129);
    } completion:^(BOOL finished) {
        completion(finished);
    }];
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