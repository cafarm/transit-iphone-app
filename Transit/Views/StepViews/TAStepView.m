//
//  TAStepView.m
//  Transit
//
//  Created by Mark Cafaro on 8/3/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TAStepView.h"

@implementation TAStepView

@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize maskLayer = _maskLayer;
@synthesize view = _view;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 78)];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
        self.view.frame = self.bounds;
        [self addSubview:self.view];
        [self addLabelShadows];
    }
    return self;
}

- (void)prepareForReuse;
{
	// Reset modified properties
	self.transform = CGAffineTransformIdentity;
}

- (void)addLabelShadows
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)view;
            label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            label.shadowOffset = CGSizeMake(0, -1);
        }
    }
}

@end
