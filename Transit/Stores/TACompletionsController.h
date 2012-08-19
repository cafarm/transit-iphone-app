//
//  TALocationCompletionsController.h
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPObjectManager;
@class TACompletion;
@class TATripPlanCompletion;
@class TALocationManager;

@protocol TACompletionsControllerDelegate;

@interface TACompletionsController : NSObject

- (id)initWithInput:(NSString *)input
    gpObjectManager:(GPObjectManager *)gpObjectManager
    locationManager:(TALocationManager *)locationManager;

@property (copy, nonatomic) NSString *input;
@property (readonly, strong, nonatomic) GPObjectManager *gpObjectManager;
@property (readonly, strong, nonatomic) TALocationManager *locationManager;

- (void)fetchCompletionsIncludingCurrentLocation:(BOOL)shouldIncludeCurrentLocation;
@property (weak, nonatomic) id<TACompletionsControllerDelegate> delegate;
@property (readonly, strong, nonatomic) NSArray *fetchedCompletions;
- (TACompletion *)completionAtIndexPath:(NSUInteger)indexPath;

- (NSUInteger)numberOfRows;

- (void)addTripPlanCompletion:(TATripPlanCompletion *)completion;

@end


@protocol TACompletionsControllerDelegate <NSObject>

@optional

- (void)controllerDidChangeContent:(TACompletionsController *)controller;

@end
