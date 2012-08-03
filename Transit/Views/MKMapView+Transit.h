//
//  MKMapView+Transit.h
//  Transit
//
//  Created by Mark Cafaro on 7/29/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <MapKit/MapKit.h>

@class OTPItinerary;
@class OTPLeg;

@interface MKMapView (Transit)

- (void)setRegionToFitItinerary:(OTPItinerary *)itinerary animated:(BOOL)animated;
- (void)setRegionToFitLeg:(OTPLeg *)leg animated:(BOOL)animated;

- (void)addOverlayForItinerary:(OTPItinerary *)itinerary;

@end
