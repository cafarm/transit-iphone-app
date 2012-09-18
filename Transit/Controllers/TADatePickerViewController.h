//
//  TADatePickerViewController.h
//  Transit
//
//  Created by Mark Cafaro on 9/15/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTPObjectManager;

@protocol TADatePickerViewControllerDelegate;

@interface TADatePickerViewController : UITableViewController

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager;

@property (readonly, nonatomic) OTPObjectManager *otpObjectManager;

@property (weak, nonatomic) id<TADatePickerViewControllerDelegate> delegate;

@property (weak, nonatomic) UIBarButtonItem *cancelButtonItem;
@property (weak, nonatomic) UIBarButtonItem *doneButtonItem;

@property (strong, nonatomic) UISegmentedControl *departAtOrArriveByControl;
@property (strong, nonatomic) UIButton *resetDateButton;
@property (weak, nonatomic) UIDatePicker *datePicker;

- (void)cancelPickingDate;
- (void)donePickingDate;

@end


@protocol TADatePickerViewControllerDelegate <NSObject>

@optional

- (void)datePickerViewControllerDidPickNewDate:(TADatePickerViewController *)controller;

@end