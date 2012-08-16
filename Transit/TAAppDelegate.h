//
//  TAAppDelegate.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTPObjectManager;
@class GPObjectManager;
@class TALocationManager;

@interface TAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OTPObjectManager *otpObjectManager;
@property (strong, nonatomic) GPObjectManager *gpObjectManager;
@property (strong, nonatomic) TALocationManager *locationManager;

@property (strong, nonatomic) UINavigationController *navigationController;

@end