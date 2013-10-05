//
//  AQTGraphic.m
//  AquaTerm
//
//  Created by ppe on Wed May 16 2001.
//  Copyright (c) 2001-2012 The AquaTerm Team. All rights reserved.
//

#import "AQTGraphic.h"

static NSString *AQTColorKey = @"AQTColorKey";
static NSString *AQTBoundsKey = @"AQTBoundsKey";
static NSString *AQTClipRectKey = @"AQTClipRectKey";
static NSString *AQTClippedKey = @"AQTClippedKey";


@implementation AQTGraphic

- (id)replacementObjectForPortCoder:(NSPortCoder *)portCoder
{
    return [portCoder isBycopy]?self:[super replacementObjectForPortCoder:portCoder];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_color forKey:AQTColorKey];
    [coder encodeRect:_bounds forKey:AQTBoundsKey];
    [coder encodeRect:_clipRect forKey:AQTClipRectKey];
    [coder encodeBool:_clipped forKey:AQTClippedKey];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _color = [coder decodeObjectForKey:AQTColorKey];
        _bounds = [coder decodeRectForKey:AQTBoundsKey];
        _clipRect = [coder decodeRectForKey:AQTClipRectKey];
        _clipped = [coder decodeBoolForKey:AQTClippedKey];
    }
    return self;
}

-(NSRect)updateBounds
{
    // Default is to do nothing.
    return self.bounds;
}

-(NSRect)clippedBounds
{
    if (self.clipped) {
        return NSIntersectionRect(self.bounds, self.clipRect);
    }
    return self.bounds;
}
@end
