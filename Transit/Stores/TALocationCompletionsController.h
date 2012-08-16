//
//  TALocationCompletionsController.h
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPObjectManager;
@class TALocationCompletion;
@class TALocationManager;

@protocol TALocationCompletionsControllerDelegate;

@interface TALocationCompletionsController : NSObject

- (id)initWithInput:(NSString *)input
    gpObjectManager:(GPObjectManager *)gpObjectManager
    locationManager:(TALocationManager *)locationManager;

@property (copy, nonatomic) NSString *input;
@property (readonly, strong, nonatomic) GPObjectManager *gpObjectManager;
@property (readonly, strong, nonatomic) TALocationManager *locationManager;

- (void)fetchCompletions;
@property (weak, nonatomic) id<TALocationCompletionsControllerDelegate> delegate;

@property (readonly, strong, nonatomic) NSArray *fetchedCompletions;
- (TALocationCompletion *)completionAtIndexPath:(NSUInteger)indexPath;

- (NSUInteger)numberOfRows;

@end


@protocol TALocationCompletionsControllerDelegate <NSObject>

@optional

- (void)controllerDidChangeContent:(TALocationCompletionsController *)controller;

@end
