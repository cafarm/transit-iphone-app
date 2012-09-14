//
//  TALocationCompletionsController.m
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationCompletionsController.h"
#import "GPObjectManager.h"
#import "TALocationManager.h"
#import "TALocationCompletion.h"
#import "GPAutocompletePrediction.h"

@interface TALocationCompletionsController()

@property (readwrite, strong, nonatomic) NSArray *fetchedCompletions;

@end

@implementation TALocationCompletionsController

@synthesize input = _input;
@synthesize gpObjectManager = _gpObjectManager;
@synthesize locationManager = _locationManager;

@synthesize delegate = _delegate;

@synthesize fetchedCompletions = _fetchedSuggestions;

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

- (void)fetchCompletions
{
    [self.gpObjectManager loadAutocompletePredictionsWithInput:self.input
                                                    location:self.locationManager.currentLocation.coordinate
                                                      radius:TARadiusOfInterest
                                           completionHandler:^(NSArray *predictions, NSError *error)
    {
        NSMutableArray *completions = nil;
        if (error == nil) {
            completions = [NSMutableArray arrayWithCapacity:[predictions count]];
            for (GPAutocompletePrediction *prediction in predictions) {
                [completions addObject:[TALocationCompletion completionWithPrediction:prediction]];
            }
        }
        self.fetchedCompletions = completions;
        
        if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            [self.delegate controllerDidChangeContent:self];
        }
    }];
}

- (TALocationCompletion *)completionAtIndexPath:(NSUInteger)index
{
    return [self.fetchedCompletions objectAtIndex:index];
}

- (NSUInteger)numberOfRows
{
    return [self.fetchedCompletions count];
}

@end
