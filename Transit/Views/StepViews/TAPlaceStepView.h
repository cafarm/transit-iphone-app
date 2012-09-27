//
//  TAPlaceStepView.h
//  Transit
//
//  Created by Mark Cafaro on 9/26/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAStepView.h"

@interface TAPlaceStepView : TAStepView

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end
