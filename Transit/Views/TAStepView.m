//
//  TAStepView.m
//  Transit
//
//  Created by Mark Cafaro on 8/3/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStepView.h"

@implementation TAStepView

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize maskLayer = _maskLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse;
{
	// Reset modified properties
	self.transform = CGAffineTransformIdentity;
}

@end
