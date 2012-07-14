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
@class TATrip;

@interface TAMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) TATrip *trip;

- (void)followCurrentLocation;
- (void)followCurrentLocationWithHeading;
- (void)stopFollowingCurrentLocation;
- (void)presentDirectionsTable;
- (void)presentTransitOptions;
- (void)startStepByStepMap;

@end
