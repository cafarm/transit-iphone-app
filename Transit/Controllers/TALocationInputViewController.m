//
//  TALocationInputViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationInputViewController.h"
#import "TAMapViewController.h"
#import "OTPObjectManager.h"
#import "TALocationManager.h"

static NSString *const kNavigationTitle = @"Transit";

@interface TALocationInputViewController ()

@property (weak, nonatomic) IBOutlet UITextField *startField;
@property (weak, nonatomic) IBOutlet UITextField *endField;
@property (weak, nonatomic) IBOutlet UIButton *swapFieldsButton;
@property (weak, nonatomic) IBOutlet UITableView *suggestedLocationsTable;

@property (weak, nonatomic) UIBarButtonItem *routeButton;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLRegion *currentRegion;
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
@property (nonatomic) CLLocationCoordinate2D endCoordinate;
@property (strong, nonatomic) CLGeocoder *geocoder;

- (void)setLabelText:(NSString *)labelText forTextField:(UITextField *)textField;
- (void)lockViewController;
- (void)unlockViewController;

@end

@implementation TALocationInputViewController

@synthesize startField = _startField;
@synthesize endField = _endField;
@synthesize swapFieldsButton = _swapFieldsButton;
@synthesize suggestedLocationsTable = _suggestedLocationsTable;

@synthesize routeButton = _routeButton;

@synthesize currentLocation = _currentLocation;
@synthesize currentRegion = _currentRegion;
@synthesize startCoordinate = _startCoordinate;
@synthesize endCoordinate = _endCoordinate;
@synthesize geocoder = _geocoder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = kNavigationTitle;
    
    UIBarButtonItem *routeButton = [[UIBarButtonItem alloc] initWithTitle:@"Route"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(route)];
    
    self.navigationItem.rightBarButtonItem = routeButton;
    routeButton.enabled = NO;
    self.routeButton = routeButton;
    
    [self setLabelText:@"Start:  " forTextField:self.startField];
    self.startField.delegate = self;
    
    [self setLabelText:@"End:  " forTextField:self.endField];
    self.endField.delegate = self;
    
    [self.endField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
            
    // clear out any cached current location
    self.currentLocation = nil;
    
    // it takes a few seconds to find the current location, so we'll prepare and monitor it in the background
    TALocationManager *locationManager = [TALocationManager sharedManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 10;
    [locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self unlockViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLabelText:(NSString *)labelText forTextField:(UITextField *)textField
{
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, 45, 31)];
    label.font = textField.font;
    label.textAlignment = UITextAlignmentRight;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = labelText;

    // a view to shift the label up to align with text field input
    UIView *view = [[UIView alloc] init];
    view.frame = label.frame;
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    textField.leftView = view;
}

- (IBAction)swapFields
{
    NSString *temp = self.startField.text;
    self.startField.text = self.endField.text;
    self.endField.text = temp;
}

- (void)route
{
    // make sure user didn't swap fields to enable the route button
    if ([self.startField.text length] == 0) {
        [self.startField becomeFirstResponder];
        return;
    }
    
    if ([self.endField.text length] == 0) {
        [self.endField becomeFirstResponder];
        return;
    }
    
    [self lockViewController];
    
    // TODO: verify the current location has been found
    
    if ([self.startField.text isEqualToString:@"Current Location"]) {
        self.startCoordinate = self.currentLocation.coordinate;
        
        [self geocodeAddressString:self.endField.text toCoordinate:&_endCoordinate completionHandler:^{
            [self loadTripPlan];
        }];
        
    } else if ([self.endField.text isEqualToString:@"Current Location"]) {
        self.endCoordinate = self.currentLocation.coordinate;
        
        [self geocodeAddressString:self.startField.text toCoordinate:&_startCoordinate completionHandler:^{
            [self loadTripPlan];
        }];
        
    } else {
        [self geocodeAddressString:self.startField.text toCoordinate:&_startCoordinate completionHandler:^{
            [self geocodeAddressString:self.endField.text toCoordinate:&_endCoordinate completionHandler:^{
                [self loadTripPlan];
            }];
        }];
    }
}

- (void)loadTripPlan
{
    OTPObjectManager *objectManager = [OTPObjectManager sharedManager];
    
    [objectManager loadTripPlanFrom:self.startCoordinate
                                 to:self.endCoordinate
                  completionHandler:^(OTPTripPlan *tripPlan, NSError *error) {
                      
                      if (error) {
                          [self showAlertViewWithError:error];
                          return;
                      }
                      
                      TAMapViewController *mapController = [[TAMapViewController alloc] init];
                      mapController.tripPlan = tripPlan;
                      
                      self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                               style:UIBarButtonItemStyleBordered
                                                                                              target:nil
                                                                                              action:nil];
                      [self.navigationController pushViewController:mapController animated:YES];
                  }];
}

- (void)geocodeAddressString:(NSString *)addressString
                toCoordinate:(CLLocationCoordinate2D *)coordinate
           completionHandler:(void (^)(void))completionHandler {
        
    __block CLLocationCoordinate2D *blockCoordinate = coordinate;
    [self.geocoder geocodeAddressString:addressString
                               inRegion:self.currentRegion
                      completionHandler:^(NSArray *placemarks, NSError *error) {
        
                          if (error) {
                              [self showAlertViewWithError:error];
                              return;
                          }
                          
                          // assume the first placemark is the best choice
                          CLPlacemark *placemark = [placemarks objectAtIndex:0];
                          
                          *blockCoordinate = placemark.location.coordinate;
                          
                          completionHandler();
                      }];
}

- (CLRegion *)currentRegion
{
    return [[CLRegion alloc] initCircularRegionWithCenter:self.currentLocation.coordinate
                                                   radius:16000
                                               identifier:@"currentRegion"];
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
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
    [self unlockViewController];
}

- (void)lockViewController
{
    self.routeButton.enabled = NO;
        
    self.navigationItem.title = @"Loading...";
    self.startField.enabled = NO;
    self.endField.enabled = NO;
    self.swapFieldsButton.enabled = NO;
    [self.view endEditing:YES];
}

- (void)unlockViewController
{
    self.navigationItem.title = kNavigationTitle;
    self.startField.enabled = YES;
    self.endField.enabled = YES;
    self.swapFieldsButton.enabled = YES;
    [self.endField becomeFirstResponder];

    if (([self.startField.text length] > 0) && ([self.endField.text length] > 0)) {
        self.routeButton.enabled = YES;
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
            [self route];
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
        if (self.routeButton.enabled) {
            self.routeButton.enabled = NO;
        }
    } else if (currentLength == 0) {
        BOOL fieldsComplete = ((textField == self.startField) && ([self.endField.text length] > 0))
                             || ((textField == self.endField) && ([self.startField.text length] > 0));
        
        if (fieldsComplete) {
            self.routeButton.enabled = YES;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.routeButton.enabled) {
        self.routeButton.enabled = NO;
    }
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *mostRecentLocation = [locations lastObject];
    
    // test that this isn't cached data
    NSTimeInterval locationAge = -[[mostRecentLocation timestamp] timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    // test that the horizontal accuracy does not indicate and invalid measurment
    if (mostRecentLocation.horizontalAccuracy < 0) {
        return;
    }
    
    self.currentLocation = mostRecentLocation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
