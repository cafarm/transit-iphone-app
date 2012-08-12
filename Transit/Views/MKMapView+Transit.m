//
//  MKMapView+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 7/29/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "MKMapView+Transit.h"
#import "OTPItinerary.h"
#import "TAStep.h"
#import "OTPLeg.h"
#import "OTPPlace.h"
#import "OTPEncodedPolyline.h"
#import "TAStepAnnotation.h"
#import "TACurrentStepAnnotation.h"

static const double kZoomRectWidthMin = 1280;
static const double kZoomRectHeightMin = 1920;

@implementation MKMapView (Transit)

- (void)setVisibleMapRectToFitItinerary:(OTPItinerary *)itinerary animated:(BOOL)animate
{
    UIEdgeInsets edgePadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setVisibleMapRectToFitLegs:itinerary.legs edgePadding:edgePadding animated:animate];
}

- (void)setVisibleMapRectToFitStep:(TAStep *)step animated:(BOOL)animate
{
    UIEdgeInsets edgePadding = UIEdgeInsetsMake(self.bounds.size.height - 279, 0, 0, 0);
    if (step.fromOrTo == TAFrom) {
        // At the end of walking we don't have a step but we want to set the region to it's leg anyway
        if (step.previousStep != nil && step.previousStep.mode == OTPWalk) {
            [self setVisibleMapRectToFitLegs:step.previousStep.legs edgePadding:edgePadding animated:animate];
        } else {
            [self setVisibleMapRectToFitPlace:step.place edgePadding:edgePadding animated:animate];
        }
    } else {
        [self setVisibleMapRectToFitLegs:step.legs edgePadding:edgePadding animated:animate];
    }
}

- (void)setVisibleMapRectToFitLegs:(NSArray *)legs edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animate
{    
    MKMapRect zoomRect = MKMapRectNull;
    for (OTPLeg *leg in legs) {
        MKPolyline *polyline = [leg.legGeometry polylineValue];
        
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = [polyline boundingMapRect];
        } else {
            zoomRect = MKMapRectUnion(zoomRect, [polyline boundingMapRect]);
        }
    }
    
    // Don't allow the zoomRect to be too small
    if (zoomRect.size.width < kZoomRectWidthMin && zoomRect.size.height < kZoomRectHeightMin) {
        zoomRect = MKMapRectMake(zoomRect.origin.x, zoomRect.origin.x, kZoomRectWidthMin, kZoomRectHeightMin);
    }
    
    [self setVisibleMapRect:zoomRect edgePadding:edgePadding animated:animate];
}

- (void)setVisibleMapRectToFitPlace:(OTPPlace *)place edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animate
{
    MKMapPoint point = place.mapPoint;
    
    MKMapPoint origin = MKMapPointMake(point.x - 2 / 2, point.y - 2 / 2);
    
    MKMapRect zoomRect = MKMapRectMake(origin.x,
                                       origin.y,
                                       2, 2);
        
    [self setVisibleMapRect:zoomRect animated:animate];
//    [self setCenterCoordinate:place.coordinate animated:animate];
}

- (void)addOverlayForItinerary:(OTPItinerary *)itinerary
{
    for (OTPLeg *leg in itinerary.legs) {
        [self addOverlayForLeg:leg];
    }
}

- (void)addOverlayForLeg:(OTPLeg *)leg
{
    MKPolyline *polyline = [leg.legGeometry polylineValue];
    
    [self addOverlay:polyline];
}

- (void)removeAllOverlays
{
    [self removeOverlays:self.overlays];
}

- (TACurrentStepAnnotation *)addAnnotationForCurrentStep:(TAStep *)step
{
    TACurrentStepAnnotation *stepAnnotation = [[TACurrentStepAnnotation alloc] initWithStep:step];
    [self addAnnotation:stepAnnotation];
    return stepAnnotation;
}

- (void)addAnnotationsForSteps:(NSArray *)steps
{
    for (TAStep *step in steps) {
        TAStepAnnotation *stepAnnotation = [[TAStepAnnotation alloc] initWithStep:step];
        [self addAnnotation:stepAnnotation];
    }
}

- (void)removeAllAnnotations
{
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] init];
    for (id<MKAnnotation> annotation in self.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [annotationsToRemove addObject:annotation];
        }
    }
}

@end
