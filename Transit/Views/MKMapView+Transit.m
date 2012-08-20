//
//  MKMapView+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 7/29/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "MKMapView+Transit.h"
#import "TAStep.h"
#import "TAStepAnnotation.h"
#import "TACurrentStepAnnotation.h"
#import "OTPClient.h"

static const double kZoomRectWidthMin = 1280;
static const double kZoomRectHeightMin = 1920;

@implementation MKMapView (Transit)

- (void)setVisibleMapRectToFitItinerary:(OTPItinerary *)itinerary animated:(BOOL)animate
{
    [self setVisibleMapRect:itinerary.boundingMapRect animated:animate];
}

- (void)setVisibleMapRectToFitStep:(TAStep *)step animated:(BOOL)animate
{
//    UIEdgeInsets edgePadding = UIEdgeInsetsMake(self.bounds.size.height - 279, 0, 0, 0);
    UIEdgeInsets edgePadding = UIEdgeInsetsMake(0, 0, 0, 0);

    if (step.fromOrTo == TAStepFrom) {
        // At the end of walking we don't have a step but we want to set the region to it's leg anyway
        if (step.previousStep != nil && step.previousStep.mode == OTPLegTraverseModeWalk) {
            [self setVisibleMapRect:step.previousStep.boundingMapRect edgePadding:edgePadding animated:animate];
        } else {
            MKMapPoint point = step.place.mapPoint;
            MKMapRect pointRect = MKMapRectMake(point.x, point.y, 0, 0);
            [self setVisibleMapRect:pointRect edgePadding:edgePadding animated:animate];
        }
    } else {
        [self setVisibleMapRect:step.boundingMapRect edgePadding:edgePadding animated:animate];
    }
}

- (void)addOverlayForItinerary:(OTPItinerary *)itinerary
{
    for (OTPLeg *leg in itinerary.legs) {
        [self addOverlayForLeg:leg];
    }
}

- (void)addOverlayForLeg:(OTPLeg *)leg
{
    MKPolyline *polyline = leg.polyline;
    
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
