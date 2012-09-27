//
//  TATransitOptionsViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/11/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATransitOptionsViewController.h"
#import "TATripPlanNavigator.h"
#import "TADatePickerViewController.h"
#import "NSDateFormatter+Transit.h"
#import "OTPClient.h"
#import "UIColor+Transit.h"

enum {
    TASectionOptimize,
    TASectionDate,
    TASectionItineraries
};

@interface TATransitOptionsViewController ()

@property (nonatomic) BOOL isFetchingNewTripPlan;
@property (nonatomic) BOOL didSetNewOptions;

@property (nonatomic) NSUInteger selectedItineraryIndex;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation TATransitOptionsViewController

@synthesize otpObjectManager = _otpObjectManager;
@synthesize tripPlanNavigator = _tripPlanNavigator;

@synthesize delegate = _delegate;

@synthesize doneButtonItem = _doneButtonItem;

@synthesize isFetchingNewTripPlan = _isFetchingNewTripPlan;
@synthesize didSetNewOptions = _didSetNewOptions;

@synthesize selectedItineraryIndex = _selectedItineraryIndex;

@synthesize dateFormatter = _dateFormatter;

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager tripPlanNavigator:(TATripPlanNavigator *)tripPlanNavigator
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _otpObjectManager = otpObjectManager;
        _tripPlanNavigator = tripPlanNavigator;        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navigationItem.title = @"Transit Options";
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneSettingOptions)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    self.doneButtonItem = doneButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.selectedItineraryIndex = self.tripPlanNavigator.currentItineraryIndex;
    self.isFetchingNewTripPlan = NO;
    self.didSetNewOptions = NO;
}

- (void)doneSettingOptions
{
    if (self.selectedItineraryIndex != self.tripPlanNavigator.currentItineraryIndex) {
        [self.tripPlanNavigator moveToItineraryWithIndex:self.selectedItineraryIndex];
        self.didSetNewOptions = true;
    }
    
    if (self.didSetNewOptions && [self.delegate respondsToSelector:@selector(transitOptionsViewControllerDidSetNewOptions:)]) {
        [self.delegate transitOptionsViewControllerDidSetNewOptions:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushDatePickerViewController
{
    TADatePickerViewController *dateController = [[TADatePickerViewController alloc] initWithOTPObjectManager:self.otpObjectManager];
    dateController.delegate = self;
    [self.navigationController pushViewController:dateController animated:YES];
}

- (void)datePickerViewControllerDidPickNewDate:(TADatePickerViewController *)controller
{
    [self.tableView reloadData];
    [self fetchNewTripPlan];
}

- (void)selectCell:(UITableViewCell *)cell
{
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.accessoryView = nil;
    cell.textLabel.textColor = [UIColor selectionColor];
}

- (void)deselectCell:(UITableViewCell *)cell
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.textLabel.textColor = [UIColor blackColor];
}

- (void)fetchNewTripPlan
{
    self.isFetchingNewTripPlan = YES;
    
    NSInteger numItineraries = [self.tripPlanNavigator.itineraries count];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:numItineraries];
    for (int i = 0; i < [self.tripPlanNavigator.itineraries count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:TASectionItineraries]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    UITableViewCell *loadingCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:TASectionItineraries]];
    loadingCell.textLabel.text = @"Loading...";
    [self deselectCell:loadingCell];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    loadingCell.accessoryView = indicatorView;
    
    [self disableAllViews];
    
    [self.otpObjectManager fetchTripPlanWithCompletionHandler:^(OTPTripPlan *tripPlan, NSError *error) {
        self.isFetchingNewTripPlan = NO;
        
        if (error) {
            [self showAlertViewWithError:error];
            return;
        }
        
        self.tripPlanNavigator.tripPlan = tripPlan;
        self.didSetNewOptions = YES;
        self.selectedItineraryIndex = self.tripPlanNavigator.currentItineraryIndex;
        
        loadingCell.textLabel.text = @"Load More Itineraries";
        [self deselectCell:loadingCell];
        
        NSInteger numItineraries = [self.tripPlanNavigator.itineraries count];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:numItineraries];
        for (int i = 0; i < [self.tripPlanNavigator.itineraries count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:TASectionItineraries]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self enableAllViews];
    }];
}

