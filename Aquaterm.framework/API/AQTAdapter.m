//
//  AQTAdapter.m
//  AquaTerm
//
//  Created by Per Persson on Sat Jul 12 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import "AQTAdapter.h"
#import "AQTClientManager.h"
#import "AQTPlotBuilder.h"
#import "AQTModel.h"
#import "AQTColorMap.h"
#import "AQTLabel.h"

@implementation AQTAdapter
/*" AQTAdapter is a class that provides an interface to the functionality of AquaTerm.
 As such, it bridges the gap between client's procedural calls requesting operations
 such as drawing a line or placing a label and the object-oriented graph being built.
 The actual assembling of the graph is performed by an instance of class AQTPlotBuilder.
 
 It seemlessly provides a connection to the viewer (AquaTerm.app) without any work on behalf of the client.
 
 It also provides some utility functionality such an indexed colormap, and an optional
 error handling callback function for the client.
 
 Event handling of user input is provided through an optional callback function.
 
 #Example: HelloAquaTerm.c
 !{
 #import <Foundation/Foundation.h>
 #import <AquaTerm/AQTAdapter.h>
 
 int main(void)
 {
 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
 AQTAdapter *adapter = [[AQTAdapter alloc] init];
 [adapter openPlotWithIndex:1];
 [adapter setPlotSize:NSMakeSize(600,400)];
 [adapter addLabel:@"HelloAquaTerm!" atPoint:NSMakePoint(300, 200) angle:0.0 align:1];
 [adapter renderPlot];
 [adapter release];
 [pool release];
 return 0;
 }
 }
 !{gcc -ObjC main.c -o aqtex -lobjc -framework AquaTerm -framework Foundation}
 !{gcc main.m -o aqtex -framework AquaTerm -framework Foundation}
 "*/

/*" This is the designated initalizer, allowing for the default handler (an object vended by AquaTerm via OS X's distributed objects mechanism) to be replaced by a local instance. In most cases #init should be used, which calls #initWithHandler: with a nil argument."*/
-(id)initWithServer:(id)localServer
{
    if(self = [super init]) {
        _clientManager = [AQTClientManager sharedManager];
        BOOL serverIsOK = [_clientManager connectToServer];
        if (!serverIsOK) {
            return nil;
        }
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectionDidDie:)
                                                     name:NSConnectionDidDieNotification
                                                   object:nil];
         */
    }
    return self;
}

/*" Initializes an instance and sets up a connection to the handler object via DO. Launches AquaTerm if necessary. "*/
- (id)init
{
    return [self initWithServer:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_clientManager terminateConnection];
}

/*" Optionally set an error handling routine of the form #customErrorHandler(NSString *errMsg) to override default behaviour. "*/
/*
- (void)setErrorHandler:(void (*)(NSString *errMsg))fPtr
{
    [_clientManager setErrorHandler:fPtr];
}
*/
/*" Optionally set an event handling routine of the form #customEventHandler(int index, NSString *event).
 The reference number of the plot that generated the event is passed in index and
 the structure of the string event is @"type:data1:data2:..."
 Currently supported events are:
 _{event description}
 _{0 NoEvent }
 _{1:%{x,y}:%button MouseDownEvent }
 _{2:%{x,y}:%key KeyDownEvent }
 _{42:%{x,y}:%key ServerError }
 _{43:%{x,y}:%key Error } "*/
/*
- (void)setEventHandler:(void (*)(int32_t index, NSString *event))fPtr
{
    [_clientManager setEventHandler:fPtr];
}
*/
- (void)connectionDidDie:(id)x
{
    // NSLog(@"in --> %@ %s line %d", NSStringFromSelector(_cmd), __FILE__, __LINE__);
    // Make sure we can't access any invalid objects:
    _selectedBuilder = nil;
}

#pragma mark === Control operations ===

