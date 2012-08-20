//
//  CLGeocoder+Transit.h
//  Transit
//
//  Created by Mark Cafaro on 8/19/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class TALocationField;
@class GPObjectManager;
@class TAPlacemark;

@interface CLGeocoder (Transit)

- (void)geocodeField:(TALocationField *)field
            inRegion:(CLRegion *)region
     gpObjectManager:(GPObjectManager *)gpObjectManager
   completionHandler:(void (^)(TAPlacemark *placemark, NSError *error))completionHandler;

@end
