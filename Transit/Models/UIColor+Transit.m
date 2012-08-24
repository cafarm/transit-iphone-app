//
//  UIColor+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 8/18/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "UIColor+Transit.h"

@implementation UIColor (Transit)

+ (UIColor *)currentLocationColor
{
    return [UIColor colorWithRed:41.0/255.0 green:87.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (UIColor *)lightBackgroundColor
{
    return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
}

@end
