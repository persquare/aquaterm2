//
//  AQTColorMap.h
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002-2012 The AquaTerm Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTColor.h"

@interface AQTColorMap : NSObject	

@property NSMutableArray *colormap;

- (id)initWithSize:(NSUInteger)size;
- (NSUInteger)size;
- (AQTColor *)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(AQTColor *)color atIndexedSubscript:(NSUInteger)index;
@end
