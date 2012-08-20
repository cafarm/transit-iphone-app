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
@synthesize vicinity = _vicinity;
@synthesize types = _types;
@synthesize location = _location;
@synthesize isCurrentLocation = _isCurrentLocation;

+ (TAPlacemark *)currentLocation
{
    return [[TAPlacemark alloc] initWithName:@"Current Location" vicinity:nil types:nil location:nil isCurrentLocation:YES];
}

+ (TAPlacemark *)placemarkWithCLPlacemark:(CLPlacemark *)placemark
{
    NSString *vicinity = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.locality];
    return [[TAPlacemark alloc] initWithName:placemark.name vicinity:vicinity types:nil location:placemark.location isCurrentLocation:NO];
}

+ (TAPlacemark *)placemarkWithGPDetailsResult:(GPDetailsResult *)result;
{
    GPDetailsLocation *resultLocation = result.geometry.location;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[resultLocation.latitude doubleValue]
                                                      longitude:[resultLocation.longitude doubleValue]];
    
    return [[TAPlacemark alloc] initWithName:result.name vicinity:result.vicinity types:result.types location:location isCurrentLocation:NO];
}

- (id)initWithName:(NSString *)name vicinity:(NSString *)vicinity types:(NSArray *)types location:(CLLocation *)location isCurrentLocation:(BOOL)isCurrentLocation;
{
    self = [super init];
    if (self) {
        _name = name;
        _vicinity = vicinity;
        _types = types;
        _location = location;
        _isCurrentLocation = isCurrentLocation;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithName:[aDecoder decodeObjectForKey:@"name"]
                     vicinity:[aDecoder decodeObjectForKey:@"vicinity"]
                        types:[aDecoder decodeObjectForKey:@"types"]
                     location:[aDecoder decodeObjectForKey:@"location"]
            isCurrentLocation:[aDecoder decodeBoolForKey:@"isCurrentLocation"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.vicinity forKey:@"vicinity"];
    [aCoder encodeObject:self.types forKey:@"types"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeBool:self.isCurrentLocation forKey:@"isCurrentLocation"];
}

- (NSString *)description
{
    NSString *description = self.name;
    
    // FIXME: This is hacky, we should be using real address components
    if ([self.types containsObject:[NSNumber numberWithInt:GPDetailsResultTypeEstablishment]]) {
        NSArray *addressComponents = [self.vicinity componentsSeparatedByString:@", "];
        description = [description stringByAppendingString:[NSString stringWithFormat:@" (%@)", [addressComponents lastObject]]];
    }
    return description;
}

@end
