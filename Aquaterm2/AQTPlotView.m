//
//  AQTView.m
//  Aquaterm2
//
//  Created by Per Persson on 13-08-14.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import "AQTPlotView.h"
#import "AQTPlotDocument.h"
#import "AQTModel.h"
#import "AQTGraphicDrawingMethods.h"

@implementation AQTPlotView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark ==== Event handling ====

- (BOOL)acceptsFirstResponder
{
    return !![[self.window.windowController document] eventDelegate];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    id <AQTEventHandling> handler = [[self.window.windowController document] eventDelegate];
    [handler processEvent:@"EVENT" sender:@"DUMMY_ID"];
}


#pragma mark ==== Drawing ====


-(BOOL)isOpaque
{
    return YES;
}

// #define DEBUG_BOUNDS 1
- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    AQTModel *model = [[[self.window windowController] document] model];
    NSRect viewBounds = [self bounds];
    NSSize canvasSize = [model canvasSize];
    NSRect dirtyCanvasRect;
    NSAffineTransform *transform = [NSAffineTransform transform];

    BOOL aa = YES; // [[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldAntialiasDrawing"];
    NSImageInterpolation ii = NSImageInterpolationNone; // [[NSUserDefaults standardUserDefaults] integerForKey:@"ImageInterpolationLevel"]
    [[NSGraphicsContext currentContext] setImageInterpolation:ii];
    [[NSGraphicsContext currentContext] setShouldAntialias:aa];

 #ifdef DEBUG_BOUNDS
    [[NSColor redColor] set];
    NSFrameRect(dirtyRect);
#endif
    NSRectClip(dirtyRect);

    // Dirty rect in view coords, clipping rect is set.
    // Need to i) set transform for subsequent operations
    // and ii) transform dirty rect to canvas coords.
    
    // (i) view transform
    [transform translateXBy:0.5 yBy:0.5]; // FIXME: should this go before scale or after?
    [transform scaleXBy:viewBounds.size.width/canvasSize.width
                    yBy:viewBounds.size.height/canvasSize.height];
    [transform concat];
    
    // (ii) dirty rect transform
    [transform invert];
    dirtyCanvasRect.origin = [transform transformPoint:dirtyRect.origin];
    dirtyCanvasRect.size = [transform transformSize:dirtyRect.size];
    
    [model renderInRect:dirtyCanvasRect]; // expects aRect in canvas coords, _not_ view coords
    
#ifdef DEBUG_BOUNDS
    NSLog(@"dirtyRect: %@", NSStringFromRect(dirtyRect));
    NSLog(@"dirtyCanvasRect: %@", NSStringFromRect(dirtyCanvasRect));
#endif

}

@end
