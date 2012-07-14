//
//  TAHTMLParser.h
//  Transit
//
//  Created by Mark Cafaro on 7/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TAHTMLParserDelegate;

@interface TAHTMLParser : NSObject

@property (weak, nonatomic) id<TAHTMLParserDelegate> delegate;

- (id)initWithData:(NSData *)data;
- (BOOL)parse;

@end

@protocol TAHTMLParserDelegate <NSObject>

@optional

- (void)parserDidStartDocument:(TAHTMLParser *)parser;
- (void)parserDidEndDocument:(TAHTMLParser *)parser;

@end