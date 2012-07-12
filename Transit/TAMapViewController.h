//
//  TAMapViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MKMapView;
@class TAItinerary;

@interface TAMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) TAItinerary *itinerary;

- (void)followCurrentLocation;
- (void)followCurrentLocationWithHeading;
- (void)stopFollowingCurrentLocation;
- (void)presentDirectionsTable;
- (void)presentTransitOptions;
- (void)startStepByStepMap;

@end
