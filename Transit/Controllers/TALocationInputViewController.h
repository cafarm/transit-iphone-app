//
//  TALocationInputViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TALocationManager.h"

@class OTPObjectManager;
@class TALocationField;
@class TAMapViewController;

@interface TALocationInputViewController : UIViewController <UITextFieldDelegate, TALocationManagerDelegate, UIAlertViewDelegate>

- (id)initWithObjectManager:(OTPObjectManager *)objectManager;

@property (strong, nonatomic) OTPObjectManager *objectManager;

@property (weak, nonatomic) UIBarButtonItem *clearButton;
@property (weak, nonatomic) UIBarButtonItem *routeButton;

@property (weak, nonatomic) IBOutlet TALocationField *startField;
@property (weak, nonatomic) IBOutlet TALocationField *endField;
@property (weak, nonatomic) IBOutlet UIButton *swapFieldsButton;
@property (weak, nonatomic) IBOutlet UITableView *suggestedLocationsTable;

@property (strong, nonatomic) TALocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

- (void)clearFields;
- (IBAction)swapFields;

- (void)routeTrip;

@end
