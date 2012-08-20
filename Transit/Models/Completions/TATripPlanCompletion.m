//
//  TATripPlanCompletion.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATripPlanCompletion.h"
#import "TAPlacemark.h"

@implementation TATripPlanCompletion

@synthesize from = _from;
@synthesize to = _to;

- (id)initWithFrom:(TAPlacemark *)from to:(TAPlacemark *)to
{
    self = [super init];
    if (self) {
        _from = from;
        _to = to;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithFrom:[aDecoder decodeObjectForKey:@"from"] to:[aDecoder decodeObjectForKey:@"to"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.from forKey:@"from"];
    [aCoder encodeObject:self.to forKey:@"to"];
}

@end
