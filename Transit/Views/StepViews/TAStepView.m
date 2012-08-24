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
@synthesize detailsLabel = _detailsLabel;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (void)prepareForReuse;
{
	// Reset modified properties
	self.transform = CGAffineTransformIdentity;
}

- (void)layoutSubviews {
    // Collect the min and max number of lines from the subclass
    NSUInteger minNumberOfLines = [self minNumberOfDetailLines];
    NSUInteger maxNumberOfLines = [self maxNumberOfDetailLines];
    
    NSInteger currentNumberOfLines = self.detailsLabel.numberOfLines;
    
    // Calculate the new number of lines required to display the text in the details label
    NSDictionary *attributes = [self.detailsLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    CGSize constrainedSize = CGSizeMake(self.detailsLabel.frame.size.width, font.lineHeight * maxNumberOfLines);
    CGSize newTextSize = [self.detailsLabel.text sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
    NSInteger newNumberOfLines = newTextSize.height / font.lineHeight;
    self.detailsLabel.numberOfLines = newNumberOfLines;
    
    // Calculate the new label frame height
    NSParagraphStyle *paragraphStyle = [attributes objectForKey:NSParagraphStyleAttributeName];
    CGFloat attributedLineHeight = font.lineHeight * paragraphStyle.lineHeightMultiple;
    CGRect newLabelFrame = CGRectMake(self.detailsLabel.frame.origin.x, self.detailsLabel.frame.origin.y, self.detailsLabel.frame.size.width, ceil(newNumberOfLines * attributedLineHeight));
    self.detailsLabel.frame = newLabelFrame;
    
    // Resize the overall frame to fit the new label, but don't make it too small
    NSInteger numberOfLinesDelta = (currentNumberOfLines >= minNumberOfLines ? currentNumberOfLines : minNumberOfLines) - (newNumberOfLines >= minNumberOfLines ? newNumberOfLines : minNumberOfLines);
    NSInteger frameHeightDelta = numberOfLinesDelta * attributedLineHeight;
    frameHeightDelta = numberOfLinesDelta >= 0 ? ceil(frameHeightDelta) : floor(frameHeightDelta);
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - frameHeightDelta);
    self.frame = newFrame;
    
    // Resize the CALayers
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.shadowPath = path.CGPath;
    self.maskLayer.frame = self.bounds;
    
    // Move the image to best fit the new frame
    [self positionImageViewForNumberOfLines:newNumberOfLines];
}

- (void)addLabelShadows
{
    // Add drop shadows to all labels
    NSShadow *textDropShadow = [[NSShadow alloc] init];
    textDropShadow.shadowBlurRadius = 2;
    textDropShadow.shadowColor = [UIColor blackColor];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)view;
            
            NSAttributedString *text = label.attributedText;
            NSDictionary *attributes = [text attributesAtIndex:0 effectiveRange:NULL];
            NSMutableDictionary *attributesMutable = [NSMutableDictionary dictionaryWithDictionary:attributes];
            [attributesMutable setObject:textDropShadow forKey:NSShadowAttributeName];
            label.attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:attributesMutable];
        }
    }
}

- (NSUInteger)minNumberOfDetailLines
{
    // Override
    return 0;
}

- (NSUInteger)maxNumberOfDetailsLines
{
    // Override
    return 0;
}

- (void)positionImageViewForNumberOfLines:(NSUInteger)numberOfLines
{
    // Override
}

@end