/* Creates a new builder instance, adds it to the list of builders and makes it the selected builder. If the referenced builder exists, it is selected and cleared. */
/*" Open up a new plot with internal reference number refNum and make it the target for subsequent commands. If the referenced plot already exists, it is selected and cleared. Disables event handling for previously targeted plot. "*/
- (void)openPlotWithIndex:(int32_t)refNum
{
    _selectedBuilder = [_clientManager newPlotWithIndex:refNum];
}

/*" Get the plot referenced by refNum and make it the target for subsequent commands. If no plot exists for refNum, the currently targeted plot remain unchanged. Disables event handling for previously targeted plot. Returns YES on success. "*/
- (BOOL)selectPlotWithIndex:(int32_t)refNum
{
    BOOL didChangePlot = NO;
    AQTPlotBuilder *tmpBuilder = [_clientManager selectPlotWithIndex:refNum];
    if (tmpBuilder != nil)
    {
        _selectedBuilder = tmpBuilder;
        didChangePlot = YES;
    }
    return didChangePlot;
}

/*" Set the limits of the plot area. Must be set %before any drawing command following an #openPlotWithIndex: or #clearPlot command or behaviour is undefined.  "*/
- (void)setPlotSize:(NSSize)canvasSize
{
    [_selectedBuilder.model setCanvasSize:canvasSize];
}

/*" Set title to appear in window titlebar, also default name when saving. "*/
- (void)setPlotTitle:(NSString *)title
{
    [_selectedBuilder.model setTitle:title?title:@"Untitled"];
}

/*" Render the current plot in the viewer. "*/
- (void)renderPlot
{
    if(_selectedBuilder) {
        [_selectedBuilder renderPlot];
    } else {
        // Just inform user about what is going on...
        NSLog(@"renderPlot called with no plot selected");
    }
}

/*" Clears the current plot and resets default values. To keep plot settings, use #eraseRect: instead. "*/
- (void)clearPlot
{
    // _selectedBuilder = [_clientManager clearPlot];
}

/*" Closes the current plot but leaves viewer window on screen. Disables event handling. "*/
- (void)closePlot
{
 //   [_clientManager closePlot];
    _selectedBuilder = nil;
}

#pragma mark === Event handling ===

/*" Inform AquaTerm whether or not events should be passed from the currently selected plot. Deactivates event passing from any plot previously set to pass events. "*/
/*
- (void)setAcceptingEvents:(BOOL)flag
{
    [_clientManager setAcceptingEvents:flag];
}
*/
/*" Reads the last event logged by the viewer. Will always return NoEvent unless #setAcceptingEvents: is called with a YES argument."*/
/*
- (NSString *)lastEvent
{
    [[NSRunLoop currentRunLoop] runMode:NSConnectionReplyMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    return [_clientManager lastEvent];
}

- (NSString *)waitNextEvent // FIXME: timeout? Hardcoded to 10s
{
    NSString *event;
    BOOL isRunning;
    [self setAcceptingEvents:YES];
    do {
        isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];
        event = [_clientManager lastEvent];
        isRunning = [event isEqualToString:@"0"]?YES:NO;
    } while (isRunning);
    [self setAcceptingEvents:NO];
    return event;
}
*/
#pragma mark === Plotting commands ===

/*" Set a clipping region (rectangular) to apply to all subsequent operations, until changed again by #setClipRect: or #setDefaultClipRect. "*/
- (void)setClipRect:(NSRect)clip
{
    [_selectedBuilder setClipRect:clip];
}

/*" Restore clipping region to the deafult (object bounds), i.e. no clipping performed. "*/
- (void)setDefaultClipRect
{
    _selectedBuilder.clipRect = NSZeroRect;
}

/*" Return the number of color entries available in the currently active colormap. "*/
- (int32_t)colormapSize
{
    return (_selectedBuilder)?_selectedBuilder.colormap.size:AQT_COLORMAP_SIZE;
}

