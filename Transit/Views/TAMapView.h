//
//  TAMapView.h
//  Transit
//
//  Created by Mark Cafaro on 7/28/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <MapKit/MapKit.h>

@class OTPItinerary;

@interface TAMapView : MKMapView

- (void)setRegionToItinerary:(OTPItinerary *)itinerary animated:(BOOL)animated;

@end
