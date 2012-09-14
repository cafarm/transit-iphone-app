//
//  MKMapView+SetRegionToFitAnnotations.h
//  Transit
//
//  Created by Mark Cafaro on 7/28/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (SetRegionToFitAnnotations)

- (void)setRegionToFitAnnotationsWithAnimation:(BOOL)animated;

@end
