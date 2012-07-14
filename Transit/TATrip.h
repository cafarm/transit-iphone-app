//
//  TATrip.h
//  Transit
//
//  Created by Mark Cafaro on 7/13/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TATrip : NSObject <NSXMLParserDelegate>

@property (readonly, strong, nonatomic) NSMutableArray *itineraries;

@end
