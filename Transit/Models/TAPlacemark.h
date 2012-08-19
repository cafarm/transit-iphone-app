//
//  TAPlacemark.h
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface TAPlacemark : CLPlacemark

+ (TAPlacemark *)currentLocation;

- (id)initCurrentLocation;

@property (readonly, nonatomic) BOOL isCurrentLocation;

@end
