//
//  TATrip.m
//  Transit
//
//  Created by Mark Cafaro on 7/13/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATrip.h"
#import "TAItinerary.h"

@interface TATrip ()
{
    NSMutableString *_currentString;
}

@end

@implementation TATrip

@synthesize itineraries=_itineraries;

- (id)init
{
    self = [super init];
    if (self) {
        _itineraries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parser:(DTHTMLParser *)parser foundComment:(NSString *)comment
{
    // TODO: signal to the controller that we found an itinerary list
//    if ([comment isEqualToString:@" Begin Itinerary List "]) {
//        
//    }
    
    if (([comment hasPrefix:@" Begin Itinerary "]) && ([comment characterAtIndex:17] != 'L')) {
        DLog(@"%@ found itinerary: %@", self, comment);
        
        TAItinerary *itinerary = [[TAItinerary alloc] init];
        [itinerary setParentParserDelegate:self];
        
        [self.itineraries addObject:itinerary];
        
        [parser setDelegate:itinerary];
    }
}

@end
