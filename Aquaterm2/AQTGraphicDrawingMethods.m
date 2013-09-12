//
//  AQTGraphicDrawingMethods.m
//  AquaTerm
//
//  Created by Per Persson on Mon Oct 20 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import "AQTGraphicDrawingMethods.h"
#import "AQTGraphic.h"
#import "AQTLabel.h"
#import "AQTPath.h"
#import "AQTImage.h"
// #import "AQTFunctions.h"
#import "AQTStringDrawingAdditions.h"

/* _aqtMinimumLinewidth is used by view to pass user prefs to line drawing routine,
 this is ugly, but I can't see a simple way to do it without affecting performance. */
static float _aqtMinimumLinewidth;

@implementation AQTGraphic (AQTGraphicDrawingMethods)
- (void)setAQTColor
{
    [[NSColor colorWithCalibratedRed:self.color.red
                               green:self.color.green
                                blue:self.color.blue
                               alpha:self.color.alpha] set];
}

// Dirty rect is in canvas coordinates
-(void)renderInRect:(NSRect)dirtyRect
{
    NSLog(@"Error: *** AQTGraphicDrawing ***");
}

-(NSRect)updateBounds
{
    return self.bounds; // Default is to do nothing.
}

-(NSRect)clippedBounds
{
    if (self.clipped) {
        return NSIntersectionRect(self.bounds, self.clipRect);
    }
    return self.bounds;
}

// Debugging methods
-(void)highlightRect:(NSRect)rect color:(NSColor *)color
{
    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
    [ctx saveGraphicsState];
    [color set];
    NSFrameRect(rect);
    [ctx restoreGraphicsState];
}

-(void)highlightBounds
{
    [self highlightRect:self.bounds color:[NSColor yellowColor]];
    if (self.clipped) {
        [self highlightRect:self.clipRect color:[NSColor orangeColor]];
    }
}
@end

/**"
 *** Tell every object in the collection to draw itself.
 "**/
@implementation AQTModel (AQTModelDrawing)
-(NSRect)updateBounds
{
    NSRect tmpRect = NSZeroRect;
    
    _aqtMinimumLinewidth = [[NSUserDefaults standardUserDefaults] floatForKey:@"MinimumLinewidth"];
    
    for (AQTGraphic *graphic in self) {
        tmpRect = NSUnionRect(tmpRect, [graphic updateBounds]);
    }
    [self setBounds:tmpRect];
    return tmpRect;
}

-(void)renderInRect:(NSRect)dirtyRect
{
    // FIXME: Figure out when to trigger.
    if (NSEqualRects(self.bounds, NSZeroRect)) {
        [self updateBounds];
    }
        
    // Model object is responsible for background...
    [self setAQTColor];
    NSRectFill(dirtyRect);
    
    for (AQTGraphic *graphic in _modelObjects) {
        [graphic renderInRect:dirtyRect];
    }
}
@end

@implementation AQTLabel (AQTLabelDrawing)
-(void)updateCache
{
    NSFont *normalFont;
    NSAffineTransform *aTransform = [NSAffineTransform transform];
    NSAffineTransform *shearTransform = [NSAffineTransform transform];
    NSAffineTransformStruct ts;
    NSBezierPath *tmpPath = [NSBezierPath bezierPath];
    NSSize tmpSize;
    NSPoint adjust = NSZeroPoint;
    // Make sure we get a valid font....
    if ((normalFont = [NSFont fontWithName:self.fontName size:self.fontSize]) == nil)
        normalFont = [NSFont systemFontOfSize:self.fontSize]; // Fall back to a system font
    // Convert (attributed) string into a path
    tmpPath = [self.string aqtBezierPathInFont:normalFont]; // Implemented in AQTStringDrawingAdditions
    tmpSize = [tmpPath bounds].size;
    // Place the path according to position, angle and align
    adjust.x = -(float)(self.justification & 0x03)*0.5*tmpSize.width; // hAlign:
    switch (self.justification & 0x1C) { // vAlign:
        case 0x00:// AQTAlignMiddle: // align middle wrt *font size*
            adjust.y = -([normalFont descender] + [normalFont capHeight])*0.5;
            break;
        case 0x08:// AQTAlignBottom: // align bottom wrt *bounding box*
            adjust.y = -[tmpPath bounds].origin.y;
            break;
        case 0x10:// AQTAlignTop: // align top wrt *bounding box*
            adjust.y = -([tmpPath bounds].origin.y + tmpSize.height) ;
            break;
        case 0x04:// AQTAlignBaseline: // align baseline (do nothing)
        default:
            // default to align baseline (do nothing) in case of error
            break;
    }
    // Avoid multiples of 90 degrees (pi/2) since tan(k*pi/2)=inf, set beta to 0.0 instead.
    float beta = (fabs(self.shearAngle - 90.0*roundf(self.shearAngle/90.0))<0.1)?0.0:-self.shearAngle;
    // shearTransform is an identity transform so we can just stuff the shearing into m21...
    ts = [shearTransform transformStruct];
    ts.m21 = -tan(beta*atan(1.0)/45.0); // =-tan(beta*pi/180.0)
    [shearTransform setTransformStruct:ts];
    [tmpPath transformUsingAffineTransform:shearTransform];
    // Now, place the sheared label correctly
    [aTransform translateXBy:self.position.x yBy:self.position.y];
    [aTransform rotateByDegrees:self.angle];
    [aTransform translateXBy:adjust.x yBy:adjust.y];
    [tmpPath transformUsingAffineTransform:aTransform];
    
    [self setCache:tmpPath];
}

