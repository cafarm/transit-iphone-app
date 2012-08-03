//
//  TAAppDelegate.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTPObjectManager;

@interface TAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OTPObjectManager *objectManager;

@property (strong, nonatomic) UINavigationController *navigationController;

@end
