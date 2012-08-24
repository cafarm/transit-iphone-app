//
//  TATransitStepView.m
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TATransitStepView.h"

static NSInteger const kNumberOfLinesMin = 1;
static NSInteger const kNumberOfLinesMax = 3;

@implementation TATransitStepView

@synthesize view = _view;
@synthesize routeLabel = _routeLabel;
@synthesize detailsLabel = _detailsLabel;
@synthesize dateLabel = _dateLabel;
@synthesize imageView = _imageView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectMake(0, 0, 268, 123) reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"TATransitStepView" owner:self options:nil];
        self.view.frame = self.bounds;
        [self addSubview:self.view];
        [self addLabelShadows];
    }
    return self;
}

- (NSUInteger)minNumberOfDetailLines
{
    return 1;
}

- (NSUInteger)maxNumberOfDetailLines
{
    return 3;
}

- (void)positionImageViewForNumberOfLines:(NSUInteger)numberOfLines
{
    CGFloat imageY;
    if (numberOfLines <= 1) {
        imageY = 21;
    } else if (numberOfLines == 2) {
        imageY = 24;
    } else {
        imageY = 35;
    }
    CGPoint imageOrigin = self.imageView.frame.origin;
    CGSize imageSize = self.imageView.frame.size;
    self.imageView.frame = CGRectMake(imageOrigin.x, imageY, imageSize.height, imageSize.width);
}

@end
