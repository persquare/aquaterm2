//
//  AQTPrintView.h
//  Aquaterm2
//
//  Created by Per Persson on 2014-01-13.
//  Copyright (c) 2014 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTPlotDocument.h"


@interface AQTPrintView : NSView
@property AQTPlotDocument *doc;
- (id)initWithFrame:(NSRect)frame document:(AQTPlotDocument *)doc;
@end
