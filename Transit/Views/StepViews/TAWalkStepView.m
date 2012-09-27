//
//  TAWalkStepView.m
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TAWalkStepView.h"

@implementation TAWalkStepView

@synthesize view = _view;
@synthesize mainLabel = _detailsLabel;
@synthesize distanceLabel = _distanceLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    [[NSBundle mainBundle] loadNibNamed:@"TAWalkStepView" owner:self options:nil];
    self = [super initWithReuseIdentifier:reuseIdentifier];
    return self;
}

@end
