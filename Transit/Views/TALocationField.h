//
//  TALocationField.h
//  Transit
//
//  Created by Mark Cafaro on 8/2/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TALocationField : UITextField

@property (strong, nonatomic) NSString *leftViewText;

@property (nonatomic) BOOL isCurrentLocation;

@end
