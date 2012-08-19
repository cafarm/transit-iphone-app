//
//  TAPredictionCompletion.m
//  Transit
//
//  Created by Mark Cafaro on 8/17/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAPlaceCompletion.h"
#import "GPAutocompletePrediction.h"
#import "GPAutocompleteTerm.h"

@implementation TAPlaceCompletion

@synthesize mainTerm = _mainTerm;
@synthesize subTerms = _subTerms;
@synthesize reference = _reference;

+ (TACompletion *)completionWithPrediction:(GPAutocompletePrediction *)prediction
{
    NSString *mainTerm = @"";
    NSString *subTerms = @"";
    
    int numTerms = [prediction.terms count];
    for (int i = 0; i < numTerms; i++) {
        GPAutocompleteTerm *term = [prediction.terms objectAtIndex:i];
        if (i == 0) {
            mainTerm = term.value;
        } else {
            subTerms = [subTerms stringByAppendingString:term.value];
            if (i < numTerms - 1) {
                subTerms = [subTerms stringByAppendingString:@", "];
            }
        }
    }
    
    return [[TAPlaceCompletion alloc] initWithMainTerm:mainTerm subTerms:subTerms reference:prediction.reference];
}

- (id)initWithMainTerm:(NSString *)mainTerm subTerms:(NSString *)subTerms reference:(NSString *)reference
{
    self = [super init];
    if (self) {
        _mainTerm = mainTerm;
        _subTerms = subTerms;
        _reference = reference;
    }
    return self;
}

@end
