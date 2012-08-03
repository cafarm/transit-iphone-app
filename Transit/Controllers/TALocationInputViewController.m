//
//  TALocationInputViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationInputViewController.h"
#import "OTPObjectManager.h"
#import "TALocationField.h"
#import "TALocationManager.h"
#import "TAMapViewController.h"

static NSString *const kNavigationTitle = @"Transit";

@interface TALocationInputViewController ()

@property (nonatomic) CLLocationCoordinate2D startCoordinate;
@property (nonatomic) CLLocationCoordinate2D endCoordinate;

- (void)lockAllViews;
- (void)unlockAllViews;

@end

@implementation TALocationInputViewController

@synthesize objectManager = _objectManager;

@synthesize clearButton = _clearButton;
@synthesize routeButton = _routeButton;

@synthesize startField = _startField;
@synthesize endField = _endField;
@synthesize swapFieldsButton = _swapFieldsButton;
@synthesize suggestedLocationsTable = _suggestedLocationsTable;

@synthesize locationManager = _locationManager;
@synthesize geocoder = _geocoder;

@synthesize startCoordinate = _startCoordinate;
@synthesize endCoordinate = _endCoordinate;

- (id)initWithObjectManager:(OTPObjectManager *)objectManager
{
    self = [super initWithNibName:@"TALocationInputViewController" bundle:nil];
    if (self) {        
        _objectManager = objectManager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = kNavigationTitle;
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(clearFields)];
    self.navigationItem.leftBarButtonItem = clearButton;
    self.clearButton = clearButton;
    
    UIBarButtonItem *routeButton = [[UIBarButtonItem alloc] initWithTitle:@"Route"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(routeTrip)];
    
    self.navigationItem.rightBarButtonItem = routeButton;
    routeButton.enabled = NO;
    self.routeButton = routeButton;
    
    self.startField.leftViewText = @"Start:  ";
    self.startField.isCurrentLocation = YES;
    self.startField.delegate = self;
    
    self.endField.leftViewText = @"End:  ";
    self.endField.delegate = self;
    
    [self.endField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // It takes a few seconds to find the current location, so we'll prepare it in the background in anticipation
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self unlockAllViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (TALocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[TALocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)clearFields
{
    self.startField.text = @"";
    self.endField.text = @"";
    
    self.clearButton.enabled = NO;
    self.routeButton.enabled = NO;
    
    [self.startField becomeFirstResponder];
}

- (IBAction)swapFields
{
    NSString *temp = self.startField.text;
    self.startField.text = self.endField.text;
    self.endField.text = temp;
}

- (void)routeTrip
{
    // Make sure user didn't swap fields to enable the route button
    if ([self.startField.text length] == 0) {
        [self.startField becomeFirstResponder];
        return;
    }
    
    if ([self.endField.text length] == 0) {
        [self.endField becomeFirstResponder];
        return;
    }
    
    [self lockAllViews];
    
    // TODO: Verify the current location has been found
    
    if (self.startField.isCurrentLocation) {
        self.startCoordinate = self.locationManager.currentLocation.coordinate;
        
        [self geocodeEndFieldWithCompletionHandler:^{
            [self pushMapViewController];
        }];
        
    } else if (self.endField.isCurrentLocation) {
        self.endCoordinate = self.locationManager.currentLocation.coordinate;
        
        [self geocodeStartFieldWithCompletionHandler:^{
            [self pushMapViewController];
        }];
        
    } else {
        [self geocodeStartFieldWithCompletionHandler:^{
            [self geocodeEndFieldWithCompletionHandler:^{
                [self pushMapViewController];
            }];
        }];
    }
}

- (void)geocodeStartFieldWithCompletionHandler:(void (^)(void))completionHandler
{
    [self.geocoder geocodeAddressString:self.startField.text
                               inRegion:self.locationManager.currentRegion
                      completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error) {
             [self showAlertViewWithError:error];
             return;
         }
         
         self.startCoordinate = ((CLPlacemark *)[placemarks objectAtIndex:0]).location.coordinate;
         
         completionHandler();
     }];
}

- (void)geocodeEndFieldWithCompletionHandler:(void (^)(void))completionHandler
{
    [self.geocoder geocodeAddressString:self.endField.text
                               inRegion:self.locationManager.currentRegion
                      completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error) {
             [self showAlertViewWithError:error];
             return;
         }
         
         self.endCoordinate = ((CLPlacemark *)[placemarks objectAtIndex:0]).location.coordinate;
         
         completionHandler();
     }];
}

- (void)pushMapViewController
{
    [self.objectManager loadTripPlanFrom:self.startCoordinate
                                      to:self.endCoordinate
                       completionHandler:^(OTPTripPlan *tripPlan, NSError *error)
    {
        if (error) {
            [self showAlertViewWithError:error];
            return;
        }
        
        TAMapViewController *mapController = [[TAMapViewController alloc] initWithObjectManager:self.objectManager
                                                                                       tripPlan:tripPlan];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:nil
                                                                                action:nil];
        [self.navigationController pushViewController:mapController animated:YES];
    }];
}

- (void)showAlertViewWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Directions Not Available"
                                                        message:error.localizedDescription
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self unlockAllViews];
}

- (void)lockAllViews
{
    self.routeButton.enabled = NO;
    self.clearButton.enabled = NO;
        
    self.navigationItem.title = @"Loading...";
    self.startField.enabled = NO;
    self.endField.enabled = NO;
    self.swapFieldsButton.enabled = NO;
    [self.view endEditing:YES];
}

- (void)unlockAllViews
{
    self.navigationItem.title = kNavigationTitle;
    self.startField.enabled = YES;
    self.endField.enabled = YES;
    self.swapFieldsButton.enabled = YES;
    [self.endField becomeFirstResponder];

    if ([self.startField.text length] > 0 && [self.endField.text length] > 0) {
        self.routeButton.enabled = YES;
    }
    
    if ([self.startField.text length] > 0 || [self.endField.text length] > 0) {
        self.clearButton.enabled = YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.endField) {
        if ([self.startField.text length] > 0) {
            self.endField.returnKeyType = UIReturnKeyRoute;
            self.endField.enablesReturnKeyAutomatically = YES;
        } else {
            self.endField.returnKeyType = UIReturnKeyNext;
            self.endField.enablesReturnKeyAutomatically = NO;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.startField) {
        [self.endField becomeFirstResponder];
    } else {
        if (textField.returnKeyType == UIReturnKeyNext) {
            [self.startField becomeFirstResponder];
        } else {
            [self routeTrip];
        }
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{    
    int currentLength = [textField.text length];
    int newLength = currentLength - range.length + [string length];
    
    if (newLength == 0) {
        
        if ([self textFieldsWillBeEmpty:textField]) {
            self.clearButton.enabled = NO;
        }
        
        self.routeButton.enabled = NO;
        
    } else if (currentLength == 0) {
        
        if ([self textFieldsWillBeComplete:textField]) {
            self.routeButton.enabled = YES;
        }
        
        self.clearButton.enabled = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self textFieldsWillBeEmpty:textField]) {
        self.clearButton.enabled = NO;
    }
    
    self.routeButton.enabled = NO;
    
    return YES;
}

- (BOOL)textFieldsWillBeEmpty:(UITextField *)textField
{
    return ((textField == self.startField) && ([self.endField.text length] == 0))
            || ((textField == self.endField) && ([self.startField.text length] == 0));
}

- (BOOL)textFieldsWillBeComplete:(UITextField *)textField
{
    return ((textField == self.startField) && ([self.endField.text length] > 0))
            || ((textField == self.endField) && ([self.startField.text length] > 0));
}

@end
