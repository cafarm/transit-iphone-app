//
//  TALocationCompletionTableViewCell.m
//  Transit
//
//  Created by Mark Cafaro on 8/16/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TALocationCompletionTableViewCell.h"
#import "TACompletion.h"

@implementation TALocationCompletionTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
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
