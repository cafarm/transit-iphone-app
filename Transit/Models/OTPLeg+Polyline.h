//
//  OTPLeg+Polyline.h
//  Transit
//
//  Created by Mark Cafaro on 7/29/12.
//  Copyright (c) 2012 Seven O' Eight. All rights reserved.
//

#import "OTPLeg.h"

@class MKPolyline;

@interface OTPLeg (Polyline)

- (MKPolyline *)legPolyline;

@end
