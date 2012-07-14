//
//  TALocationInputViewController.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationInputViewController.h"
#import "TAMapViewController.h"
#import "TAItineraryStore.h"

@interface TALocationInputViewController ()
{
    NSString *navigationTitle;
    UIBarButtonItem *routeButton;
    IBOutlet UITextField *startField;
    IBOutlet UITextField *endField;
    IBOutlet UIButton *swapFieldsButton;
    IBOutlet UITableView *suggestedLocationsTable;
    
    TAItineraryStore *itineraryStore;
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
        navigationTitle = @"Transit";
        [[self navigationItem] setTitle:navigationTitle];
        
        routeButton = [[UIBarButtonItem alloc] initWithTitle:@"Route"
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(routeMapOverview)];
        [routeButton setEnabled:NO];
        [[self navigationItem] setRightBarButtonItem:routeButton];
        
        itineraryStore = [[TAItineraryStore alloc] init];
        [itineraryStore setDelegate:self];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self unlockViewController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self view] endEditing: YES];
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

- (IBAction)swapStartAndEndFields
{
    NSString *start = [startField text];
    [startField setText:[endField text]];
    [endField setText:start];
}

- (void)routeMapOverview
{
    // make sure user didn't swap fields to somehow enable the route button
    if ([[startField text] length] == 0) {
        [startField becomeFirstResponder];
        return;
    }
    
    if (([[endField text] length] == 0)) {
        [endField becomeFirstResponder];
        return;
    }
    
    [self lockViewController];
    
    [itineraryStore setStartLocation:[startField text]];
    [itineraryStore setEndLocation:[endField text]];
    [itineraryStore fetchItineraries];
}

- (void)itineraryStore:(TAItineraryStore *)store didFetchItineraries:(NSArray *)itineraries
{
    TAMapViewController *mapController = [[TAMapViewController alloc] init];
    
    UIBarButtonItem *transitButton = [[UIBarButtonItem alloc] initWithTitle:navigationTitle
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:transitButton];
    
    [[self navigationController] pushViewController:mapController animated:YES];
}

- (void)itineraryStore:(TAItineraryStore *)store didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Directions Not Available"
                                                        message:[error localizedDescription]
                                                       delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    
    [alertView show];
    [self unlockViewController];
}

- (void)lockViewController
{
    [[self navigationItem] setTitle:@"Loading..."];
    [routeButton setEnabled:NO];
    [startField setEnabled:NO];
    [endField setEnabled:NO];
    [swapFieldsButton setEnabled:NO];
    [[self view] endEditing: YES];
}

- (void)unlockViewController
{
    [[self navigationItem] setTitle:navigationTitle];
    [routeButton setEnabled:YES];
    [startField setEnabled:YES];
    [endField setEnabled:YES];
    [swapFieldsButton setEnabled:YES];
    [endField becomeFirstResponder];
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
            [self routeMapOverview];
        }
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    int currentLength = [[textField text] length];
    int newLength = currentLength - range.length + [string length];
    
    if (newLength == 0) {
        if ([routeButton isEnabled]) {
            [routeButton setEnabled:NO];
        }
    } else if (currentLength == 0) {
        BOOL inputComplete = ((textField == startField) && ([[endField text] length] > 0))
                             || ((textField == endField) && ([[startField text] length] > 0));
        
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
