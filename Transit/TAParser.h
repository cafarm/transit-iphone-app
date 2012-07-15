//
//  TAParser.h
//  Transit
//
//  Created by Mark Cafaro on 7/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTHTMLParser.h"

@interface TAParser : NSObject <DTHTMLParserDelegate>

@property (weak, nonatomic) id parentParserDelegate;

@end
