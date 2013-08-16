//
//  AQTGraphic.h
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001-2012 The AquaTerm Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AQTColor.h"

@interface AQTGraphic : NSObject <NSCoding>
@property AQTColor *color;
@property NSRect bounds;
@property NSRect clipRect;
@property BOOL clipped;
@property id cache;
@end
