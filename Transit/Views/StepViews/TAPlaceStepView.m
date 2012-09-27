//
//  TAPlaceStepView.m
//  Transit
//
//  Created by Mark Cafaro on 9/26/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAPlaceStepView.h"

@implementation TAPlaceStepView

@synthesize view = _view;
@synthesize mainLabel = _mainLabel;
@synthesize detailsLabel = _detailsLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    [[NSBundle mainBundle] loadNibNamed:@"TAPlaceStepView" owner:self options:nil];
    self = [super initWithReuseIdentifier:reuseIdentifier];
    return self;
}

@end
