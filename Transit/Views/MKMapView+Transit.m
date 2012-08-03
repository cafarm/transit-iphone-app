//
//  MKMapView+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 7/29/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "MKMapView+Transit.h"
#import "OTPItinerary.h"
#import "OTPLeg.h"
#import "OTPPlace.h"
#import "TALegStartAnnotation.h"

@implementation MKMapView (Transit)

- (void)setRegionToFitItinerary:(OTPItinerary *)itinerary animated:(BOOL)animated
{
    NSMutableArray *places = [NSMutableArray arrayWithCapacity:([itinerary.legs count] + 1)];

    for (OTPLeg *leg in itinerary.legs) {        
        [places addObject:leg.from];
        
        if (leg == itinerary.legs.lastObject) {
            [places addObject:leg.to];
        }
    }
    [self setRegionToFitPlaces:places animated:animated];
}

- (void)setRegionToFitLeg:(OTPLeg *)leg animated:(BOOL)animated
{
    NSArray *places = [NSArray arrayWithObjects:leg.from, leg.to, nil];
    [self setRegionToFitPlaces:places animated:animated];
}

- (void)setRegionToFitPlaces:(NSArray *)places animated:(BOOL)animated
{
    CLLocationCoordinate2D topLeftCoordinate = {
        .latitude = -90,
        .longitude = 180
    };
    
    CLLocationCoordinate2D bottomRightCoordinate = {
        .latitude = 90,
        .longitude = -180
    };
    
    for (OTPPlace *place in places) {
        topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, [place.longitude doubleValue]);
        topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, [place.latitude doubleValue]);
        bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, [place.longitude doubleValue]);
        bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, [place.latitude doubleValue]);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5;
    region.center.longitude = topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 1.1;
    
    // add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.1;
    
    region = [self regionThatFits:region];
    [self setRegion:region animated:animated];
}

- (void)addOverlayForItinerary:(OTPItinerary *)itinerary
{
    for (OTPLeg *leg in itinerary.legs) {
        [self addOverlayForLeg:leg];
    }
}

- (void)addOverlayForLeg:(OTPLeg *)leg
{
    TALegStartAnnotation *legStartAnnotation = [[TALegStartAnnotation alloc] initWithLeg:leg];
    [self addAnnotation:legStartAnnotation];
    
    MKPolyline *polyline = leg.polyline;
    
    [self addOverlay:polyline];
}

@end
