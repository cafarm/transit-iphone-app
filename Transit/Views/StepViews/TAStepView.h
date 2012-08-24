//
//  TAStepView.h
//  Transit
//
//  Created by Mark Cafaro on 8/3/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAStepView : UIView

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@property (readwrite, copy, nonatomic) NSString *reuseIdentifier;
@property (strong, nonatomic) CALayer *maskLayer;
@property (weak, nonatomic) UIView *view;
@property (weak, nonatomic) UILabel *detailsLabel;
@property (weak, nonatomic) UIImageView *imageView;

@property (nonatomic) NSUInteger minNumberOfDetailLines;
@property (nonatomic) NSUInteger maxNumberOfDetailLines;

- (void)addLabelShadows;
- (void)prepareForReuse;
- (void)positionImageViewForNumberOfLines:(NSUInteger)numberOfLines;

@end
