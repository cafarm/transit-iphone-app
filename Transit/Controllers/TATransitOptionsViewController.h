//
//  TATransitOptionsViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/11/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TADatePickerViewController.h"

@class OTPObjectManager;
@class TATripPlanNavigator;

@protocol TATransitOptionsViewControllerDelegate;

@interface TATransitOptionsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, TADatePickerViewControllerDelegate, UIAlertViewDelegate>

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager tripPlanNavigator:(TATripPlanNavigator *)tripPlanNavigator;

@property (weak, nonatomic) id<TATransitOptionsViewControllerDelegate> delegate;

@property (readonly, nonatomic) OTPObjectManager *otpObjectManager;
@property (readonly, nonatomic) TATripPlanNavigator *tripPlanNavigator;

@property (weak, nonatomic) UIBarButtonItem *doneButtonItem;

- (void)doneSettingOptions;

@end


@protocol TATransitOptionsViewControllerDelegate <NSObject>

@optional

- (void)transitOptionsViewControllerDidSetNewOptions:(TATransitOptionsViewController *)controller;

@end