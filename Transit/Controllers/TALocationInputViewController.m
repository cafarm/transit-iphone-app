//
//  TALocationInputViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TALocationInputViewController.h"
#import "TALocationField.h"
#import "TACompletionsController.h"
#import "TAAttributionCompletion.h"
#import "TALocationManager.h"
#import "TATripPlanNavigator.h"
#import "TAMapViewController.h"
#import "TACurrentLocationCompletion.h"
#import "TATripPlanCompletion.h"
#import "TAPlaceCompletion.h"
#import "TAAttributionCompletion.h"
#import "TAPlacemark.h"
#import "OTPClient.h"
#import "GPClient.h"
#import "CLGeocoder+Transit.h"
#import "UIColor+Transit.h"

static NSString *const kNavigationTitle = @"Transit";

@interface TALocationInputViewController ()

@property (strong, nonatomic) TAPlacemark *startPlacemark;
@property (strong, nonatomic) TAPlacemark *endPlacemark;

- (void)lockAllViews;
- (void)unlockAllViews;

@end


@implementation TALocationInputViewController

@synthesize otpObjectManager = _otpObjectManager;
@synthesize gpObjectManager = _gpObjectManager;
@synthesize locationManager = _locationManager;

@synthesize clearButton = _clearButton;
@synthesize routeButton = _routeButton;

@synthesize startField = _startField;
@synthesize endField = _endField;
@synthesize swapFieldsButton = _swapFieldsButton;
@synthesize fieldContainerView = _fieldContainerView;
@synthesize completionsTable = _completionsTable;

@synthesize firstResponderField = _firstResponderField;

@synthesize currentLocationCompletionCell = _currentLocationCompletionCell;
@synthesize tripPlanCompletionCell = _tripPlanCompletionCell;
@synthesize placeCompletionCell = _placeCompletionCell;
@synthesize attributionCompletionCell = _attributionCompletionCell;

@synthesize completionsController = _completionsController;

@synthesize geocoder = _geocoder;

