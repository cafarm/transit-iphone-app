//
//  TAMapViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAMapViewController.h"

@interface TAMapViewController ()
{
    char currentLocationPressCycle;
}

@property (strong, nonatomic) UIBarButtonItem *startButton;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

- (void)changeView:(id)sender;

@end

@implementation TAMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentLocationPressCycle = 0;
        
        [self setStartButton:[[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleDone target:self action:@selector(start)]];
        [[self navigationItem] setRightBarButtonItem:[self startButton]];
        
        [self setSegmentedControl:[[UISegmentedControl alloc] initWithFrame:CGRectMake(7, 380, 117, 30)]];
        [[self segmentedControl] setMomentary:YES];
        [[self segmentedControl] insertSegmentWithTitle:@"fol" atIndex:TACurrentLocation animated:NO];
        [[self segmentedControl] insertSegmentWithTitle:@"lis" atIndex:TADirectionsList animated:NO];
        [[self segmentedControl] insertSegmentWithTitle:@"opt" atIndex:TATransitOptions animated:NO];
        
        [[self segmentedControl] addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
        
        [[self view] addSubview:[self segmentedControl]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)changeView:(id)sender
{
    TAMapViewControl selectedSegment = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    switch (selectedSegment) {
        case TACurrentLocation:
            currentLocationPressCycle++;
            if (currentLocationPressCycle == 1) {
                [self followCurrentLocation];
                [[self segmentedControl] setTitle:@"hed" forSegmentAtIndex:TACurrentLocation];
            } else if (currentLocationPressCycle == 2) {
                [self followCurrentLocationWithHeading];
                [[self segmentedControl] setTitle:@"off" forSegmentAtIndex:TACurrentLocation];
            } else {
                [self stopFollowingCurrentLocation];
            }
            break;
        case TADirectionsList:
            NSLog(@"dir list");
            break;
        case TATransitOptions:
            NSLog(@"dir list");
        default:
            break;
    }
}

- (void)followCurrentLocation
{    
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)followCurrentLocationWithHeading
{
    [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (void)stopFollowingCurrentLocation
{
    [mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MKUserTrackingModeNone) {
        [[self segmentedControl] setTitle:@"fol" forSegmentAtIndex:TACurrentLocation];
        currentLocationPressCycle = 0;
    }
}

- (void)startStepByStep
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
