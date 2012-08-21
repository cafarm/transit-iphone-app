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
@class GPDetailsResult;

@interface TAPlacemark : NSObject <NSCoding>

+ (TAPlacemark *)currentLocation;
+ (TAPlacemark *)placemarkWithCLPlacemark:(CLPlacemark *)placemark;
+ (TAPlacemark *)placemarkWithGPDetailsResult:(GPDetailsResult *)result;

- (id)initWithName:(NSString *)name locality:(NSString *)locality types:(NSArray *)types location:(CLLocation *)location isCurrentLocation:(BOOL)isCurrentLocation;

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *locality;
@property (readonly, nonatomic) NSArray *types;
@property (readonly, nonatomic) CLLocation *location;
@property (readonly, nonatomic) BOOL isCurrentLocation;

@end
