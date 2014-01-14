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

- (id)initWithFrame:(NSRect)frame model:(AQTModel *)model
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    [_model renderInRect:dirtyRect]; // expects aRect in canvas coords, _not_ view coords
}

@end
