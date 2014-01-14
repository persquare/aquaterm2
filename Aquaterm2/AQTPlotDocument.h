//
//  AQTDocument.h
//  Aquaterm2
//
//  Created by Per Persson on 13-08-09.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AQTRendering.h"
#import "AQTModel.h"
@interface AQTPlotDocument : NSDocument <AQTRendering>
{
    AQTModel *_model;
}
@property id clientID;
@property NSString *name;
@property int32_t pid;
- (AQTModel *)model;
- (IBAction)export:(id)sender;
@end
