//
//  TALocationField.m
//  Transit
//
//  Created by Mark Cafaro on 8/2/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationField.h"

@implementation TALocationField

@synthesize leftViewText = _leftViewText;

@synthesize isCurrentLocation = _isCurrentLocation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setLeftViewText:(NSString *)leftViewText
{
    self.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, 45, 31)];
    label.font = self.font;
    label.textAlignment = UITextAlignmentRight;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = leftViewText;
    
    // A view to shift the label up to align with text field input
    UIView *view = [[UIView alloc] init];
    view.frame = label.frame;
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    self.leftView = view;
    
    _leftViewText = leftViewText;
}

- (void)setIsCurrentLocation:(BOOL)isCurrentLocation
{
    if (isCurrentLocation) {
        self.text = @"Current Location";
    } else {
        self.text = @"";
    }
    
    _isCurrentLocation = isCurrentLocation;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