-(NSRect)updateBounds
{
    if (!self.cache) {
        [self updateCache];
    }
    NSRect tempBounds = [self.cache bounds];
    [self setBounds:tempBounds];
    return tempBounds;
}

-(void)renderInRect:(NSRect)dirtyRect
{
    if (!NSIntersectsRect(dirtyRect, self.clippedBounds)) {
        return;
    }
    
    [self setAQTColor];
    if (self.clipped) {
        [NSGraphicsContext saveGraphicsState];
        NSRectClip(self.clippedBounds);
    }
    [self.cache fill];
    if (self.clipped)  {
        [NSGraphicsContext restoreGraphicsState];
    }
#ifdef DEBUG_BOUNDS
    [self highlightBounds];
#endif
}
@end

@implementation AQTPath (AQTPathDrawing)
-(void)updateCache
{
    float lw = self.filled?1.0:self.linewidth; // FIXME: this is a hack to avoid tiny gaps between filled patches
    NSBezierPath *scratch = [NSBezierPath bezierPath];
    for (NSValue *v in _path) {
        if (scratch.isEmpty) {
            [scratch moveToPoint:v.pointValue];
        } else {
            [scratch lineToPoint:v.pointValue];
        }
    }
    [scratch setLineJoinStyle:NSRoundLineJoinStyle]; //CM FIXME - This looks like a bug. This explains why join styles don't work in the TestView... //CM
    [scratch setLineCapStyle:self.lineCapStyle];
    [scratch setLineWidth:(lw<_aqtMinimumLinewidth)?_aqtMinimumLinewidth:lw];
    
    if (self.hasPattern) {
        NSUInteger patternCount = _pattern.count;
        CGFloat temppat[patternCount];
        int32_t i = 0;
        for (NSNumber *p in _pattern) {
            temppat[i++] = p.floatValue;
        }
        [scratch setLineDash:temppat count:patternCount phase:patternPhase];
    }
    if (self.filled) {
        [scratch closePath];
    }
    // FIXME: Add closed path handling from Public API and onwards...
    //        This looks like a closed path..., make it so.
    NSValue *v0 = _path[0];
    NSValue *vLast = _path.lastObject;
    if (NSEqualPoints(v0.pointValue,  vLast.pointValue)){
        [scratch closePath];
    }
    [self setCache:scratch];
}

-(NSRect)updateBounds
{
    if (!self.cache) {
        [self updateCache];
    }
    NSRect tmpBounds = NSInsetRect([self.cache bounds], -self.linewidth/2.0, -self.linewidth/2.0);
    [self  setBounds:tmpBounds];
    return tmpBounds;
}

-(void)renderInRect:(NSRect)dirtyRect
{    
    if (!NSIntersectsRect(dirtyRect, self.clippedBounds)) {
        return;
    }
    [self setAQTColor];
    if (self.clipped) {
        [NSGraphicsContext saveGraphicsState];
        NSRectClip(self.clippedBounds);
    }
    [self.cache stroke];
    if (self.filled) {
        [self.cache fill];
    }
    if (self.clipped) {
        [NSGraphicsContext restoreGraphicsState];
    }
#ifdef DEBUG_BOUNDS
    [self highlightBounds];
#endif
}
@end

@implementation AQTImage (AQTImageDrawing)
-(BOOL)fitBounds
{
    return YES;
}

-(void)updateCache
{
    // Install an NSImage in _cache
    unsigned char *theBytes = (unsigned char*) [self.bitmap bytes];
    NSImage *tmpImage = [[NSImage alloc] initWithSize:self.bitmapSize];
    NSBitmapImageRep *tmpBitmap =
    [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&(theBytes)
                                            pixelsWide:self.bitmapSize.width
                                            pixelsHigh:self.bitmapSize.height
                                         bitsPerSample:8
                                       samplesPerPixel:3
                                              hasAlpha:NO
                                              isPlanar:NO
                                        colorSpaceName:NSDeviceRGBColorSpace
                                           bytesPerRow:3*self.bitmapSize.width
                                          bitsPerPixel:24];
    [tmpImage addRepresentation:tmpBitmap];
    [self setCache:tmpImage];
}

-(NSRect)updateBounds
{
    NSAffineTransform *transf = [NSAffineTransform transform];
    NSRect tmpBounds = self.bounds;
    if (!self.fitBounds) {
        // Make a path from bounds rect, transform the path,
        // retrieve the new bounds from the path.
        NSRect bitmapBounds = NSMakeRect(0, 0, self.bitmapSize.width, self.bitmapSize.height);
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:bitmapBounds];
        tmpBounds = [[self.transform transformBezierPath:path] bounds];
        [self setBounds:tmpBounds];
    }
    return tmpBounds;
}

-(void)renderInRect:(NSRect)dirtyRect
{
    if (!NSIntersectsRect(dirtyRect, self.clippedBounds)) {
        return;
    }
    if (!self.cache) {
        [self updateCache];
    }
    
    [NSGraphicsContext saveGraphicsState];
    if (self.clipped) {
        NSRectClip(self.clippedBounds);
    }
    if (self.fitBounds) {
        [self.cache drawInRect:self.bounds
                      fromRect:NSMakeRect(0,0,[self.cache size].width,[self.cache size].height)
                     operation:NSCompositeSourceOver
                      fraction:1.0];
    } else {
        [self.transform concat];
        [self.cache drawAtPoint:NSMakePoint(0,0)
                       fromRect:NSMakeRect(0,0,[self.cache size].width,[self.cache size].height)
                      operation:NSCompositeSourceOver
                       fraction:1.0];
    }
    [NSGraphicsContext restoreGraphicsState];
#ifdef DEBUG_BOUNDS
    [self highlightBounds];
#endif
    
}
@end

