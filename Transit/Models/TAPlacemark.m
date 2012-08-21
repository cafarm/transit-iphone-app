//
//  TAPlacemark.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "TAPlacemark.h"
#import "GPClient.h"

@implementation TAPlacemark

@synthesize name = _name;
@synthesize locality = _locality;
@synthesize types = _types;
@synthesize location = _location;
@synthesize isCurrentLocation = _isCurrentLocation;

+ (TAPlacemark *)currentLocation
{
    return [[TAPlacemark alloc] initWithName:@"Current Location" locality:nil types:nil location:nil isCurrentLocation:YES];
}

+ (TAPlacemark *)placemarkWithCLPlacemark:(CLPlacemark *)placemark
{
    NSString *name;
    if (placemark.name != nil) {
        name = placemark.name;
    } else if (placemark.subThoroughfare != nil) {
        name = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
    } else if (placemark.thoroughfare != nil) {
        name = placemark.thoroughfare;
    } else if (placemark.subLocality != nil) {
        name = placemark.subLocality;
    } else {
        name = placemark.locality;
    }
    
    return [[TAPlacemark alloc] initWithName:name locality:placemark.locality types:nil location:placemark.location isCurrentLocation:NO];
}

+ (TAPlacemark *)placemarkWithGPDetailsResult:(GPDetailsResult *)result;
{
    // FIXME: This is hacky, we should be using the real address components
    NSArray *addressComponents = [result.vicinity componentsSeparatedByString:@", "];
    NSString *locality = [addressComponents lastObject];
    
    GPDetailsLocation *resultLocation = result.geometry.location;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[resultLocation.latitude doubleValue]
                                                      longitude:[resultLocation.longitude doubleValue]];
    
    return [[TAPlacemark alloc] initWithName:result.name locality:locality types:result.types location:location isCurrentLocation:NO];
}

- (id)initWithName:(NSString *)name locality:(NSString *)locality types:(NSArray *)types location:(CLLocation *)location isCurrentLocation:(BOOL)isCurrentLocation
{
    self = [super init];
    if (self) {
        _name = name;
        _locality = locality;
        _types = types;
        _location = location;
        _isCurrentLocation = isCurrentLocation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithName:[aDecoder decodeObjectForKey:@"name"]
                     locality:[aDecoder decodeObjectForKey:@"locality"]
                        types:[aDecoder decodeObjectForKey:@"types"]
                     location:[aDecoder decodeObjectForKey:@"location"]
            isCurrentLocation:[aDecoder decodeBoolForKey:@"isCurrentLocation"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.locality forKey:@"locality"];
    [aCoder encodeObject:self.types forKey:@"types"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeBool:self.isCurrentLocation forKey:@"isCurrentLocation"];
}

@end
