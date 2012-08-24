//
//  TATransitStepView.h
//  Transit
//
//  Created by Mark Cafaro on 8/21/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStepView.h"

@interface TATransitStepView : TAStepView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
