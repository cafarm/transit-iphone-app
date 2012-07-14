//
//  TAConnection.h
//  Transit
//
//  Created by Mark Cafaro on 7/13/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (copy, nonatomic) NSURLRequest *request;
@property (copy, nonatomic) void (^completionBlock)(id obj, NSError *error);
@property (strong, nonatomic) id<NSXMLParserDelegate> xmlRootObject;

- (id)initWithRequest:(NSURLRequest *)request;

- (void)start;

@end
