//
//  TALocationInputViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationInputViewController.h"

@interface TALocationInputViewController ()

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

- (IBAction)swapFields:(id)sender
{
    NSString *start = [startField text];
    [startField setText:[endField text]];
    [endField setText:start];
}

- (void)route
{
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == endField) {
        if (![[startField text] isEqual:@""]) {
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
    int newLength = [[textField text] length] - range.length + [string length];
    if (newLength == 0) {
        [routeButton setEnabled:NO];
    } else if ((![[startField text] isEqual:@""]) && (![[endField text] isEqual:@""])) {
        [routeButton setEnabled:YES];
    }
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [startField setDelegate:self];
    [endField setDelegate:self];
    
    // hack to suppress keyboard slide animation
    [UIWindow beginAnimations: nil context: NULL];
    [UIWindow setAnimationsEnabled: NO];
    
    [endField becomeFirstResponder];
    
    [UIWindow commitAnimations];
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
