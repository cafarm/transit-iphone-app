//
//  TALocationInputViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationInputViewController.h"

@interface TALocationInputViewController ()

- (void)setLabelText:(NSString *)labelText forTextField:(UITextField *)textField;

@end

@implementation TALocationInputViewController

@synthesize startField;
@synthesize endField;

@synthesize routeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navigationItem = [self navigationItem];
        [navigationItem setTitle:@"Directions"];
        
        [self setRouteButton:[[UIBarButtonItem alloc] initWithTitle:@"Route" style:UIBarButtonItemStyleDone target:self action:@selector(route)]];
        [routeButton setEnabled:NO];
        [navigationItem setRightBarButtonItem:routeButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setLabelText:@"Start:  " forTextField:startField];
    [startField setDelegate:self];
    
    [self setLabelText:@"End:  " forTextField:endField];
    [endField setDelegate:self];
    
    // hack to suppress keyboard slide animation
    [UIWindow beginAnimations: nil context: NULL];
    [UIWindow setAnimationsEnabled: NO];
    
    [endField becomeFirstResponder];
    
    [UIWindow commitAnimations];
}

- (void)setLabelText:(NSString *)labelText forTextField:(UITextField *)textField
{
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, 45, 31)];
    [label setFont:[textField font]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor grayColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:labelText];

    // a view to shift the label up to align with text field input
    UIView *view = [[UIView alloc] init];
    [view setFrame:[label frame]];
    [view setBackgroundColor:[UIColor clearColor]];
    [view addSubview:label];
    
    [textField setLeftView:view];
}

- (IBAction)swapFields:(id)sender
{
    NSString *start = [startField text];
    [startField setText:[endField text]];
    [endField setText:start];
}

- (void)route
{
    // make sure user didn't swap fields to enable the route button without a start
    if ([[startField text] length] == 0) {
        [startField becomeFirstResponder];
        return;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == endField) {
        if ([[startField text] length] > 0) {
            [endField setReturnKeyType:UIReturnKeyRoute];
            [endField setEnablesReturnKeyAutomatically:YES];
        } else{
            [endField setReturnKeyType:UIReturnKeyNext];
            [endField setEnablesReturnKeyAutomatically:NO];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == startField) {
        [endField becomeFirstResponder];
    } else {
        if ([textField returnKeyType] == UIReturnKeyNext) {
            [startField becomeFirstResponder];
        } else {
            [self route];
        }
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int currentLength = [[textField text] length];
    int newLength = currentLength - range.length + [string length];
    
    if (newLength == 0) {
        if ([routeButton isEnabled]) {
            [routeButton setEnabled:NO];
        }
    } else if (currentLength == 0) {
        BOOL inputComplete = ((textField == startField) && ([[endField text] length] > 0)) || ((textField == endField) && ([[startField text] length] > 0));
        if (inputComplete) {
            [routeButton setEnabled:YES];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([routeButton isEnabled]) {
        [routeButton setEnabled:NO];
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
