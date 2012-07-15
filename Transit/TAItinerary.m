//
//  TAItinerary.m
//  Transit
//
//  Created by Mark Cafaro on 7/10/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAItinerary.h"
#import "TAWalkLeg.h"
#import "TATransitLeg.h"

@interface TAItinerary ()
{
    NSMutableString *_currentElementString;
}

@end

@implementation TAItinerary

- (void)parser:(DTHTMLParser *)parser foundComment:(NSString *)comment
{
    DLog(@"\t%@ found comment: %@", self, comment);
    
    if ([comment hasPrefix:@" End Fare Breakdown for Itinerary "]) {
        [parser setDelegate:self.parentParserDelegate];
    }
}

- (void)parser:(DTHTMLParser *)parser
    didStartElement:(NSString *)elementName
         attributes:(NSDictionary *)attributeDict
{
//    DLog(@"\t%@ found element: %@", self, elementName);
    
    if ([elementName isEqualToString:@"td"]) {
        _currentElementString = [[NSMutableString alloc] init];
    }
}

- (void)parser:(DTHTMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentElementString appendString:string];
}

- (void)parser:(DTHTMLParser *)parser
 didEndElement:(NSString *)elementName
{
    if ([elementName isEqualToString:@"td"]) {
        
        if ([_currentElementString hasPrefix:@" Walk"]) {
            DLog(@"Found walk leg: %@", _currentElementString);
            
            TAWalkLeg *walkLeg = [[TAWalkLeg alloc] initWithElementString:_currentElementString];
            [self.legs addObject:walkLeg];
            
            DLog(@"Added walk leg: %@", walkLeg);
        } else if ([_currentElementString isEqualToString:@"Depart"]) {
            DLog(@"Found transit leg: %@", _currentElementString);
            
            TATransitLeg *transitLeg = [[TATransitLeg alloc] init];
            transitLeg.parentParserDelegate = self;
            [self.legs addObject:transitLeg];
            
            [parser setDelegate:transitLeg];
        }
        
        _currentElementString = nil;
    }
}

@end
