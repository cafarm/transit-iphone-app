//
//  TALocationManager.m
//  Transit
//
//  Created by Mark Cafaro on 7/27/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationManager.h"

@implementation TALocationManager

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

+ (TALocationManager *)sharedManager
{
    static TALocationManager *sharedManager = nil;
    if (!sharedManager) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

@end
