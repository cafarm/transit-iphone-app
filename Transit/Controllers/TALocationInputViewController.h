//
//  TALocationInputViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TALocationManager.h"
#import "TALocationCompletionsController.h"

@class OTPObjectManager;
@class GPObjectManager;
@class TALocationCompletionsController;
@class TALocationField;
@class TAMapViewController;

@interface TALocationInputViewController : UIViewController <TALocationCompletionsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

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

@property (strong, nonatomic) TALocationCompletionsController *completionsController;

@property (strong, nonatomic) CLGeocoder *geocoder;

- (void)clearFields;
- (IBAction)swapFields;

- (void)routeTrip;

@end
