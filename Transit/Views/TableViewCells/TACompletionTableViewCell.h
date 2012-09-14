//
//  TALocationCompletionTableViewCell.h
//  Transit
//
//  Created by Mark Cafaro on 8/16/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TACompletion.h"

typedef enum {
    TACompletionTableViewCellStyleCurrentLocation,
    TACompletionTableViewCellStyleTripPlan,
    TACompletionTableViewCellStylePlace,
    TACompletionTableViewCellStyleAttribution
} TACompletionTableViewCellStyle;

@interface TACompletionTableViewCell : UITableViewCell

- (id)initWithStyle:(TACompletionTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic) NSString *textLabelText;
@property (nonatomic) NSString *detailTextLabelText;

@end
