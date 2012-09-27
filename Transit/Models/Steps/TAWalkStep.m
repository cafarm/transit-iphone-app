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
    // Steps only exist for walking from somewhere
    return ((OTPLeg *)[self.legs objectAtIndex:0]).from;
}

- (NSString *)mainDescription
{
    return [NSString stringWithFormat:@"Walk to %@", ((OTPLeg *)[self.legs lastObject]).to.name];
}

@end