@synthesize startPlacemark = _startPlacemark;
@synthesize endPlacemark = _endPlacemark;

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager
               gpObjectManager:(GPObjectManager *)gpObjectManager
               locationManager:(TALocationManager *)locationManager
{
    self = [super initWithNibName:@"TALocationInputViewController" bundle:nil];
    if (self) {        
        _otpObjectManager = otpObjectManager;
        _gpObjectManager = gpObjectManager;
        _locationManager = locationManager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide nav bar shadow
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    self.navigationItem.title = kNavigationTitle;
    
    self.fieldContainerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LocationInputBackground"]];
    
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
    self.routeButton = routeButton;
    
    self.startField.leftViewLabel.text = @"Start:  ";
    self.startField.delegate = self;
    
    self.endField.leftViewLabel.text = @"End:  ";
    self.endField.delegate = self;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 5, 15, 5);
    [self.swapFieldsButton setBackgroundImage:[[UIImage imageNamed:@"BlueButton"] resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    [self.swapFieldsButton setBackgroundImage:[[UIImage imageNamed:@"BlueButton"] resizableImageWithCapInsets:insets] forState:UIControlStateDisabled];
    [self.swapFieldsButton setBackgroundImage:[[UIImage imageNamed:@"BlueButtonPressed"] resizableImageWithCapInsets:insets] forState:UIControlStateHighlighted];
    [self.swapFieldsButton setImage:[UIImage imageNamed:@"Swap"] forState:UIControlStateNormal];
    self.swapFieldsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 0);
    
    // If we have authorization to current location, set the start field to current location
    if ([TALocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
        || [TALocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        
        self.startField.contentType = TALocationFieldContentTypeCurrentLocation;
        [self.endField becomeFirstResponder];
    } else {
        [self.startField becomeFirstResponder];
    }
    
    self.completionsTable.delegate = self;
    self.completionsTable.dataSource = self;
    
    self.completionsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self toggleButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // It takes a few seconds to find the current location, so we'll prepare it in the background in anticipation
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    [self fetchCompletionsWithField:self.firstResponderField];
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

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect tableFrame = self.completionsTable.frame;
    self.completionsTable.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height - keyboardSize.height);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect tableFrame = self.completionsTable.frame;
    self.completionsTable.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height + keyboardSize.height);
}

- (TACompletionsController *)completionsController
{
    if (_completionsController == nil) {
        _completionsController = [[TACompletionsController alloc] initWithInput:[self firstResponderField].text
                                                                gpObjectManager:self.gpObjectManager
                                                                locationManager:self.locationManager];
    }
    return _completionsController;
}

- (void)fetchCompletionsWithField:(TALocationField *)field
{
    field.contentType != TALocationFieldContentTypeCurrentLocation ? [self fetchCompletionsWithInput:field.text] : [self fetchCompletionsWithInput:@""];
}

- (void)fetchCompletionsWithInput:(NSString *)input
{
    // Trim leading whitespace
    NSRange leadingSpaceRange = [input rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    input = [input stringByReplacingCharactersInRange:leadingSpaceRange withString:@""];
    
    self.completionsController.input = input;
    
    BOOL isSubstringOfCurrentLocation;
    if (![input isEqualToString:@""]) {
        NSRange range = [TALocationFieldCurrentLocationText rangeOfString:input options:NSAnchoredSearch | NSCaseInsensitiveSearch];
        isSubstringOfCurrentLocation = range.location != NSNotFound;
    } else {
        isSubstringOfCurrentLocation = YES;
    }
    
    BOOL shouldIncludeCurrentLocation = isSubstringOfCurrentLocation
                                         && self.startField.contentType != TALocationFieldContentTypeCurrentLocation
                                         && self.endField.contentType != TALocationFieldContentTypeCurrentLocation
                                         && [TALocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
    
    [self.completionsController fetchCompletionsIncludingCurrentLocation:shouldIncludeCurrentLocation];
}

- (CLGeocoder *)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)clearFields
{
    self.startField.contentType = TALocationFieldContentTypeDefault;
    self.startField.text = nil;
    
    self.endField.contentType = TALocationFieldContentTypeDefault;
    self.endField.text = nil;
    
    [self.startField becomeFirstResponder];
    
    [self toggleButtons];
    
    [self fetchCompletionsWithField:[self firstResponderField]];
}

- (IBAction)swapFields
{
    NSString *tempString = self.startField.text;
    TALocationFieldContentType tempType = self.startField.contentType;
    id tempReference = self.startField.contentReference;
    
    self.startField.text = self.endField.text;
    self.startField.contentType = self.endField.contentType;
    self.startField.contentReference = self.endField.contentReference;
    
    self.endField.text = tempString;
    self.endField.contentType = tempType;
    self.endField.contentReference = tempReference;
    
    if (self.firstResponderField == self.endField) {
        [self toggleEndFieldReturnKey];
    }
}

- (void)routeTrip
{
    // Make sure user didn't swap fields to enable the route button
    if (!self.startField.isComplete) {
        [self.startField becomeFirstResponder];
        return;
    }
    
    if (!self.endField.isComplete) {
        [self.endField becomeFirstResponder];
        return;
    }
    
    // The Apple geocoder is so bad, if we have a Google completion available use it even if the user didn't select it
    // TODO: We should really geocode both fields with Google at this point
    if (self.firstResponderField.contentType == TALocationFieldContentTypeDefault) {
        TAPlaceCompletion *placeCompletion = [self.completionsController.fetchedPlaceCompletions objectAtIndex:0];
        if (placeCompletion != nil) {
            self.firstResponderField.contentType = TALocationFieldContentTypeGooglePlace;
            self.firstResponderField.contentReference = placeCompletion.reference;
        }
    }
    
    [self lockAllViews];
    
    // TODO: Verify the current location has been found
    
    [self.geocoder geocodeField:self.startField
                       inRegion:self.locationManager.currentRegion
                gpObjectManager:self.gpObjectManager
              completionHandler:^(TAPlacemark *placemark, NSError *error)
    {
        if (error) {
            [self showAlertViewWithError:error];
            return;
        }
        self.startPlacemark = placemark;
        
        [self.geocoder geocodeField:self.endField
                           inRegion:self.locationManager.currentRegion
                    gpObjectManager:self.gpObjectManager
                  completionHandler:^(TAPlacemark *placemark, NSError *error)
        {
            if (error) {
                [self showAlertViewWithError:error];
                return;
            }
            self.endPlacemark = placemark;
            [self pushMapViewController];
        }];
    }];
}

- (void)pushMapViewController
{
    CLLocationCoordinate2D startCoordinate = self.startPlacemark.isCurrentLocation ? self.locationManager.currentLocation.coordinate : self.startPlacemark.location.coordinate;
    CLLocationCoordinate2D endCoordinate = self.endPlacemark.isCurrentLocation ? self.locationManager.currentLocation.coordinate : self.endPlacemark.location.coordinate;
    
    self.otpObjectManager.from = startCoordinate;
    self.otpObjectManager.to = endCoordinate;
    
    [self.otpObjectManager fetchTripPlanWithCompletionHandler:^(OTPTripPlan *tripPlan, NSError *error)
    {
        if (error) {
            [self showAlertViewWithError:error];
            return;
        }
        
        // Add this trip to the completions so the user can come back to it at a later date
        TATripPlanCompletion *completion = [[TATripPlanCompletion alloc] initWithFrom:self.startPlacemark to:self.endPlacemark];
        [self.completionsController addTripPlanCompletion:completion];
        
        TATripPlanNavigator *tripPlanNavigator = [[TATripPlanNavigator alloc] initWithTripPlan:tripPlan];
        
        TAMapViewController *mapController = [[TAMapViewController alloc] initWithObjectManager:self.otpObjectManager
                                                                                locationManager:self.locationManager
                                                                              tripPlanNavigator:tripPlanNavigator];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:nil
                                                                                action:nil];
        [self.navigationController pushViewController:mapController animated:YES];
    }];
}

- (void)showAlertViewWithError:(NSError *)error
{
    NSString *message;
    if (error.domain == kCLErrorDomain) {
        message = @"Directions could not be found between these locations.";
    } else {
        message = error.localizedDescription;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Directions Not Available"
                                                        message:message
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
    self.startField.enabled = NO;
    self.endField.enabled = NO;
    self.swapFieldsButton.enabled = NO;
    self.completionsTable.allowsSelection = NO;
    self.navigationItem.title = @"Loading...";
    [self.view endEditing:YES];
}

- (void)unlockAllViews
{
    [self toggleButtons];
    self.startField.enabled = YES;
    self.endField.enabled = YES;
    self.swapFieldsButton.enabled = YES;
    self.completionsTable.allowsSelection = YES;
    self.navigationItem.title = kNavigationTitle;
    [self.endField becomeFirstResponder];
}

- (void)toggleButtons
{
    if (self.startField.isComplete && self.endField.isComplete)  {
        self.routeButton.enabled = YES;
    } else {
        self.routeButton.enabled = NO;
    }
    
    if (self.startField.isComplete || self.endField.isComplete) {
        self.swapFieldsButton.enabled = YES;
        self.clearButton.enabled = YES;
    } else {
        self.swapFieldsButton.enabled = NO;
        self.clearButton.enabled = NO;
    }
}

- (void)toggleEndFieldReturnKey
{
    if (self.startField.isComplete) {
        self.endField.returnKeyType = UIReturnKeyRoute;
    } else {
        self.endField.returnKeyType = UIReturnKeyNext;
    }
}

- (void)locationFieldDidBeginEditing:(TALocationField *)locationField
{    
    if (locationField == self.endField) {
        [self toggleEndFieldReturnKey];
    }
    
    [self fetchCompletionsWithField:self.firstResponderField];
}

- (BOOL)locationFieldShouldReturn:(TALocationField *)locationField
{
    if (locationField == self.startField) {
        [self.endField becomeFirstResponder];
    } else {
        if (locationField.returnKeyType == UIReturnKeyNext) {
            [self.startField becomeFirstResponder];
        } else {
            [self routeTrip];
        }
    }
    
    return NO;
}

- (BOOL)locationField:(TALocationField *)locationField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    // We have to do a lot of work here because we don't know when the field "did" clear!
    int currentLength = [locationField.text length];
    int newLength = currentLength - range.length + [string length];
    
    if (newLength == 0) {
        if ([self locationFieldsWillBeEmpty]) {
            self.clearButton.enabled = NO;
            self.swapFieldsButton.enabled = NO;
        }
        self.routeButton.enabled = NO;
        
    } else if (currentLength == 0) {
        if ([self locationFieldsWillBeComplete]) {
            self.routeButton.enabled = YES;
        }
        self.clearButton.enabled = YES;
        self.swapFieldsButton.enabled = YES;
    }
    
    NSString *input = [locationField.text stringByReplacingCharactersInRange:range withString:string];
    [self fetchCompletionsWithInput:input];
    
    return YES;
}

- (BOOL)locationFieldShouldClear:(TALocationField *)locationField
{
    // Again, a bunch of work because we don't know when the field "did" clear!
    if ([self locationFieldsWillBeEmpty]) {
        self.clearButton.enabled = NO;
        self.swapFieldsButton.enabled = NO;
    }
    self.routeButton.enabled = NO;
        
    // If the current location field is being cleared we have to force the fetch because we haven't cleared it yet
    if (locationField.contentType == TALocationFieldContentTypeCurrentLocation) {
        [self.completionsController fetchCompletionsIncludingCurrentLocation:YES];
    } else {
        [self fetchCompletionsWithInput:@""];
    }
    
    return YES;
}

- (BOOL)locationFieldsWillBeEmpty
{
    return (([self firstResponderField] == self.startField) && !self.endField.isComplete)
            || (([self firstResponderField] == self.endField) && !self.startField.isComplete);
}

- (BOOL)locationFieldsWillBeComplete
{
    return (([self firstResponderField] == self.startField) && self.endField.isComplete)
            || (([self firstResponderField] == self.endField) && self.startField.isComplete);
}

- (TALocationField *)firstResponderField
{
    return self.startField.isFirstResponder ? self.startField : self.endField;
}

- (void)locationManager:(TALocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusAuthorized) {
        if (self.startField.contentType == TALocationFieldContentTypeCurrentLocation) {
            self.startField.text = nil;
            self.startField.contentType = TALocationFieldContentTypeDefault;
            [self.startField becomeFirstResponder];
        }
        
        if (self.endField.contentType == TALocationFieldContentTypeCurrentLocation) {
            self.startField.text = nil;
            self.endField.contentType = TALocationFieldContentTypeDefault;
        }
        
        [self toggleButtons];
        [self.completionsTable reloadData];
    }
}

