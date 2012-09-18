//
//  NSDateFormatter+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 9/16/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "NSDateFormatter+Transit.h"

@implementation NSDateFormatter (Transit)

- (NSString *)stringFromTravelDate:(NSDate *)date
{
    // Store current formatting properties
    BOOL doesRelativeDateFormatting = self.doesRelativeDateFormatting;
    NSDateFormatterStyle dateStyle = self.dateStyle;
    NSDateFormatterStyle timeStyle = self.timeStyle;
    
    self.doesRelativeDateFormatting = YES;
    self.dateStyle = NSDateFormatterMediumStyle;
    self.timeStyle = NSDateFormatterNoStyle;
    NSString *dateString = [self stringFromDate:date];
    
    if ([dateString isEqualToString:@"Yesterday"]
        || [dateString isEqualToString:@"Today"]
        || [dateString isEqualToString:@"Tomorrow"]) {
        
        dateString = [dateString stringByAppendingString:@" at "];
    } else {
        dateString = [dateString stringByAppendingString:@" "];
    }
    
    self.dateStyle = NSDateFormatterNoStyle;
    self.timeStyle = NSDateFormatterShortStyle;
    dateString = [dateString stringByAppendingString:[self stringFromDate:date]];
    
    // Restore formatting properties
    self.doesRelativeDateFormatting = doesRelativeDateFormatting;
    self.dateStyle = dateStyle;
    self.timeStyle = timeStyle;
    
    return dateString;
}

@end
