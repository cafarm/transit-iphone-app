//
//  TALocationCompletion.m
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationCompletion.h"
#import "GPAutocompletePrediction.h"
#import "GPAutocompleteTerm.h"

@implementation TALocationCompletion

@synthesize text = _text;
@synthesize detailText = _detailText;

+ (TALocationCompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction
{
    NSString *text = @"";
    NSString *detailText = @"";
    
    int numTerms = [prediction.terms count];
    for (int i = 0; i < numTerms; i++) {
        GPAutocompleteTerm *term = [prediction.terms objectAtIndex:i];
        if (i == 0) {
            text = term.value;
        } else {
            detailText = [detailText stringByAppendingString:term.value];
            if (i < numTerms - 1) {
                detailText = [detailText stringByAppendingString:@", "];
            }
        }
    }
    
    return [[self alloc] initWithText:text detailText:detailText];
}

- (id)initWithText:(NSString *)text detailText:(NSString *)detailText
{
    self = [super init];
    if (self) {
        _text = text;
        _detailText = detailText;
    }
    return self;
}

@end