- (void)controllerDidChangeContent:(TACompletionsController *)controller
{
    [self.completionsTable reloadData];
    
    // Set the table view to the top
    [self.completionsTable setContentOffset:CGPointZero animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.completionsController numberOfRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TACompletion *completion = [self.completionsController completionAtIndexPath:indexPath.row];
    
    if (![completion isKindOfClass:[TAAttributionCompletion class]]) {
        return 44;
    } else {
        return 34;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TACompletion *completion = [self.completionsController completionAtIndexPath:indexPath.row];
    
    UITableViewCell *cell = nil;
    
    if ([completion isKindOfClass:[TACurrentLocationCompletion class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"currentLocationCompletionCellID"];
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"TACurrentLocationCompletionTableViewCell" owner:self options:nil];
            cell = self.currentLocationCompletionCell;
            self.currentLocationCompletionCell = nil;
        }
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = TALocationFieldCurrentLocationText;
        label.textColor = [UIColor currentLocationColor];

    } else if ([completion isKindOfClass:[TATripPlanCompletion class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tripPlanCompletionCellID"];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"TATripPlanCompletionTableViewCell" owner:self options:nil];
            cell = self.tripPlanCompletionCell;
            self.tripPlanCompletionCell = nil;
        }
        TATripPlanCompletion *tripPlanCompletion = (TATripPlanCompletion *)completion;
        
        // From name label
        [self formatTripPlanNameLabel:(UILabel *)[cell viewWithTag:1] withPlacemark:tripPlanCompletion.from];
        // From locality label
        [self formatTripPlanLocalityLabel:(UILabel *)[cell viewWithTag:2] withNameLabel:(UILabel *)[cell viewWithTag:1] Placemark:tripPlanCompletion.from];
        // To name label
        [self formatTripPlanNameLabel:(UILabel *)[cell viewWithTag:3] withPlacemark:tripPlanCompletion.to];
        // To locality label
        [self formatTripPlanLocalityLabel:(UILabel *)[cell viewWithTag:4] withNameLabel:(UILabel *)[cell viewWithTag:3] Placemark:tripPlanCompletion.to];
        
    } else if ([completion isKindOfClass:[TAPlaceCompletion class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"placeCompletionCellID"];
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"TAPlaceCompletionTableViewCell" owner:self options:nil];
            cell = self.placeCompletionCell;
            self.placeCompletionCell = nil;
        }
        TAPlaceCompletion *placeCompletion = (TAPlaceCompletion *)completion;
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        nameLabel.text = placeCompletion.mainTerm;
        
        UILabel *detailsLabel = (UILabel *)[cell viewWithTag:2];
        detailsLabel.text = placeCompletion.subTerms;
        
    } else if ([completion isKindOfClass:[TAAttributionCompletion class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"attributionCompletionCellID"];
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"TAAttributionCompletionTableViewCell" owner:self options:nil];
            cell = self.attributionCompletionCell;
            self.attributionCompletionCell = nil;
        }
        // No extra setup necessary
    }
    
    //cell.contentView.backgroundColor = [UIColor lightBackgroundColor];
	return cell;
}

