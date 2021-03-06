//
//  AQTPlotBuilder.m
//  AquaTerm
//
//  Created by Per Persson on Sat Aug 16 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import <stdint.h>
#import "AQTPlotState.h"
#import "AQTModel.h"
#import "AQTColorMap.h"
#import "AQTColor.h"

extern const int32_t AQTRoundLineCapStyle;

@implementation AQTPlotState

- (id)initWithPlot:(id <AQTRendering>)plot
{
    self = [super init];
    if (self) {
        _plot = plot;
        // FIXME: Default plot size + preferences, NOT NSZeroSize!
        [self reset];
    }
    return self;
}

- (void)renderPlot
{
    @try {
        [_plot setModel:_model];
    }
    @catch (NSException *exception) {
        NSLog(@"Error: %@", exception);
    }
}

- (void)setDefaultValues
{
    self.current_color = [[AQTColor alloc] initWithRed:0 green:0 blue:0];
    self.fontName = @"Times-Roman"; // FIXME
    self.fontSize = 14.0f;
    self.linewidth = 1.0f;
    self.patternPhase = 0.0f;
    self.pattern = nil;
    self.capStyle = AQTRoundLineCapStyle;
    self.imageTransform = [NSAffineTransform transform];
    self.clipRect = NSZeroRect;
    self.colormap = [[AQTColorMap alloc] init];
}

- (void)reset
{
    _model = [[AQTModel alloc] initWithCanvasSize:NSZeroSize];
    [self setDefaultValues];
}
@end
