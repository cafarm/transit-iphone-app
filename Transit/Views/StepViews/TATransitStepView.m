//
//  TATransitStepView.m
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TATransitStepView.h"

@implementation TATransitStepView

@synthesize view = _view;
@synthesize mainLabel = _routeLabel;
@synthesize detailsLabel = _detailsLabel;
@synthesize dateLabel = _dateLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    [[NSBundle mainBundle] loadNibNamed:@"TATransitStepView" owner:self options:nil];
    self = [super initWithReuseIdentifier:reuseIdentifier];
    return self;
}

@end
