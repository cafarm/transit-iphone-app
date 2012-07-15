//
//  TATransitLeg.m
//  Transit
//
//  Created by Mark Cafaro on 7/14/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TATransitLeg.h"

@interface TATransitLeg()
{
    char _currentCellCount;
    char _currentRowCount;
    NSMutableString *_currentElementString;
}

@end

@implementation TATransitLeg

@synthesize tripID=_tripID;
@synthesize routeID=_routeID;
@synthesize serviceDate=_serviceDate;
@synthesize fromStopID=_fromStopID;
@synthesize toStopID=_toStopID;
@synthesize path=_path;
@synthesize scheduledDepartureTime=_scheduledDepartureTime;
@synthesize predictedDepartureTime=_predictedDepartureTime;
@synthesize scheduledArrivalTime=_scheduledArrivalTime;
@synthesize predictedArrivalTime=_predictedArrivalTime;

- (id)init
{
    self = [super init];
    if (self) {
        // assumed to be in the first row and cell on init
        _currentCellCount = 1;
        _currentRowCount = 1;
        
        _currentElementString = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)parser:(DTHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"td"]) {
        _currentCellCount++;
        _currentElementString = [[NSMutableString alloc] init];
    } else if ([elementName isEqualToString:@"tr"]) {
        _currentCellCount = 0;
        _currentRowCount++;
    }
}

- (void)parser:(DTHTMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentElementString appendString:string];
}

- (void)parser:(DTHTMLParser *)parser didEndElement:(NSString *)elementName
{
    if ([elementName isEqualToString:@"td"]) {
        
        if (_currentRowCount == 1) {
            switch (_currentCellCount) {
                case 1:
                    // nothing
                    break;
                case 2:
                    // fromStopID
                    DLog(@"Found from stop: %@", _currentElementString);
                    break;
                case 3:
                    // scheduledDepartureTime
                    DLog(@"Found scheduled departure time: %@", _currentElementString);
                    break;
                case 4:
                    // routeID
                    DLog(@"Found route id: %@", _currentElementString);
                    break;
            }
        } else {
            switch (_currentCellCount) {
                case 1:
                    // nothing
                    break;
                case 2:
                    // toStopID
                    DLog(@"Found to stop: %@", _currentElementString);
                    break;
                case 3:
                    // scheduledArrivalTime
                    DLog(@"Found scheduled arrival time: %@", _currentElementString);
                    break;
                case 4:
                    // nothing
                    break;
            }
        }
        
        _currentElementString = nil;
        
    } else if ([elementName isEqualToString:@"tr"]) {
        
        if (_currentRowCount >= 2) {
            [parser setDelegate:self.parentParserDelegate];
            
            DLog(@"Added transit leg: %@", self);
        }
    }
}

@end
