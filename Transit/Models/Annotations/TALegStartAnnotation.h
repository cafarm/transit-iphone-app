//
//  TALegStartAnnotation.h
//  Transit
//
//  Created by Mark Cafaro on 8/2/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class OTPLeg;

@interface TALegStartAnnotation : NSObject <MKAnnotation>

- (id)initWithLeg:(OTPLeg *)leg;

@property (readonly, nonatomic) OTPLeg *leg;

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (readonly, copy, nonatomic) NSString *title;

@end
