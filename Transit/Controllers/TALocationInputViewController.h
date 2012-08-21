//
//  TALocationInputViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TALocationManager.h"
#import "TACompletionsController.h"
#import "TALocationField.h"

@class OTPObjectManager;
@class GPObjectManager;
@class TACompletionsController;
@class TAMapViewController;

@interface TALocationInputViewController : UIViewController <TACompletionsControllerDelegate, UITableViewDataSource,
                                                             UITableViewDelegate, TALocationFieldDelegate,
                                                             UIAlertViewDelegate, TALocationManagerDelegate>

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager
               gpObjectManager:(GPObjectManager *)gpObjectManager
               locationManager:(TALocationManager *)locationManager;

@property (readonly, nonatomic) OTPObjectManager *otpObjectManager;
@property (readonly, nonatomic) GPObjectManager *gpObjectManager;
@property (readonly, nonatomic) TALocationManager *locationManager;

@property (weak, nonatomic) UIBarButtonItem *clearButton;
@property (weak, nonatomic) UIBarButtonItem *routeButton;

@property (weak, nonatomic) IBOutlet TALocationField *startField;
@property (weak, nonatomic) IBOutlet TALocationField *endField;
@property (weak, nonatomic) IBOutlet UIButton *swapFieldsButton;
@property (weak, nonatomic) IBOutlet UITableView *completionsTable;

@property (readonly, nonatomic) TALocationField *firstResponderField;

@property (weak, nonatomic) IBOutlet UITableViewCell *currentLocationCompletionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *tripPlanCompletionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *placeCompletionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *attributionCompletionCell;

@property (strong, nonatomic) TACompletionsController *completionsController;

@property (strong, nonatomic) CLGeocoder *geocoder;

- (void)clearFields;
- (IBAction)swapFields;

- (void)routeTrip;

@end
