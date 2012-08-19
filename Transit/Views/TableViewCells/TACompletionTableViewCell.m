//
//  TALocationCompletionTableViewCell.m
//  Transit
//
//  Created by Mark Cafaro on 8/16/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TACompletionTableViewCell.h"
#import "TATripPlanCompletion.h"
#import "TAPlaceCompletion.h"
#import "TAAttributionCompletion.h"
#import "UIColor+Transit.h"

@interface TACompletionTableViewCell ()
    @property (nonatomic) TACompletionTableViewCellStyle style;
@end


@implementation TACompletionTableViewCell

@synthesize style = _style;

- (id)initWithStyle:(TACompletionTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        _style = style;
        
        // Force the style layout before displaying
        [self layoutIfNeeded];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.style) {
        case TACompletionTableViewCellStyleCurrentLocation:
            self.textLabel.textColor = [UIColor currentLocationColor];
            break;
        case TACompletionTableViewCellStyleTripPlan:
            
            break;
        case TACompletionTableViewCellStylePlace:
            
            break;
        case TACompletionTableViewCellStyleAttribution:
            self.imageView.frame = CGRectMake(self.frame.size.width - self.imageView.frame.size.width - 15,
                                              self.imageView.frame.origin.y + 1,
                                              self.imageView.frame.size.width,
                                              self.imageView.frame.size.height);
            break;
        default:
            break;
    }
    
    // Details, details, details...
    self.textLabel.font = [UIFont boldSystemFontOfSize:17];
    CGRect textFrame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(textFrame.origin.x - 3, textFrame.origin.y, textFrame.size.width, textFrame.size.height);
    
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    CGRect detailFrame = self.detailTextLabel.frame;
    self.detailTextLabel.frame = CGRectMake(detailFrame.origin.x - 3, detailFrame.origin.y - 1, detailFrame.size.width, detailFrame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
