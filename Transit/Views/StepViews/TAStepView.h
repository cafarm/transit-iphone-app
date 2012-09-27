//
//  TAStepView.h
//  Transit
//
//  Created by Mark Cafaro on 8/3/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAStepView : UIView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (readwrite, copy, nonatomic) NSString *reuseIdentifier;
@property (strong, nonatomic) CALayer *maskLayer;
@property (weak, nonatomic) UIView *view;

- (void)addLabelShadows;
- (void)prepareForReuse;

@end
