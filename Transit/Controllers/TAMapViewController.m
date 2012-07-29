//
//  TAMapViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAMapViewController.h"
#import "TAMapView.h"
#import "OTPTripPlan.h"
#import "OTPItinerary.h"
#import "OTPLeg+Polyline.h"
#import "OTPPlace.h"
#import "TAPlaceAnnotation.h"
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

@property (weak, nonatomic) TAMapView *mapView;
@property (weak, nonatomic) UIBarButtonItem *startButton;
@property (weak, nonatomic) UISegmentedControl *segmentedControl;

@property (nonatomic) BOOL shouldShowSelectedItineraryOverview;
@property (nonatomic) BOOL shouldOverlaySelectedItinerary;

- (void)changeView:(id)sender;

@end

@implementation TAMapViewController

@synthesize mapView = _mapView;
@synthesize startButton = _startButton;
@synthesize segmentedControl = _segmentedControl;

@synthesize shouldShowSelectedItineraryOverview = _shouldShowSelectedItineraryOverview;
@synthesize shouldOverlaySelectedItinerary = _shouldOverlaySelectedItinerary;

@synthesize tripPlan = _tripPlan;
@synthesize selectedItineraryIndex = _selectedItineraryIndex;

- (void)loadView
{    
    UIBarButtonItem *startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                                    style:UIBarButtonItemStyleDone target:self
                                                                   action:@selector(startStepByStepMap)];
    
    self.navigationItem.rightBarButtonItem = startButton;
    self.startButton = startButton;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(7, 380, 117, 30)];
    segmentedControl.momentary = YES;
    [segmentedControl insertSegmentWithTitle:@"fol" atIndex:TACurrentLocation animated:NO];
    [segmentedControl insertSegmentWithTitle:@"lst" atIndex:TADirectionsList animated:NO];
    [segmentedControl insertSegmentWithTitle:@"opt" atIndex:TATransitOptions animated:NO];
    [segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl = segmentedControl;
        
    TAMapView *mapView = [[TAMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    [mapView addSubview:segmentedControl];
    mapView.region = kSeattleRegion;
    mapView.delegate = self;
    self.mapView = mapView;
    
    self.view = mapView;
    
    self.shouldOverlaySelectedItinerary = NO;
    self.shouldShowSelectedItineraryOverview = NO;
}

- (void)viewDidLoad
{
    self.selectedItineraryIndex = 0;
    
    // we want the map tiles to finish loading before showing the itinerary overview
    self.shouldShowSelectedItineraryOverview = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSelectedItineraryOverviewAnimated:(BOOL)animated
{
    OTPItinerary *selectedItinerary = [self.tripPlan.itineraries objectAtIndex:self.selectedItineraryIndex];
    
    [self.mapView setRegionToItinerary:selectedItinerary animated:animated];
    
    // we want the map to finish setting the region before overlaying the itinerary
    self.shouldOverlaySelectedItinerary = YES;
}

- (void)overlaySelectedItinerary
{
    OTPItinerary *selectedItinerary = [self.tripPlan.itineraries objectAtIndex:self.selectedItineraryIndex];
    [self overlayItinerary:selectedItinerary];
}

- (void)overlayItinerary:(OTPItinerary *)itinerary
{
    for (OTPLeg *leg in itinerary.legs) {
        BOOL isLast = leg == itinerary.legs.lastObject;
        
        [self overlayLeg:leg isLast:isLast];
    }
}

- (void)overlayLeg:(OTPLeg *)leg isLast:(BOOL)isLast
{
    if (!isLast) {
        TAPlaceAnnotation *fromAnnotation = [[TAPlaceAnnotation alloc] initWithPlace:leg.from];
        [self.mapView addAnnotation:fromAnnotation];
    } else {
        TAPlaceAnnotation *toAnnotation = [[TAPlaceAnnotation alloc] initWithPlace:leg.to];
        [self.mapView addAnnotation:toAnnotation];
    }

    MKPolyline *polyline = leg.legPolyline;
    
    [self.mapView addOverlay:polyline];
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
            [self presentDirectionsTable];
            break;
        case TATransitOptions:
            [self presentTransitOptions];
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

- (void)setSelectedItineraryIndex:(int)selectedItineraryIndex
{
    NSAssert(selectedItineraryIndex >= 0 && selectedItineraryIndex <= [self.tripPlan.itineraries count], nil);
    
    _selectedItineraryIndex = selectedItineraryIndex;
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone) {
        [self.segmentedControl setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if (self.shouldShowSelectedItineraryOverview) {
        [self showSelectedItineraryOverviewAnimated:YES];
        self.shouldShowSelectedItineraryOverview = NO;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.shouldOverlaySelectedItinerary) {
        [self overlaySelectedItinerary];
        self.shouldOverlaySelectedItinerary = NO;
    }
}

- (void)presentDirectionsTable
{
    TADirectionsTableViewController *directionsController = [[TADirectionsTableViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:directionsController];
        
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)presentTransitOptions
{
    TATransitOptionsViewController *optionsController = [[TATransitOptionsViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:optionsController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)startStepByStepMap
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
