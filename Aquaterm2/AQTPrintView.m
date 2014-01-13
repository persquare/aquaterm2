//
//  AQTPrintView.m
//  Aquaterm2
//
//  Created by Per Persson on 2014-01-13.
//  Copyright (c) 2014 Aquaterm. All rights reserved.
//

#import "AQTPrintView.h"
#import "AQTModel.h"
#import "AQTGraphicDrawingMethods.h"

@implementation AQTPrintView

- (id)initWithFrame:(NSRect)frame document:(AQTPlotDocument *)doc
{
    self = [super initWithFrame:frame];
    if (self) {
        _doc = doc;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    NSLog(@"%@#%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    AQTModel *model = [_doc model];
    NSRect viewBounds = [self bounds];
    NSSize canvasSize = [model canvasSize];
    NSRect dirtyCanvasRect;
    NSAffineTransform *transform = [NSAffineTransform transform];
    
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
}

@end
