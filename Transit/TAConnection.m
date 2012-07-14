//
//  TAConnection.m
//  Transit
//
//  Created by Mark Cafaro on 7/13/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "TAConnection.h"

static NSMutableArray *_sharedConnectionList = nil;

@interface TAConnection ()
{
    NSURLConnection *_connection;
    NSMutableData *_container;
}

@end

@implementation TAConnection

@synthesize request=_request;
@synthesize completionBlock=_completionBlock;
@synthesize xmlRootObject=_xmlRootObject;

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}

- (void)start
{
    _container = [[NSMutableData alloc] init];
    
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
    
    if (!_sharedConnectionList) {
        _sharedConnectionList = [[NSMutableArray alloc] init];
    }
    
    // Add connection to the array so it doesn't get destroyed
    [_sharedConnectionList addObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.xmlRootObject) {
        // Create a parser with the incoming data and let the root object parse its content
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_container];
        [parser setDelegate:self.xmlRootObject];
        [parser parse];
    }
    
    // Pass the root object to the completion block
    if (self.completionBlock) {
        self.completionBlock(_xmlRootObject, nil);
    }
    
    [_sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
    
    [_sharedConnectionList removeObject:self];
}

@end
