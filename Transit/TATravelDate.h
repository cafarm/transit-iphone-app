//
//  TATravelDate.h
//  Transit
//
//  Created by Mark Cafaro on 7/12/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TADepartAt,
    TAArriveBy
} TADepartAtOrArriveBy;

@interface TATravelDate : NSObject

@property (readonly, strong, nonatomic) NSDate *date;
@property (readonly, nonatomic) TADepartAtOrArriveBy departAtOrArriveBy;

- (id)initWithDate:(NSDate *)date departAtOrArriveBy:(TADepartAtOrArriveBy)departAtOrArriveBy;

@end
