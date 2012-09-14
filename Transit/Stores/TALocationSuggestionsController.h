//
//  TALocationSuggestionsController.h
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPObjectManager;
@class TALocationSuggestion;
@class TALocationManager;

@protocol TALocationSuggestionsControllerDelegate;

@interface TALocationSuggestionsController : NSObject

- (id)initWithInput:(NSString *)input
    gpObjectManager:(GPObjectManager *)gpObjectManager
    locationManager:(TALocationManager *)locationManager;

@property (copy, nonatomic) NSString *input;
@property (readonly, strong, nonatomic) GPObjectManager *gpObjectManager;
@property (readonly, strong, nonatomic) TALocationManager *locationManager;

- (void)fetchSuggestions;
@property (weak, nonatomic) id<TALocationSuggestionsControllerDelegate> delegate;

@property (readonly, strong, nonatomic) NSArray *fetchedSuggestions;
- (TALocationSuggestion *)suggestionAtIndexPath:(NSUInteger)indexPath;

- (NSUInteger)numberOfRows;

@end


@protocol TALocationSuggestionsControllerDelegate <NSObject>

@optional

- (void)controllerDidChangeContent:(TALocationSuggestionsController *)controller;

@end