/*" Set an RGB entry in the colormap, at the position given by entryIndex. "*/
- (void)setColormapEntry:(int32_t)entryIndex red:(float)r green:(float)g blue:(float)b alpha:(float)a
{
    AQTColor *tmpColor = [[AQTColor alloc] initWithRed:r green:g blue:b alpha:a];
    [_selectedBuilder.colormap setColor:tmpColor forIndex:entryIndex];
    // FIXME: _selectedBuilder.colormap[entryIndex] = tmpColor;
}

- (void)setColormapEntry:(int32_t)entryIndex red:(float)r green:(float)g blue:(float)b
{
    [self setColormapEntry:entryIndex red:r green:g blue:b alpha:1.0];
}


/*" Set an RGB entry in the colormap, at the position given by entryIndex. "*/
- (void)getColormapEntry:(int32_t)entryIndex red:(float *)r green:(float *)g blue:(float *)b alpha:(float *)a
{
    AQTColor *tmpColor = [_selectedBuilder.colormap colorForIndex:entryIndex];
    // FIXME: AQTColor *tmpColor = _selectedBuilder.colormap[entryIndex]
    *r = tmpColor.red;
    *g = tmpColor.green;
    *b = tmpColor.blue;
    *a = tmpColor.alpha;
}

- (void)getColormapEntry:(int32_t)entryIndex red:(float *)r green:(float *)g blue:(float *)b
{
    float dummyAlpha;
    [self getColormapEntry:entryIndex red:r green:g blue:b alpha:&dummyAlpha];
}


/*" Set the current color, used for all subsequent items, using the color stored at the position given by index in the colormap. "*/
- (void)takeColorFromColormapEntry:(int32_t)index
{
    _selectedBuilder.current_color = [_selectedBuilder.colormap colorForIndex:index];
}

/*" Set the background color, overriding any previous color, using the color stored at the position given by index in the colormap. "*/
- (void)takeBackgroundColorFromColormapEntry:(int32_t)index
{
    [_selectedBuilder.model setColor:[_selectedBuilder.colormap colorForIndex:index]];
}

/*" Set the current color, used for all subsequent items, using explicit RGB components. "*/
- (void)setColorRed:(float)r green:(float)g blue:(float)b alpha:(float)a
{
    _selectedBuilder.current_color = [[AQTColor alloc] initWithRed:r green:g blue:b alpha:a];
}

- (void)setColorRed:(float)r green:(float)g blue:(float)b
{
    [self setColorRed:r green:g blue:b alpha:1.0];
}

/*" Set the background color, overriding any previous color, using explicit RGB components. "*/
- (void)setBackgroundColorRed:(float)r green:(float)g blue:(float)b alpha:(float)a
{
    [_selectedBuilder.model setColor:[[AQTColor alloc] initWithRed:r green:g blue:b alpha:a]];
}

- (void)setBackgroundColorRed:(float)r green:(float)g blue:(float)b
{
    [self setBackgroundColorRed:r green:g blue:b alpha:1.0];
}


/*" Get current RGB color components by reference. "*/
- (void)getColorRed:(float *)r green:(float *)g blue:(float *)b alpha:(float *)a
{
    AQTColor *tmpColor = _selectedBuilder.current_color;
    *r = tmpColor.red;
    *g = tmpColor.green;
    *b = tmpColor.blue;
    *a = tmpColor.alpha;
}


- (void)getColorRed:(float *)r green:(float *)g blue:(float *)b
{
    AQTColor *tmpColor = _selectedBuilder.current_color;
    *r = tmpColor.red;
    *g = tmpColor.green;
    *b = tmpColor.blue;
}

/*" Get background color components by reference. "*/
- (void)getBackgroundColorRed:(float *)r green:(float *)g blue:(float *)b alpha:(float *)a
{
    AQTColor *tmpColor = _selectedBuilder.model.color;
    *r = tmpColor.red;
    *g = tmpColor.green;
    *b = tmpColor.blue;
    *a = tmpColor.alpha;
}


