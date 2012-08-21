//
//  UITableViewCell+Transit.m
//  Transit
//
//  Created by Mark Cafaro on 8/20/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "UITableViewCell+Transit.h"
#import "TAPlacemark.h"
#import "TACurrentLocationCompletion.h"
#import "TATripPlanCompletion.h"
#import "TAPlaceCompletion.h"
#import "TAAttributionCompletion.h"
#import "TALocationField.h"
#import "UIColor+Transit.h"
#import "GPClient.h"

@implementation UITableViewCell (Transit)

+ (void)styleCurrentLocationCompletionCell:(UITableViewCell *)cell withCompletion:(TACurrentLocationCompletion *)completion
{
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = TALocationFieldCurrentLocationText;
    label.textColor = [UIColor currentLocationColor];
}

+ (void)styleTripPlanCompletionCell:(UITableViewCell *)cell withCompletion:(TATripPlanCompletion *)completion
{
    // From name label
    [UITableViewCell formatTripPlanNameLabel:(UILabel *)[cell viewWithTag:1] withPlacemark:completion.from];
    // From locality label
    [UITableViewCell formatTripPlanLocalityLabel:(UILabel *)[cell viewWithTag:2] withNameLabel:(UILabel *)[cell viewWithTag:1] Placemark:completion.from];
    // To name label
    [UITableViewCell formatTripPlanNameLabel:(UILabel *)[cell viewWithTag:3] withPlacemark:completion.to];
    // To locality label
    [UITableViewCell formatTripPlanLocalityLabel:(UILabel *)[cell viewWithTag:4] withNameLabel:(UILabel *)[cell viewWithTag:3] Placemark:completion.to];
}

+ (void)formatTripPlanNameLabel:(UILabel *)label withPlacemark:(TAPlacemark *)placemark
{
    // Size the label to fit the text
    CGSize constrainedSize = CGSizeMake(300 - label.frame.origin.x, label.frame.size.height);
    CGSize textSize = [placemark.name sizeWithFont:label.font constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, textSize.width, label.frame.size.height);
    label.text = placemark.name;
    
    if (placemark.isCurrentLocation) {
        label.textColor = [UIColor currentLocationColor];
    } else {
        label.textColor = [UIColor blackColor];
    }
}

+ (void)formatTripPlanLocalityLabel:(UILabel *)label withNameLabel:(UILabel *)nameLabel Placemark:(TAPlacemark *)placemark
{
    // Only add locality to establishments
    if ([placemark.types containsObject:[NSNumber numberWithInt:GPDetailsResultTypeEstablishment]]) {
        CGFloat labelX = nameLabel.frame.origin.x + nameLabel.frame.size.width + 5;
        CGFloat remainingSpace = 300 - labelX;
        
        if (remainingSpace > 0) {
            label.frame = CGRectMake(labelX, label.frame.origin.y, remainingSpace, label.frame.size.height);
            label.text = [NSString stringWithFormat:@"(%@)", placemark.locality];
        } else {
            label.text = nil;
        }
        
    } else {
        label.text = nil;
    }
}

+ (void)stylePlaceCompletionCell:(UITableViewCell *)cell withCompletion:(TAPlaceCompletion *)completion
{
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = completion.mainTerm;
    
    UILabel *detailsLabel = (UILabel *)[cell viewWithTag:2];
    detailsLabel.text = completion.subTerms;
}

+ (void)styleAttributionCompletionCell:(UITableViewCell *)cell withCompletion:(TAAttributionCompletion *)completion
{
    // We don't have to do anything here at the moment because we only have one attribution, Google
}

@end
