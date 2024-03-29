//
//  TAAppDelegate.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAAppDelegate.h"
#import "TALocationManager.h"
#import "TALocationInputViewController.h"
#import "OTPClient.h"
#import "GPClient.h"

@implementation TAAppDelegate

@synthesize otpObjectManager=_otpObjectManager;
@synthesize navigationController=_navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //self.otpObjectManager = [[OTPObjectManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:4567"]];
    self.otpObjectManager = [[OTPObjectManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://otp.hopto.org/opentripplanner-api-webapp"]];
    
    //self.gpObjectManager = [[GPObjectManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:4567"] apiKey:@"AIzaSyCXTU7jtaUbbQ4ZouFEKabc2VfJv260YhE"];
    self.gpObjectManager = [[GPObjectManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://maps.googleapis.com/maps/api"] apiKey:@"AIzaSyCXTU7jtaUbbQ4ZouFEKabc2VfJv260YhE"];
    
    self.locationManager = [[TALocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
    
    TALocationInputViewController *inputController = [[TALocationInputViewController alloc] initWithOTPObjectManager:self.otpObjectManager
                                                                                                     gpObjectManager:self.gpObjectManager
                                                                                                     locationManager:self.locationManager];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:inputController];
        
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
