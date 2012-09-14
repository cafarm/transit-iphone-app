//
//  TAPredictionCompletion.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAPredictionCompletion.h"
#import "GPAutocompletePrediction.h"
#import "GPAutocompleteTerm.h"

@implementation TAPredictionCompletion

@synthesize reference = _reference;

+ (TACompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction
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
    
    return [[TAPredictionCompletion alloc] initWithText:text detailText:detailText reference:prediction.reference];
}

- (id)initWithText:(NSString *)text detailText:(NSString *)detailText reference:(NSString *)reference
{
    self = [super initWithText:text detailText:detailText];
    if (self) {
        _reference = reference;
    }
    return self;
}

@end
