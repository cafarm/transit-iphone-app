//
//  TALocationInputViewController.h
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAItineraryStoreDelegate.h"

@interface TALocationInputViewController : UIViewController <UITextFieldDelegate, TAItineraryStoreDelegate>

- (IBAction)swapStartAndEndFields;
- (void)routeMapOverview;

@end