- (void)disableAllViews
{
    self.doneButtonItem.enabled = NO;
    self.tableView.allowsSelection = NO;
}

- (void)enableAllViews
{
    self.doneButtonItem.enabled = YES;
    self.tableView.allowsSelection = YES;
}

- (void)showAlertViewWithError:(NSError *)error
{
    NSString *message;
    message = error.localizedDescription;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Directions Not Available"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self enableAllViews];
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case TASectionOptimize: {
            title = @"Prefer";
            break;
        }
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows;
    switch (section) {
        case TASectionOptimize: {
            numberOfRows = 3;
            break;
        }
        case TASectionDate: {
            numberOfRows = 1;
            break;
        }
        case TASectionItineraries: {
            if (self.isFetchingNewTripPlan) {
                numberOfRows = 1;
            } else {
                numberOfRows = [self.tripPlanNavigator.itineraries count] + 1;
            }
            break;
        }
        default: {
            numberOfRows = 0;
            break;
        }
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    } else {
        // Reset cell
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        [self deselectCell:cell];
    }
    
    switch (indexPath.section) {
        case TASectionOptimize: {
            switch (indexPath.row) {
                case OTPObjectManagerOptimizeBestRoute: {
                    cell.textLabel.text = @"Best Route";
                    break;
                }
                case OTPObjectManagerOptimizeFewerTransfers: {
                    cell.textLabel.text = @"Fewer Transfers";
                    break;
                }
                case OTPObjectManagerOptimizeLessWalking: {
                    cell.textLabel.text = @"Less Walking";
                    break;
                }
            }
            
            if (indexPath.row == self.otpObjectManager.optimize) {
                [self selectCell:cell];
            }
            break;
        }
        case TASectionDate: {
            cell.textLabel.text = self.otpObjectManager.shouldArriveBy ? @"Arrive" : @"Depart";
            cell.detailTextLabel.text = [self.dateFormatter stringFromTravelDate:self.otpObjectManager.date];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case TASectionItineraries: {
            if (indexPath.row >= [self.tripPlanNavigator.itineraries count]) {
                cell.textLabel.text = @"Load More Itineraries";
            } else {
                OTPItinerary *itinerary = [self.tripPlanNavigator.itineraries objectAtIndex:indexPath.row];
                
                self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
                self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
                
                NSInteger durationInMinutes = [itinerary.duration longValue] / 1000 / 60;
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@ (%d mins)",
                                       [self.dateFormatter stringFromDate:itinerary.startTime],
                                       [self.dateFormatter stringFromDate:itinerary.endTime],
                                       durationInMinutes];
                
                if (indexPath.row == self.selectedItineraryIndex) {
                    [self selectCell:cell];
                }
            }
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case TASectionOptimize: {
            if (indexPath.row == self.otpObjectManager.optimize) {
                return;
            }
            
            NSIndexPath *oldCellIndex = [NSIndexPath indexPathForItem:self.otpObjectManager.optimize inSection:TASectionOptimize];
            UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldCellIndex];
            [self deselectCell:oldCell];
            
            UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self selectCell:newCell];
            
            self.otpObjectManager.optimize = indexPath.row;
            [self fetchNewTripPlan];
            break;
        }
        case TASectionDate: {
            [self pushDatePickerViewController];
            break;
        }
        case TASectionItineraries: {
            if (indexPath.row >= [self.tripPlanNavigator.itineraries count]) {
                // TODO: Load more itineraries here
            } else {
                if (indexPath.row == self.selectedItineraryIndex) {
                    return;
                }
                
                NSIndexPath *oldCellIndex = [NSIndexPath indexPathForItem:self.selectedItineraryIndex inSection:TASectionItineraries];
                UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldCellIndex];
                [self deselectCell:oldCell];
                
                UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
                [self selectCell:newCell];
                
                self.selectedItineraryIndex = indexPath.row;
            }
            break;
        }
    }
}

@end
