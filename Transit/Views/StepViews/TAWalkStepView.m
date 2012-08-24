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
@synthesize detailsLabel = _detailsLabel;
@synthesize distanceLabel = _distanceLabel;
@synthesize imageView = _imageView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectMake(0, 0, 268, 114) reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"TAWalkStepView" owner:self options:nil];
        self.view.frame = self.bounds;
        [self addSubview:self.view];
    }
    return self;
}

- (NSUInteger)minNumberOfDetailLines
{
    return 2;
}

- (NSUInteger)maxNumberOfDetailLines
{
    return 4;
}

- (void)positionImageViewForNumberOfLines:(NSUInteger)numberOfLines
{
    CGFloat imageY;
    if (numberOfLines <= 3) {
        imageY = 21;
    } else {
        imageY = 30;
    }
    CGPoint imageOrigin = self.imageView.frame.origin;
    CGSize imageSize = self.imageView.frame.size;
    self.imageView.frame = CGRectMake(imageOrigin.x, imageY, imageSize.height, imageSize.width);
}

@end
