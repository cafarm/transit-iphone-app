//
//  TADatePickerViewController.m
//  Transit
//
//  Created by Mark Cafaro on 9/15/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TADatePickerViewController.h"
#import "NSDateFormatter+Transit.h"
#import "OTPClient.h"

enum {
    TASectionDepartAtOrArriveBy,
    TASectionDateDisplay,
    TASectionResetButton
};

enum {
    TASegmentDepartAt,
    TASegmentArriveBy
};

@interface TADatePickerViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation TADatePickerViewController

@synthesize otpObjectManager = _otpObjectManager;

@synthesize delegate = _delegate;

@synthesize departAtOrArriveByControl = _departAtOrArriveByControl;
@synthesize resetDateButton = _resetDateButton;
@synthesize datePicker = _datePicker;

@synthesize dateFormatter = _dateFormatter;

- (id)initWithOTPObjectManager:(OTPObjectManager *)otpObjectManager
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _otpObjectManager = otpObjectManager;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.allowsSelection = NO;
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPickingDate)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.cancelButtonItem = cancelButtonItem;
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePickingDate)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    self.doneButtonItem = doneButtonItem;
    
    self.departAtOrArriveByControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Depart At", @"Arrive By", nil]];
    self.departAtOrArriveByControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.departAtOrArriveByControl addTarget:self action:@selector(changedDepartAtOrArriveBy) forControlEvents:UIControlEventValueChanged];
    
    self.resetDateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.resetDateButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.resetDateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.resetDateButton setTitleColor:[UIColor colorWithRed:143/255.0 green:178/255.0 blue:220/255.0 alpha:1] forState:UIControlStateDisabled];
    self.resetDateButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.resetDateButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateNormal];
    self.resetDateButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [self.resetDateButton setBackgroundImage:[[UIImage imageNamed:@"LargeBlueButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateNormal];
    [self.resetDateButton setBackgroundImage:[[UIImage imageNamed:@"LargeBlueButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateDisabled];
    [self.resetDateButton addTarget:self action:@selector(resetDate) forControlEvents:UIControlEventTouchUpInside];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    CGSize pickerSize = datePicker.frame.size;
    datePicker.frame = CGRectMake(0, self.view.frame.size.height - pickerSize.height, pickerSize.width, pickerSize.height);
    datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    datePicker.date = self.otpObjectManager.date;
    [datePicker addTarget:self action:@selector(changedDate) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    self.datePicker = datePicker;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.departAtOrArriveByControl.selectedSegmentIndex = self.otpObjectManager.shouldArriveBy;
    [self changedDepartAtOrArriveBy];
}

- (void)resetDate
{
    if (self.departAtOrArriveByControl.selectedSegmentIndex == TASegmentDepartAt) {
        self.datePicker.date = [NSDate date];
    } else {
        self.datePicker.date = [NSDate dateWithTimeIntervalSinceNow:45 * 60];
    }
    
    [self changedDate];
}

- (void)toggleResetDateButton
{
    NSDate *date;
    if (self.departAtOrArriveByControl.selectedSegmentIndex == TASegmentDepartAt) {
        [self.resetDateButton setTitle:@"Now" forState:UIControlStateNormal];
        date = [NSDate date];
    } else {
        [self.resetDateButton setTitle:@"In 45 Minutes" forState:UIControlStateNormal];
        date = [NSDate dateWithTimeIntervalSinceNow:45 * 60];
    }
    
    if (abs([self.datePicker.date timeIntervalSinceDate:date]) < 60) {
        self.resetDateButton.enabled = NO;
    } else {
        self.resetDateButton.enabled = YES;
    }
}

- (void)changedDate
{    
    NSIndexPath *dateCellIndex = [NSIndexPath indexPathForItem:0 inSection:TASectionDateDisplay];
    UITableViewCell *dateCell = [self.tableView cellForRowAtIndexPath:dateCellIndex];
    dateCell.textLabel.text = [self.dateFormatter stringFromTravelDate:self.datePicker.date];
    
    [self toggleResetDateButton];
}

- (void)changedDepartAtOrArriveBy
{
    [self toggleTitle];
    [self toggleResetDateButton];
}

- (void)toggleTitle
{
    if (self.departAtOrArriveByControl.selectedSegmentIndex == TASegmentDepartAt) {
        self.navigationItem.title = @"Departure Time";
    } else {
        self.navigationItem.title = @"Arrival Time";
    }
}

- (void)cancelPickingDate
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)donePickingDate
{
    BOOL didChange = false;
    
    if (self.otpObjectManager.shouldArriveBy != self.departAtOrArriveByControl.selectedSegmentIndex) {
        self.otpObjectManager.shouldArriveBy = self.departAtOrArriveByControl.selectedSegmentIndex;
        didChange = true;
    }

    if (abs([self.otpObjectManager.date timeIntervalSinceDate:self.datePicker.date]) > 60) {
        self.otpObjectManager.date = self.datePicker.date;
        didChange = true;
    }
    
    if (didChange && [self.delegate respondsToSelector:@selector(datePickerViewControllerDidPickNewDate:)]) {
        [self.delegate datePickerViewControllerDidPickNewDate:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    } else {
        // Reset cell
        cell.textLabel.text = nil;
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
        cell.backgroundView = nil;
    }
    
    switch (indexPath.section) {
        case TASectionDepartAtOrArriveBy: {
            self.departAtOrArriveByControl.frame = cell.bounds;
            [cell.contentView addSubview:self.departAtOrArriveByControl];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            break;
        }
        case TASectionDateDisplay: {
            cell.textLabel.text = [self.dateFormatter stringFromTravelDate:self.datePicker.date];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            break;
        }
        case TASectionResetButton: {
            self.resetDateButton.frame = cell.bounds;
            [cell.contentView addSubview:self.resetDateButton];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            break;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    switch (indexPath.section) {
        case TASectionDepartAtOrArriveBy:
        case TASectionResetButton: {
            height = 45;
            break;
        }
        default: {
            height = 44;
            break;
        }
    }
    return height;
}

@end
