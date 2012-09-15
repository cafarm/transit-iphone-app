//
//  TAStepAnnotation.h
//  Transit
//
//  Created by Mark Cafaro on 8/7/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class TAStep;

typedef enum {
    TAStepAnnotationDirectionLeft,
    TAStepAnnotationDirectionRight
} TAStepAnnotationDirection;

@interface TAStepAnnotation : NSObject <MKAnnotation>

- (id)initWithStep:(TAStep *)step direction:(TAStepAnnotationDirection)direction;

@property (readonly, nonatomic) TAStep *step;

@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (readonly, copy, nonatomic) NSString *title;

@property (readonly, nonatomic) TAStepAnnotationDirection direction;

@end
