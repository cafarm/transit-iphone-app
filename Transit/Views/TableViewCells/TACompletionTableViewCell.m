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
#import "TALocationField.h"
#import "UIColor+Transit.h"

@interface TACompletionTableViewCell ()
    @property (nonatomic) TACompletionTableViewCellStyle style;
@end


@implementation TACompletionTableViewCell

@synthesize textLabelText = _textLabelText;
@synthesize detailTextLabelText = _detailTextLabelText;

@synthesize style = _style;

- (id)initWithStyle:(TACompletionTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:17];
        
        switch (style) {
            case TACompletionTableViewCellStyleTripPlan:
                self.detailTextLabel.font = self.textLabel.font;
                self.detailTextLabel.textColor = self.textLabel.textColor;
                break;
            case TACompletionTableViewCellStyleCurrentLocation:
                self.textLabel.textColor = [UIColor currentLocationColor];
            case TACompletionTableViewCellStylePlace:
                self.detailTextLabel.font = [UIFont systemFontOfSize:14];
                break;
            case TACompletionTableViewCellStyleAttribution:
                
                break;
            default:
                break;
        }
        
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
    CGRect textFrame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(textFrame.origin.x - 3, textFrame.origin.y, textFrame.size.width, textFrame.size.height);
    
    CGRect detailFrame = self.detailTextLabel.frame;
    self.detailTextLabel.frame = CGRectMake(detailFrame.origin.x - 3, detailFrame.origin.y - 1, detailFrame.size.width, detailFrame.size.height);
}

- (void)setTextLabelText:(NSString *)textLabelText
{
//    switch (self.style) {
//        case TACompletionTableViewCellStyleCurrentLocation:
//            self.textLabel.textColor = [UIColor currentLocationColor];
//            break;
//        case TACompletionTableViewCellStyleTripPlan:
//            
//            break;
//        case TACompletionTableViewCellStylePlace:
//            
//            break;
//        case TACompletionTableViewCellStyleAttribution:
//
//            break;
//        default:
//            break;
//    }
    self.textLabel.text = textLabelText;
}

- (NSString *)textLabelText
{
    return self.textLabel.text;
}

- (void)setDetailTextLabelText:(NSString *)detailTextLabelText
{
//    switch (self.style) {
//        case TACompletionTableViewCellStyleCurrentLocation:
//            self.detailTextLabel.textColor = [UIColor currentLocationColor];
//            break;
//        case TACompletionTableViewCellStyleTripPlan:
//            
//            break;
//        case TACompletionTableViewCellStylePlace:
//            
//            break;
//        case TACompletionTableViewCellStyleAttribution:
//            
//            break;
//        default:
//            break;
//    }
    self.detailTextLabel.text = detailTextLabelText;
}

- (NSString *)detailTextLabelText
{
    return self.detailTextLabel.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
