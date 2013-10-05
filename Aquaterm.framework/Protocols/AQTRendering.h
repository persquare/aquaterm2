//
//  AQTRendering.h
//  Aquaterm2
//
//  Created by Per Persson on 13-08-13.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTEventHandling.h"
@class AQTModel;

@protocol AQTRendering <NSObject>
- (void)setModel:(bycopy AQTModel *)aModel; // (id)?
- (void)setEventDelegate:(id <AQTEventHandling>)delegate;
@end