- (void)getBackgroundColorRed:(float *)r green:(float *)g blue:(float *)b
{
    float dummyAlpha;
    [self getBackgroundColorRed:r green:g blue:b alpha:&dummyAlpha];
}


/*" Set the font to be used. Applies to all future operations. Default is Times-Roman."*/
- (void)setFontname:(NSString *)name
{
    _selectedBuilder.fontName = name;
}

/*" Set the font size in points. Applies to all future operations. Default is 14pt. "*/
- (void)setFontsize:(float)fontsize
{
    _selectedBuilder.fontSize = fontsize;
}

/*" Add text at coordinate given by pos, rotated by angle degrees and aligned vertically and horisontally (with respect to pos and rotation) according to align. Horizontal and vertical align may be combined by an OR operation, e.g. (AQTAlignCenter | AQTAlignMiddle).
 _{HorizontalAlign Description}
 _{AQTAlignLeft LeftAligned}
 _{AQTAlignCenter Centered}
 _{AQTAlignRight RightAligned}
 _{VerticalAlign -}
 _{AQTAlignMiddle ApproxCenter}
 _{AQTAlignBaseline Normal}
 _{AQTAlignBottom BottomBoundsOfTHISString}
 _{AQTAlignTop TopBoundsOfTHISString}
 By specifying #shearAngle the text may be sheared in order to appear correctly in e.g. 3D plot labels.
 The text can be either an NSString or an NSAttributedString. By using NSAttributedString a subset of the attributes defined in AppKit may be used to format the string beyond the fontface ans size. The currently supported attributes are
 _{Attribute value}
 _{@"NSSuperScript" raise-level}
 _{@"NSUnderline" 0or1}
 "*/
- (void)addLabel:(id)text atPoint:(NSPoint)pos angle:(float)angle shearAngle:(float)shearAngle align:(int32_t)just
{
    // [_selectedBuilder addLabel:text position:pos angle:angle shearAngle:shearAngle justification:just];
    AQTLabel *label = nil;
    if ([text isKindOfClass:[NSString class]]) {
        label = [[AQTLabel alloc] initWithString:text
                                     position:pos
                                        angle:angle
                                   shearAngle:shearAngle
                                justification:just];
    } else if ([text isKindOfClass:[NSAttributedString class]]) {
        label = [[AQTLabel alloc] initWithAttributedString:text
                                               position:pos
                                                  angle:angle
                                             shearAngle:shearAngle
                                          justification:just];
    }
    
    if (label) {
        label.clipped = !NSEqualRects(_selectedBuilder.clipRect, NSZeroRect);
        label.clipRect = _selectedBuilder.clipRect;
        label.color = _selectedBuilder.current_color;
        label.fontName = _selectedBuilder.fontName;
        label.fontSize = _selectedBuilder.fontSize;
        [_selectedBuilder.model addObject:label];
    }
}

/*" Same as #addLabel:atPoint:angle:shearAngle:align: except that shearAngle defaults to 0."*/
- (void)addLabel:(id)text atPoint:(NSPoint)pos angle:(float)angle align:(int32_t)just
{
    [self addLabel:text atPoint:pos angle:angle shearAngle:0.0 align:just];
}

/*" Convenience form of #addLabel:atPoint:angle:shearAngle:align: for horizontal, left and baseline aligned text."*/
- (void)addLabel:(id)text atPoint:(NSPoint)pos
{
    [self addLabel:text atPoint:pos angle:0.0 shearAngle:0.0 align:(AQTAlignLeft | AQTAlignBaseline)];
}



/*" Set the current linewidth (in points), used for all subsequent lines. Any line currently being built by #moveToPoint:/#addLineToPoint will be considered finished since any coalesced sequence of line segments must share the same linewidth.  Default linewidth is 1pt."*/
- (void)setLinewidth:(float)newLinewidth
{
    _selectedBuilder.linewidth = newLinewidth;
}

