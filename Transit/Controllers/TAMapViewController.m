//
//  TAMapViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAMapViewController.h"
#import "TADirectionsTableViewController.h"
#import "TATransitOptionsViewController.h"

typedef enum {
    TACurrentLocation,
    TADirectionsList,
    TATransitOptions
} TAMapViewControl;

@interface TAMapViewController ()
{
    UIBarButtonItem *_transitButton;
    UIBarButtonItem *_startButton;
    IBOutlet MKMapView *_mapView;
    UISegmentedControl *_segmentedControl;
}

- (void)changeView:(id)sender;

@end

@implementation TAMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        _startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleDone target:self action:@selector(startStepByStepMap)];
        self.navigationItem.rightBarButtonItem = _startButton;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(7, 380, 117, 30)];
    _segmentedControl.momentary = YES;
    [_segmentedControl insertSegmentWithTitle:@"fol" atIndex:TACurrentLocation animated:NO];
    [_segmentedControl insertSegmentWithTitle:@"lst" atIndex:TADirectionsList animated:NO];
    [_segmentedControl insertSegmentWithTitle:@"opt" atIndex:TATransitOptions animated:NO];
    
    [_segmentedControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_segmentedControl];
}

- (void)changeView:(id)sender
{
    TAMapViewControl selectedSegment = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    switch (selectedSegment) {
        case TACurrentLocation:
            if (_mapView.userTrackingMode == MKUserTrackingModeNone) {
                [self followCurrentLocation];
            } else if (_mapView.userTrackingMode == MKUserTrackingModeFollow) {
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
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [_segmentedControl setTitle:@"hed" forSegmentAtIndex:TACurrentLocation];
}

- (void)followCurrentLocationWithHeading
{
    [_mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [_segmentedControl setTitle:@"off" forSegmentAtIndex:TACurrentLocation];
}

- (void)stopFollowingCurrentLocation
{
    [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    [ _segmentedControl setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone) {
        [_segmentedControl setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
