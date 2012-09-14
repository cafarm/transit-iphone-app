//
//  TALocationCompletion.m
//  Transit
//
//  Created by Mark Cafaro on 8/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACompletion.h"
#import "GPAutocompletePrediction.h"
#import "GPAutocompleteTerm.h"

@implementation TACompletion

@synthesize type = _type;
@synthesize text = _text;
@synthesize detailText = _detailText;

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
    
    return [[TACompletion alloc] initWithType:TACompletionTypeLocation text:text detailText:detailText];
}

+ (TACompletion *)googleLogo
{
    return [[TACompletion alloc] initWithType:TACompletionTypeGoogleLogo text:@"" detailText:@""];
}

- (id)initWithType:(TACompletionType)type text:(NSString *)text detailText:(NSString *)detailText
{
    self = [super init];
    if (self) {
        _type = type;
        _text = text;
        _detailText = detailText;
    }
    return self;
}

@end
