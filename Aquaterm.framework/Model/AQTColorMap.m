//
//  AQTColorMap.m
//  AquaTerm
//
//  Created by Bob Savage on Mon Jan 28 2002.
//  Copyright (c) 2002-2012 The AquaTerm Team. All rights reserved.
//

#import "AQTColorMap.h"

@implementation AQTColorMap
-(id)init
{
    return [self initWithSize:1]; // Black
}

-(id)initWithSize:(NSUInteger)mapsize
{
    self = [super init];
    if (self) {
        NSUInteger size = (mapsize < 1)?1:mapsize;        
        _colormap = [NSMutableArray arrayWithCapacity:size];
        self[size-1] = [[AQTColor alloc] init];        
    }
    return self;
}

- (NSString *)description
{
    return [_colormap description];
}

-(NSUInteger)size
{
    return _colormap.count;
}

- (AQTColor *)objectAtIndexedSubscript:(NSUInteger)index
{
    return _colormap[index % _colormap.count];
}

- (void)setObject:(AQTColor *)color atIndexedSubscript:(NSUInteger)index
{
    // Add entry, pad if necessary
    NSUInteger start = (index < _colormap.count)?index:_colormap.count;

    for (NSUInteger i=start; i<=index; i++) {
        _colormap[i] = color;
    }
}
@end
