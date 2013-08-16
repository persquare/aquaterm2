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
    return [self initWithColormapSize:1]; // Black
}

-(id)initWithColormapSize:(int32_t)mapsize
{
    if (self = [super init])
    {
        size = (mapsize < 1)?1:mapsize;        
        colormap = [NSMutableArray array];
        colormap[0] = [[AQTColor alloc] init];
    }
    return self;
}

-(int32_t)size
{
    return size;
}

-(void)setColor:(AQTColor *)newColor forIndex:(int32_t)index
{
    if (index >= 0 && index < size)
    {
        colormap[index] = newColor;
    }
}

-(AQTColor *)colorForIndex:(int32_t)index
{
    if (index < 0 || index >= size)
    {
        return colormap[0];
    }
    else
    {
        return colormap[index];
    }
}
@end
