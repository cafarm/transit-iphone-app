//
//  UIColor+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 8/18/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "UIColor+Transit.h"

#define RGB(a) a / 255.0

@implementation UIColor (Transit)

+ (UIColor *)currentLocationColor
{
    return [UIColor colorWithRed:RGB(41) green:RGB(87) blue:RGB(255) alpha:1.0];
}

@end
