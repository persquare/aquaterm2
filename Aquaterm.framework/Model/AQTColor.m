//
//  AQTColor.m
//  Aquaterm2
//
//  Created by Per Persson on 13-08-09.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import "AQTColor.h"

static NSString *AQTRedComponentKey  = @"AQTRedComponentKey";
static NSString *AQTGreenComponentKey = @"AQTGreenComponentKey";
static NSString *AQTBlueComponentKey = @"AQTBlueComponentKey";
static NSString *AQTAlphaComponentKey = @"AQTAlphaComponentKey";

@implementation AQTColor

- (id)initWithRed:(float)r green:(float)g blue:(float)b alpha:(float)a
{
    self = [super init];
    if (self) {
        _red = r;
        _green = g;
        _blue = b;
        _alpha = a;
    }
    return self;    
}

- (id)initWithRed:(float)r green:(float)g blue:(float)b
{
    return [self initWithRed:r green:g blue:b alpha:1.0];
}

- (id)init
{
    return [self initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
}

- (id)replacementObjectForPortCoder:(NSPortCoder *)portCoder
{
    return [portCoder isBycopy]?self:[super replacementObjectForPortCoder:portCoder];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeFloat:_red forKey:AQTRedComponentKey];
    [coder encodeFloat:_green forKey:AQTGreenComponentKey];
    [coder encodeFloat:_blue forKey:AQTBlueComponentKey];
    [coder encodeFloat:_alpha forKey:AQTAlphaComponentKey];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _red = [coder decodeFloatForKey:AQTRedComponentKey];
        _green = [coder decodeFloatForKey:AQTGreenComponentKey];
        _blue = [coder decodeFloatForKey:AQTBlueComponentKey];
        _alpha = [coder decodeFloatForKey:AQTAlphaComponentKey];
    }
    return self;
}

- (BOOL)isEqualToColor:(AQTColor *)color
{
    float EPS = 1.0f/256.0f; // Assume 32bit RGBA
    BOOL equal = fabsf(_red - color.red) < EPS
    && fabsf(_green - color.green) < EPS
    && fabsf(_blue - color.blue) < EPS
    && fabsf(_alpha - color.alpha) < EPS;
    
    return equal;
}
@end
