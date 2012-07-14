//
//  TAItineraryStoreDelegate.h
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TAItineraryStore;

@protocol TAItineraryStoreDelegate <NSObject>

@optional

- (void)itineraryStore:(TAItineraryStore *)store didFetchItineraries:(NSArray *)itineraries;
- (void)itineraryStore:(TAItineraryStore *)store didFailWithError:(NSError *)error;

@end
