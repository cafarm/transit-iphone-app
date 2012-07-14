//
//  TATrip.m
//  Transit
//
//  Created by Mark Cafaro on 7/13/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATrip.h"

@interface TATrip ()
{
    __weak id _parentParserDelegate;
    NSMutableString *_currentString;
}

@end

@implementation TATrip

@synthesize itineraries=_itineraries;

- (id)init
{
    self = [super init];
    if (self) {
        _itineraries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qName
         attributes:(NSDictionary *)attributeDict
{
    DLog(@"%@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    DLog(@"%@", comment);
}

@end
