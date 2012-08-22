//
//  TAWalkStepView.h
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStepView.h"

@interface TAWalkStepView : TAStepView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (strong, nonatomic) IBOutlet UIView *view;

@end
