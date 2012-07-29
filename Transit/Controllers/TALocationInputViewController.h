//
//  TALocationInputViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TALocationInputViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

- (IBAction)swapFields;
- (void)route;

@end