/*" Set the current line style to pattern style, used for all subsequent lines. The linestyle is specified as a pattern, an array of at most 8 float, where even positions correspond to dash-lengths and odd positions correspond to gap-lengths. To produce e.g. a dash-dotted line, use the pattern {4.0, 2.0, 1.0, 2.0}."*/
- (void)setLinestylePattern:(float *)newPattern count:(int32_t)newCount phase:(float)newPhase
{
    if (newCount <= 0) {
        [self setLinestyleSolid];
        return;
    }
    
    _selectedBuilder.pattern = [NSMutableArray arrayWithCapacity:INITIAL_PATTERN_STORAGE];
    for (int32_t i = 0; i < newCount; i++) {
        _selectedBuilder.pattern[i] = @(newPattern[i]);
    }
    _selectedBuilder.patternPhase = newPhase;
}

/*" Set the current line style to solid, used for all subsequent lines. This is the default."*/
- (void)setLinestyleSolid
{
    _selectedBuilder.pattern = nil;
}

/*" Set the current line cap style (in points), used for all subsequent lines. Any line currently being built by #moveToPoint:/#addLineToPoint will be considered finished since any coalesced sequence of line segments must share the same cap style.
 _{capStyle Description}
 _{AQTButtLineCapStyle ButtLineCapStyle}
 _{AQTRoundLineCapStyle RoundLineCapStyle}
 _{AQTSquareLineCapStyle SquareLineCapStyle}
 Default is RoundLineCapStyle. "*/
- (void)setLineCapStyle:(int32_t)capStyle
{
    _selectedBuilder.capStyle = capStyle;
}

/*" Moves the current point (in canvas coordinates) in preparation for a new sequence of line segments. "*/
- (void)moveToPoint:(NSPoint)point
{
    // [_selectedBuilder moveToPoint:point];
    [self addPolylineWithPoints:&point pointCount:1];
}

/*" Add a line segment from the current point (given by a previous #moveToPoint: or #addLineToPoint). "*/
- (void)addLineToPoint:(NSPoint)point
{
    id obj = [_selectedBuilder.model lastObject];
    if ([obj isKindOfClass:[AQTPath class]]) {
        [(AQTPath *)obj appendPoint:point];
    }
}

/*" Add a sequence of line segments specified by a list of start-, end-, and joinpoint(s) in points. Parameter pc is number of line segments + 1."*/
- (void)addPolylineWithPoints:(NSPoint *)points pointCount:(int32_t)pc
{
    if (pc < 0) {
        return;
    }
    AQTPath *tmpPath = [[AQTPath alloc] initWithPoints:points pointCount:pc];
    // Copy current properties to path
    tmpPath.clipRect = _selectedBuilder.clipRect;
    tmpPath.clipped = !NSEqualRects(_selectedBuilder.clipRect, NSZeroRect);
    tmpPath.color = _selectedBuilder.current_color;
    tmpPath.linewidth = _selectedBuilder.linewidth;
    tmpPath.lineCapStyle = _selectedBuilder.capStyle;
    if (_selectedBuilder.pattern) {
        [tmpPath setLinestylePattern:[_selectedBuilder.pattern copy]
                               phase:_selectedBuilder.patternPhase];
    }
    [_selectedBuilder.model addObject:tmpPath];

}

- (void)moveToVertexPoint:(NSPoint)point
{
    [self addPolygonWithVertexPoints:&point pointCount:1];
}

- (void)addEdgeToVertexPoint:(NSPoint)point
{
    [self addLineToPoint:point];
}

