//
//  TALocationInputViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationInputViewController.h"
#import "TAMapViewController.h"

@interface TALocationInputViewController ()
{
    NSString *_navigationTitle;
    UIBarButtonItem *_routeButton;
    IBOutlet UITextField *_startField;
    IBOutlet UITextField *_endField;
    IBOutlet UIButton *_swapFieldsButton;
    IBOutlet UITableView *_suggestedLocationsTable;
}

- (void)setLabelText:(NSString *)labelText forTextField:(UITextField *)textField;
- (void)lockViewController;
- (void)unlockViewController;

@end

@implementation TALocationInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _navigationTitle = @"Transit";
        [self.navigationItem setTitle:_navigationTitle];
        
        _routeButton = [[UIBarButtonItem alloc] initWithTitle:@"Route"
                                                        style:UIBarButtonItemStyleDone
                                                       target:self
                                                       action:@selector(routeMapOverview)];
        [_routeButton setEnabled:NO];
        [self.navigationItem setRightBarButtonItem:_routeButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setLabelText:@"Start:  " forTextField:_startField];
    [_startField setDelegate:self];
    
    [self setLabelText:@"End:  " forTextField:_endField];
    [_endField setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self unlockViewController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing: YES];
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

- (IBAction)swapStartAndEndFields
{
    NSString *start = _startField.text;
    _startField.text = _endField.text;
    _endField.text = start;
}

- (void)routeMapOverview
{
    // make sure user didn't swap fields to somehow enable the route button
    if ([_startField.text length] == 0) {
        [_startField becomeFirstResponder];
        return;
    }
    
    if ([_endField.text length] == 0) {
        [_endField becomeFirstResponder];
        return;
    }
    
    [self lockViewController];
}

- (void)lockViewController
{
    self.navigationItem.title = @"Loading...";
    _routeButton.enabled = NO;
    _startField.enabled = NO;
    _endField.enabled = NO;
    _swapFieldsButton.enabled = NO;
    [self.view endEditing: YES];
}

- (void)unlockViewController
{
    self.navigationItem.title = _navigationTitle;
    _routeButton.enabled = YES;
    _startField.enabled = YES;
    _endField.enabled = YES;
    _swapFieldsButton.enabled = YES;
    [_endField becomeFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _endField) {
        if ([_startField.text length] > 0) {
            _endField.returnKeyType = UIReturnKeyRoute;
            _endField.enablesReturnKeyAutomatically = YES;
        } else{
            _endField.returnKeyType = UIReturnKeyNext;
            _endField.enablesReturnKeyAutomatically = NO;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _startField) {
        [_endField becomeFirstResponder];
    } else {
        if (textField.returnKeyType == UIReturnKeyNext) {
            [_startField becomeFirstResponder];
        } else {
            [self routeMapOverview];
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
        if (_routeButton.enabled) {
            _routeButton.enabled = NO;
        }
    } else if (currentLength == 0) {
        BOOL inputComplete = ((textField == _startField) && ([_endField.text length] > 0))
                             || ((textField == _endField) && ([_startField.text length] > 0));
        
        if (inputComplete) {
            _routeButton.enabled = YES;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (_routeButton.enabled) {
        _routeButton.enabled = NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
