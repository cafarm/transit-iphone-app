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
#import "OTPItinerary.h"
#import "OTPLeg.h"
#import "OTPPlace.h"
#import "TADirectionsTableViewController.h"
#import "TATransitOptionsViewController.h"

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

@property (nonatomic) BOOL shouldShowPreferredItinerary;
@property (nonatomic) BOOL shouldOverlayPreferredItinerary;

- (void)changeView:(id)sender;

@end

@implementation TAMapViewController

@synthesize mapView = _mapView;
@synthesize segmentedControl = _segmentedControl;

@synthesize startButton = _startButton;
@synthesize overviewButton = _overviewButton;
@synthesize resumeButton = _resumeButton;

@synthesize shouldShowPreferredItinerary = _shouldShowPreferredItinerary;
@synthesize shouldOverlayPreferredItinerary = _shouldOverlayPreferredItinerary;

@synthesize objectManager = _objectManager;
@synthesize tripPlan = _tripPlan;

- (id)initWithObjectManager:(OTPObjectManager *)objectManager tripPlan:(OTPTripPlan *)tripPlan
{
    self = [super init];
    if (self) {
        _objectManager = objectManager;
        _tripPlan = tripPlan;
    }
    return self;
}

- (void)loadView
{    
    self.startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                        style:UIBarButtonItemStyleDone target:self
                                                       action:@selector(startPreferredItinerary)];
    
    self.navigationItem.rightBarButtonItem = self.startButton;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, 320, 100)];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(7, 380, 117, 30)];
    segmentedControl.momentary = YES;
    [segmentedControl insertSegmentWithTitle:@"fol" atIndex:TACurrentLocation animated:NO];
    [segmentedControl insertSegmentWithTitle:@"lst" atIndex:TADirectionsList animated:NO];
    [segmentedControl insertSegmentWithTitle:@"opt" atIndex:TATransitOptions animated:NO];
    [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl = segmentedControl;
        
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];

//    [mapView addSubview:scrollView];
    [mapView addSubview:segmentedControl];
    mapView.showsUserLocation = YES;
    mapView.region = kSeattleRegion;
    mapView.delegate = self;
    self.mapView = mapView;
    
    self.view = mapView;
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
                                                          action:@selector(overviewPreferredItinerary)];
    }
    return _overviewButton;
}

- (UIBarButtonItem *)resumeButton
{
    if (_resumeButton == nil) {
        _resumeButton = [[UIBarButtonItem alloc] initWithTitle:@"Resume"
                                                         style:UIBarButtonItemStyleDone
                                                        target:self
                                                        action:@selector(resumePreferredItinerary)];
    }
    return _resumeButton;
}

- (void)overlayPreferredItinerary
{
    [self.mapView addOverlayForItinerary:self.tripPlan.preferredItinerary];
}

- (void)overviewPreferredItinerary
{
    [self overviewPreferredItineraryAnimated:YES];
}

- (void)overviewPreferredItineraryAnimated:(BOOL)animated
{
    [self.mapView setRegionToFitItinerary:self.tripPlan.preferredItinerary animated:animated];
    
    if (self.tripPlan.preferredItinerary.isStarted) {
        [self.navigationItem setRightBarButtonItem:self.resumeButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:self.startButton animated:YES];
    }
}

- (void)startPreferredItinerary
{
    [self startPreferredItineraryAnimated:YES];
}

- (void)startPreferredItineraryAnimated:(BOOL)animated
{
    self.tripPlan.preferredItinerary.currentLegIndex = 0;
    
    [self.mapView setRegionToFitLeg:self.tripPlan.preferredItinerary.currentLeg animated:animated];
    
    [self.navigationItem setRightBarButtonItem:self.overviewButton animated:animated];
    
    self.tripPlan.preferredItinerary.isStarted = YES;
}

- (void)resumePreferredItinerary
{
    [self resumePreferredItineraryAnimated:YES];
}

- (void)resumePreferredItineraryAnimated:(BOOL)animated
{
    self.tripPlan.preferredItinerary.currentLegIndex++;
    
    [self.mapView setRegionToFitLeg:self.tripPlan.preferredItinerary.currentLeg animated:animated];
    
    [self.navigationItem setRightBarButtonItem:self.overviewButton animated:animated];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [UIColor blueColor];
		polylineView.lineWidth = 13 / 2;
		return polylineView;
	}
	
	return [[MKOverlayView alloc] initWithOverlay:overlay];
	
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
        
        [self overviewPreferredItineraryAnimated:YES];
        
        // We want the map to complete it's animation before overlaying the preferred itinerary
        self.shouldOverlayPreferredItinerary = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.shouldOverlayPreferredItinerary) {
        [self overlayPreferredItinerary];
        
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

@end