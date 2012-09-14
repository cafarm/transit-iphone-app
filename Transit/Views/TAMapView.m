//
//  TAMapView.m
//  Transit
//
//  Created by Mark Cafaro on 7/28/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAMapView.h"
#import "OTPItinerary.h"
#import "OTPLeg.h"
#import "OTPPlace.h"

@implementation TAMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setRegionToItinerary:(OTPItinerary *)itinerary animated:(BOOL)animated
{
    CLLocationCoordinate2D topLeftCoordinate = {
        .latitude = -90,
        .longitude = 180
    };
    
    CLLocationCoordinate2D bottomRightCoordinate = {
        .latitude = 90,
        .longitude = -180
    };
        
    NSMutableArray *places = [NSMutableArray arrayWithCapacity:([itinerary.legs count] + 1)];
    for (OTPLeg *leg in itinerary.legs) {
        BOOL isLast = leg == itinerary.legs.lastObject;
        
        if (!isLast) {
            [places addObject:leg.from];
        } else {
            [places addObject:leg.to];
        }
    }
    
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
    
    // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.1;
    
    region = [self regionThatFits:region];
    [self setRegion:region animated:animated];
}


@end
