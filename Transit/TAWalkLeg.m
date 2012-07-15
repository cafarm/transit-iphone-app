//
//  TAWalkLeg.m
//  Transit
//
//  Created by Mark Cafaro on 7/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAWalkLeg.h"

@implementation TAWalkLeg

- (id)initWithElementString:(NSString *)elementString
{
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"[0-9\\.]+"
                                                                           options:0
                                                                             error:nil];
    
    NSArray *matches = [expression matchesInString:elementString
                                           options:0
                                             range:NSMakeRange(0, [elementString length])];
    
    float distanceInMiles = 0.0f;
    if ([matches count] > 0) {
        NSTextCheckingResult *result = [matches objectAtIndex:0];
        NSRange range = [result range];
        
        distanceInMiles = [[elementString substringWithRange:range] floatValue];
    }
    
    int distanceInMeters = distanceInMiles * 1609.34f;
    
    return [self initWithTravelMode:TAWalk distance:distanceInMeters];
}

@end
