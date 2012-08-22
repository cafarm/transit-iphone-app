//
//  TAWalkStep.m
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAWalkStep.h"

@implementation TAWalkStep

- (OTPPlace *)place
{
    // Steps only exist for walking from somewhere, except in the case of the last step
    if (self.isDestination) {
        return self.to;
    } else {
        return self.from;
    }
}

@end
