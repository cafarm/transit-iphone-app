//
//  MKMapView+Transit.h
//  Transit
//
//  Created by Mark Cafaro on 7/29/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <MapKit/MapKit.h>

@class OTPItinerary;
@class TAStep;
@class TACurrentStepAnnotation;

@interface MKMapView (Transit)

- (void)setVisibleMapRectToFitItinerary:(OTPItinerary *)itinerary animated:(BOOL)animated;
- (void)setVisibleMapRectToFitStep:(TAStep *)step animated:(BOOL)animated;

- (void)addOverlayForItinerary:(OTPItinerary *)itinerary;
- (void)removeAllOverlays;

- (TACurrentStepAnnotation *)addAnnotationForCurrentStep:(TAStep *)step;
- (void)addAnnotationsForSteps:(NSArray *)steps;
- (void)removeAllAnnotations;

@end
