//
//  TALocationSuggestionsController.m
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationSuggestionsController.h"
#import "GPObjectManager.h"
#import "TALocationManager.h"
#import "TALocationSuggestion.h"
#import "GPAutocompletePrediction.h"

@interface TALocationSuggestionsController()

@property (readwrite, strong, nonatomic) NSArray *fetchedSuggestions;

@end

@implementation TALocationSuggestionsController

@synthesize input = _input;
@synthesize gpObjectManager = _gpObjectManager;
@synthesize locationManager = _locationManager;

@synthesize delegate = _delegate;

@synthesize fetchedSuggestions = _fetchedSuggestions;

- (id)initWithInput:(NSString *)input
    gpObjectManager:(GPObjectManager *)gpObjectManager
    locationManager:(TALocationManager *)locationManager
{
    self = [super init];
    if (self) {
        _input = input;
        _gpObjectManager = gpObjectManager;
        _locationManager = locationManager;
    }
    return self;
}

- (void)fetchSuggestions
{
    [self.gpObjectManager loadAutocompletePredictionsWithInput:self.input
                                                    location:self.locationManager.currentLocation.coordinate
                                                      radius:TARadiusDistanceOfInterest
                                           completionHandler:^(NSArray *predictions, NSError *error)
    {
        NSMutableArray *suggestions = nil;
        if (error != nil) {
            suggestions = [NSMutableArray arrayWithCapacity:[predictions count]];
            for (GPAutocompletePrediction *prediction in predictions) {
                [suggestions addObject:[TALocationSuggestion suggestionWithPrediction:prediction]];
            }
        }
        self.fetchedSuggestions = suggestions;
        
        if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            [self.delegate controllerDidChangeContent:self];
        }
    }];
}

- (TALocationSuggestion *)suggestionAtIndexPath:(NSUInteger)index
{
    return [self.fetchedSuggestions objectAtIndex:index];
}

- (NSUInteger)numberOfRows
{
    return [self.fetchedSuggestions count];
}

@end
