//
//  AQTGraphicDrawingMethods.h
//  AquaTerm
//
//  Created by Per Persson on Mon Oct 20 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AQTGraphic.h"
#import "AQTModel.h"


@interface AQTGraphic (AQTGraphicDrawingMethods)
- (NSRect)updateBounds;
- (NSRect)clippedBounds;
- (void)renderInRect:(NSRect)dirtyRect; // In canvas coords, not view coords
@end