- (void)formatTripPlanNameLabel:(UILabel *)label withPlacemark:(TAPlacemark *)placemark
{
    // Size the label to fit the text
    CGSize constrainedSize = CGSizeMake(300 - label.frame.origin.x, label.frame.size.height);
    CGSize textSize = [placemark.name sizeWithFont:label.font constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, textSize.width, label.frame.size.height);
    label.text = placemark.name;
    
    if (placemark.isCurrentLocation) {
        label.textColor = [UIColor currentLocationColor];
    } else {
        label.textColor = [UIColor blackColor];
    }
}

- (void)formatTripPlanLocalityLabel:(UILabel *)label withNameLabel:(UILabel *)nameLabel Placemark:(TAPlacemark *)placemark
{
    // Only add locality to establishments
    if ([placemark.types containsObject:[NSNumber numberWithInt:GPDetailsResultTypeEstablishment]]) {
        CGFloat labelX = nameLabel.frame.origin.x + nameLabel.frame.size.width + 5;
        CGFloat remainingSpace = 300 - labelX;
        
        if (remainingSpace > 0) {
            label.frame = CGRectMake(labelX, label.frame.origin.y, remainingSpace, label.frame.size.height);
            label.text = [NSString stringWithFormat:@"(%@)", placemark.locality];
        } else {
            label.text = nil;
        }
        
    } else {
        label.text = nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TACompletion *completion = [self.completionsController completionAtIndexPath:indexPath.row];
    
    // We don't have to do any geocoding with stored trip completions, just load the from and to and push the map
    if ([completion isKindOfClass:[TATripPlanCompletion class]]) {
        self.startPlacemark = ((TATripPlanCompletion *)completion).from;
        self.endPlacemark = ((TATripPlanCompletion *)completion).to;
        [self pushMapViewController];
        return;
    }

    if ([completion isKindOfClass:[TACurrentLocationCompletion class]]) {
        [self firstResponderField].contentType = TALocationFieldContentTypeCurrentLocation;
        
    } else if ([completion isKindOfClass:[TAPlaceCompletion class]]) {
        self.firstResponderField.contentType = TALocationFieldContentTypeGooglePlace;
        
        TAPlaceCompletion *placeCompletion = (TAPlaceCompletion *)completion;
        self.firstResponderField.text = [NSString stringWithFormat:@"%@, %@", placeCompletion.mainTerm, placeCompletion.subTerms];
        self.firstResponderField.contentReference = placeCompletion.reference;
    }
    
    if (self.firstResponderField == self.endField && [self locationFieldsWillBeComplete]) {
        [self routeTrip];
    } else {
        [self toggleButtons];
        if (self.firstResponderField == self.startField) {
            [self.endField becomeFirstResponder];
        } else {
            [self.startField becomeFirstResponder];
        }
    }
}

@end
