//
//  TAPlaceAnnotation.h
//  Transit
//
//  Created by Mark Cafaro on 7/28/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class OTPPlace;

@interface TAPlaceAnnotation : NSObject <MKAnnotation>

- (id)initWithPlace:(OTPPlace *)place;

@property (readonly, nonatomic) OTPPlace *place;
@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (readonly, copy, nonatomic) NSString *title;

@end