/*" Add a polygon specified by a list of corner points. Number of corners is passed in pc."*/
- (void)addPolygonWithVertexPoints:(NSPoint *)points pointCount:(int32_t)pc
{
    if (pc < 0) {
        return;
    }
    AQTPath *tmpPath = [[AQTPath alloc] initWithPoints:points pointCount:pc];
    // Copy current properties to path
    tmpPath.clipRect = _selectedBuilder.clipRect;
    tmpPath.clipped = !NSEqualRects(_selectedBuilder.clipRect, NSZeroRect);
    tmpPath.color = _selectedBuilder.current_color;
    tmpPath.linewidth = _selectedBuilder.linewidth;
    tmpPath.lineCapStyle = _selectedBuilder.capStyle;
    tmpPath.filled = YES;
    [_selectedBuilder.model addObject:tmpPath];
}

/*" Add a filled rectangle. Will attempt to remove any objects that will be covered by aRect."*/
- (void)addFilledRect:(NSRect)aRect
{
    NSPoint pointList[4]={
        NSMakePoint(NSMinX(aRect), NSMinY(aRect)),
        NSMakePoint(NSMaxX(aRect), NSMinY(aRect)),
        NSMakePoint(NSMaxX(aRect), NSMaxY(aRect)),
        NSMakePoint(NSMinX(aRect), NSMaxY(aRect))};
    // [self eraseRect:aRect];
    [self addPolygonWithVertexPoints:pointList pointCount:4];
}

/*" Remove any objects %completely inside aRect. Does %not force a redraw of the plot."*/
- (void)eraseRect:(NSRect)aRect
{
    // FIXME: Possibly keep a list of rects to be erased and pass them before any append command??
    // [_clientManager clearPlotRect:aRect];
}

/*" Set a transformation matrix for images added by #addTransformedImageWithBitmap:size:clipRect:, see NSImage documentation for details. "*/
- (void)setImageTransformM11:(float)m11 m12:(float)m12 m21:(float)m21 m22:(float)m22 tX:(float)tX tY:(float)tY
{
    NSAffineTransformStruct ts;
    ts.m11 = m11;
    ts.m12 = m12;
    ts.m21 = m21;
    ts.m22 = m22;
    ts.tX = tX;
    ts.tY = tY;
    NSAffineTransform *trans = [NSAffineTransform transform];
    [trans setTransformStruct:ts];
    [_selectedBuilder setImageTransform:trans];
}

/*" Set transformation matrix to unity, i.e. no transform. "*/
- (void)resetImageTransform
{
    [_selectedBuilder setImageTransform:[NSAffineTransform transform]];
}

/*" Add a bitmap image of size bitmapSize scaled to fit destBounds, does %not apply transform. Bitmap format is 24bits per pixel in sequence RGBRGB... with 8 bits per color."*/
- (void)addImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize bounds:(NSRect)destBounds
{
    // [_clientManager clearPlotRect:destBounds];
    [_selectedBuilder addImageWithBitmap:bitmap size:bitmapSize bounds:destBounds];
}

/*" Deprecated, use #addTransformedImageWithBitmap:size: instead. Add a bitmap image of size bitmapSize %honoring transform, transformed image is clipped to destBounds. Bitmap format is 24bits per pixel in sequence RGBRGB...  with 8 bits per color."*/
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize clipRect:(NSRect)destBounds
{
    [_selectedBuilder addTransformedImageWithBitmap:bitmap size:bitmapSize clipRect:destBounds];
}

/*" Add a bitmap image of size bitmapSize %honoring transform, transformed image is clipped to current clipRect. Bitmap format is 24bits per pixel in sequence RGBRGB...  with 8 bits per color."*/
- (void)addTransformedImageWithBitmap:(const void *)bitmap size:(NSSize)bitmapSize
{
    [_selectedBuilder addTransformedImageWithBitmap:bitmap size:bitmapSize];
}

/*******************************************
 * Private methods                         *
 *******************************************/
/*
- (void)timingTestWithTag:(uint32_t)tag
{
    [_clientManager timingTestWithTag:tag];
}
 */
@end

