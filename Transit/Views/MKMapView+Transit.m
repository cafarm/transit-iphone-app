//
//  MKMapView+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 7/29/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "MKMapView+Transit.h"
#import "TAPlaceStep.h"
#import "TAWalkStep.h"
#import "TATransitStep.h"
#import "TAStepAnnotation.h"
#import "TACurrentStepAnnotation.h"
#import "OTPClient.h"

static const double TAZoomWidthMin = 1500;

@implementation MKMapView (Transit)

- (void)setVisibleMapRectToFitItinerary:(OTPItinerary *)itinerary edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animate
{
    MKMapRect rect = [self restrictedRectForRect:itinerary.boundingMapRect];
    [self setVisibleMapRect:rect edgePadding:edgePadding animated:animate];
}

- (void)setVisibleMapRectToFitStep:(TAStep *)step edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animate
{
    if (([step isKindOfClass:[TAPlaceStep class]] && ((TAPlaceStep *)step).isDestination) || [step isKindOfClass:[TAWalkStep class]] || ([step isKindOfClass:[TATransitStep class]] && !((TATransitStep *)step).isArrival)) {
        // At the end of walking we don't have a step but we want to set the region to it's leg anyway
        if (step.previousStep != nil && [step.previousStep isKindOfClass:[TAWalkStep class]]) {
            MKMapRect rect = [self restrictedRectForRect:step.previousStep.boundingMapRect];
            [self setVisibleMapRect:rect edgePadding:edgePadding animated:animate];
        } else {
            MKMapPoint point = step.place.mapPoint;
            MKMapRect pointRect = MKMapRectMake(point.x - TAZoomWidthMin / 2, point.y, TAZoomWidthMin, 0);
            [self setVisibleMapRect:pointRect edgePadding:edgePadding animated:animate];
        }
    } else {
        MKMapRect rect = [self restrictedRectForRect:step.boundingMapRect];
        [self setVisibleMapRect:rect edgePadding:edgePadding animated:animate];
    }
}

- (MKMapRect)restrictedRectForRect:(MKMapRect)rect
{
    if (rect.size.width < TAZoomWidthMin) {
        double x = rect.origin.x - ((TAZoomWidthMin - rect.size.width) / 2);
        double width = TAZoomWidthMin;
        return MKMapRectMake(x, rect.origin.y, width, rect.size.height);
    } else {
        return rect;
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
    TAStepAnnotationFacing direction = TAStepAnnotationFacingRight;
    for (TAStep *step in steps) {
        if ([step isKindOfClass:[TAPlaceStep class]] || [step isKindOfClass:[TAWalkStep class]] || !((TATransitStep *)step).isArrival) {
            TAStepAnnotation *stepAnnotation = [[TAStepAnnotation alloc] initWithStep:step direction:direction];
            [self addAnnotation:stepAnnotation];
            
            // FIXME: There is probably a better way to do this than just alternating directions
            if (direction == TAStepAnnotationFacingLeft) {
                direction = TAStepAnnotationFacingRight;
            } else {
                direction = TAStepAnnotationFacingLeft;
            }
        }
    }
}

- (void)removeAllAnnotations
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (id<MKAnnotation> annotation in self.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [annotations addObject:annotation];
        }
    }
    [self removeAnnotations:annotations];
}

@end
