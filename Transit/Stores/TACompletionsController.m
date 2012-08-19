//
//  TALocationCompletionsController.m
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACompletionsController.h"
#import "GPObjectManager.h"
#import "TALocationManager.h"
#import "TACurrentLocationCompletion.h"
#import "TATripPlanCompletion.h"
#import "TAPlaceCompletion.h"
#import "TAAttributionCompletion.h"
#import "GPAutocompletePrediction.h"

@interface TACompletionsController()

@property (strong, nonatomic) TACurrentLocationCompletion *fetchedCurrentLocationCompletion;
@property (strong, nonatomic) NSMutableArray *fetchedTripPlanCompletions;
@property (strong, nonatomic) NSMutableArray *fetchedPlaceCompletions;

@property (strong, nonatomic) TACurrentLocationCompletion *currentLocationCompletion;
@property (strong, nonatomic) NSMutableArray *tripPlanCompletions;

@end


@implementation TACompletionsController

@synthesize input = _input;
@synthesize gpObjectManager = _gpObjectManager;
@synthesize locationManager = _locationManager;

@synthesize delegate = _delegate;

@synthesize fetchedCompletions = _fetchedCompletions;

@synthesize fetchedCurrentLocationCompletion = _fetchedCurrentLocationCompletion;
@synthesize fetchedTripPlanCompletions = _fetchedTripPlanCompletions;
@synthesize fetchedPlaceCompletions = _fetchedPlaceCompletions;

@synthesize currentLocationCompletion = _currentLocationCompletion;
@synthesize tripPlanCompletions = _tripPlanCompletions;

- (id)initWithInput:(NSString *)input
    gpObjectManager:(GPObjectManager *)gpObjectManager
    locationManager:(TALocationManager *)locationManager
{
    self = [super init];
    if (self) {
        _input = input;
        _gpObjectManager = gpObjectManager;
        _locationManager = locationManager;
        
        NSString *path = [self tripPlanCompletionArchivePath];
        _tripPlanCompletions = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (_tripPlanCompletions == nil) {
            _tripPlanCompletions = [NSMutableArray array];
        }
        
        _currentLocationCompletion = [[TACurrentLocationCompletion alloc] init];
    }
    return self;
}

- (void)fetchCompletionsIncludingCurrentLocation:(BOOL)shouldIncludeCurrentLocation
{
    if (shouldIncludeCurrentLocation) {
        self.fetchedCurrentLocationCompletion = self.currentLocationCompletion;
    } else {
        self.fetchedCurrentLocationCompletion = nil;
    }
    
    if ([self.input isEqualToString:@""]) {
        self.fetchedPlaceCompletions = nil;
        self.fetchedTripPlanCompletions = self.tripPlanCompletions;
    } else {
        self.fetchedTripPlanCompletions = nil;
        [self fetchPlaceCompletions];
    }
    
    if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [self.delegate controllerDidChangeContent:self];
    }
}

- (void)fetchPlaceCompletions
{    
    [self.gpObjectManager loadAutocompletePredictionsWithInput:self.input
                                                      location:self.locationManager.currentLocation.coordinate
                                                        radius:TARadiusOfInterest
                                             completionHandler:^(NSArray *predictions, NSError *error)
     {
         self.fetchedPlaceCompletions = nil;
         if (error == nil) {
             self.fetchedPlaceCompletions = [NSMutableArray arrayWithCapacity:[predictions count] + 1];
             for (GPAutocompletePrediction *prediction in predictions) {
                 [self.fetchedPlaceCompletions addObject:[TAPlaceCompletion completionWithPrediction:prediction]];
             }
             
             // Add the required attribution to the bottom if predictions were provided
             if ([predictions count] > 0) {
                 [self.fetchedPlaceCompletions addObject:[TAAttributionCompletion google]];
             }
         }
         if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
             [self.delegate controllerDidChangeContent:self];
         }
     }];
}

- (NSArray *)fetchedCompletions
{
    NSMutableArray *completions = [NSMutableArray array];
    if (self.fetchedCurrentLocationCompletion != nil) {
        [completions addObject:self.fetchedCurrentLocationCompletion];
    }
    [completions addObjectsFromArray:self.fetchedTripPlanCompletions];
    [completions addObjectsFromArray:self.fetchedPlaceCompletions];
    return completions;
}

- (TACompletion *)completionAtIndexPath:(NSUInteger)index
{
    return [self.fetchedCompletions objectAtIndex:index];
}

- (NSUInteger)numberOfRows
{
    return [self.fetchedCompletions count];
}

- (void)addTripPlanCompletion:(TATripPlanCompletion *)completion
{
    // Keep our trip plan completions at a reasonable size
    if ([self.tripPlanCompletions count] >= 14) {
        [self.tripPlanCompletions removeLastObject];
    }

    [self.tripPlanCompletions insertObject:completion atIndex:0];
}

- (NSString *)tripPlanCompletionArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"tripPlanCompletions.archive"];
}

@end
