//
//  AQTRendering.h
//  Aquaterm2
//
//  Created by Per Persson on 13-08-13.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AQTModel;

@protocol AQTRendering <NSObject>
//- (void)setClient:(byref id)aClient;
- (void)setModel:(bycopy AQTModel *)aModel; // (id)?
//- (void)appendModel:(bycopy id)aModel;
//- (void)draw;
//- (void)removeGraphicsInRect:(AQTRect)aRect; // FIXME: Replace by an AQTErase object?
//- (void)setAcceptingEvents:(BOOL)flag;
//- (void)close;
@end
