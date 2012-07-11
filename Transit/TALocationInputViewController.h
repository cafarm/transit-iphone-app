//
//  TALocationInputViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TALocationInputViewController : UIViewController <UITextFieldDelegate>
{
    UIBarButtonItem *routeButton;
    IBOutlet UITextField *startField;
    IBOutlet UITextField *endField;
    IBOutlet UIButton *swapFieldsButton;
}

- (void)routeMapOverview;

@end
