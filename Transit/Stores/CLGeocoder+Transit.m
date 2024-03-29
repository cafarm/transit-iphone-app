//
//  CLGeocoder+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 8/19/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "CLGeocoder+Transit.h"
#import "TALocationField.h"
#import "TAPlaceMark.h"
#import "GPClient.h"

@implementation CLGeocoder (Transit)

- (void)geocodeField:(TALocationField *)field
            inRegion:(CLRegion *)region
     gpObjectManager:(GPObjectManager *)gpObjectManager
   completionHandler:(void (^)(TAPlacemark *placemark, NSError *error))completionHandler
{
    if (field.contentType == TALocationFieldContentTypeCurrentLocation) {
        completionHandler([TAPlacemark currentLocation], nil);
        
    } else if (field.contentType == TALocationFieldContentTypeGooglePlace) {
        [gpObjectManager fetchDetailsResultWithReference:field.contentReference
                                       completionHandler:^(GPDetailsResult *result, NSError *error)
        {
            TAPlacemark *placemark;
            if (error == nil) {                
                placemark = [TAPlacemark placemarkWithGPDetailsResult:result];
            }
            completionHandler(placemark, error);
        }];
        
    } else if (field.contentType == TALocationFieldContentTypePlacemark) {
        completionHandler(field.contentReference, nil);
        
    } else {
        [self geocodeAddressString:field.text
                          inRegion:region
                 completionHandler:^(NSArray *placemarks, NSError *error)
         {
             TAPlacemark *placemark;
             if (error == nil) {
                 placemark = [TAPlacemark placemarkWithCLPlacemark:[placemarks objectAtIndex:0]];
             }
             completionHandler(placemark, error);
         }];
    }
}

@end
