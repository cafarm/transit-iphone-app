//
//  MKMapView+SetRegionToFitAnnotations.m
//  Transit
//
//  Created by Mark Cafaro on 7/28/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "MKMapView+SetRegionToFitAnnotations.h"

@implementation MKMapView (SetRegionToFitAnnotations)

- (void)setRegionToFitAnnotationsWithAnimation:(BOOL)animated {
    if ([self.annotations count] == 0) {
        return;
    }
    
    CLLocationCoordinate2D topLeftCoordinate = {
        .latitude = -90,
        .longitude = 180
    };
    
    CLLocationCoordinate2D bottomRightCoordinate = {
        .latitude = 90,
        .longitude = -180
    };
    
    for (id<MKAnnotation> annotation in self.annotations) {
        topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude);
        topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude);
        bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude);
        bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5;
    region.center.longitude = topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 1.1;
    
    // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.1;
    
    region = [self regionThatFits:region];
    [self setRegion:region animated:animated];
}

@end
