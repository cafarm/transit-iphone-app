//
//  TALocationManager.h
//  Transit
//
//  Created by Mark Cafaro on 7/27/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface TALocationManager : CLLocationManager

+ (TALocationManager *)sharedManager;

@end
