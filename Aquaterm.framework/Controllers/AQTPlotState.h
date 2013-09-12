//
//  AQTPlotBuilder.h
//  AquaTerm
//
//  Created by Per Persson on Sat Aug 16 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import <Foundation/Foundation.h>
// #import "AQTGraphic.h"
// #import "AQTImage.h"
// #import "AQTPath.h"
#import "AQTRendering.h"

// FIXME: These DEFINES are bogus
// This is the default colormap size
#define AQT_COLORMAP_SIZE 256

// This is the maximum practically useable path length due to the way Quartz renders a path
// FIXME: establish some "optimal" value
#define MAX_POLYLINE_POINTS 64
#define MAX_POLYGON_POINTS 256
#define MAX_PATTERN_COUNT 8

@class AQTModel, AQTColor, AQTColorMap;

@interface AQTPlotState : NSObject

@property id <AQTRendering> plot;
@property AQTModel *model;	/*" The graph currently being built "*/
@property AQTColorMap *colormap;
@property AQTColor *current_color;
@property NSString *fontName;	/*" Currently selected font "*/
@property float fontSize;	/*" Currently selected fontsize [pt]"*/
@property float linewidth;
@property float patternPhase;
@property NSMutableArray *pattern;
@property int32_t capStyle;
@property NSAffineTransform *imageTransform;
@property NSRect clipRect;


- (id)initWithPlot:(id <AQTRendering>)plot; // FIXME: Rename -initWithRenderer:
- (void)renderPlot;
- (void)reset;
@end
