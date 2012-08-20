//
//  TAPlacemark.h
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLPlacemark;
@class CLLocation;

@interface TAPlacemark : NSObject

+ (TAPlacemark *)currentLocation;

- (id)initWithCLPlacemark:(CLPlacemark *)placemark isCurrentLocation:(BOOL)isCurrentLocation;
- (id)initWithCLPlacemark:(CLPlacemark *)placemark;

@property (readonly, nonatomic) BOOL isCurrentLocation;

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) CLLocation *location;

@end
