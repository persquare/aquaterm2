//
//  AQTServer.m
//  Aquaterm2
//
//  Created by Per Persson on 13-08-13.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import "AQTServer.h"
#import "AQTPlotDocument.h"

@implementation AQTServer

-(void)awakeFromNib
{
    NSPort *vPort= [NSPort port];
    _serviceVendor = [NSConnection connectionWithReceivePort:vPort sendPort:vPort];
    [_serviceVendor setRootObject:self];
    if ([_serviceVendor registerName:@"aquatermServer"]) {
        return;
    }
    // Handle error condition
    NSInteger retCode = NSRunCriticalAlertPanel(@"Could not establish service",
                                                @"Another application has already registered the service \"aquatermServer\".\nYou may leave AquaTerm running by pressing Cancel, but no clients will be able to use it.\nPress Quit to close this copy of AquaTerm.",
                                                @"Quit", @"Cancel", nil);
    if (retCode == NSAlertDefaultReturn) {
        [NSApp terminate:self];
    }
}

#pragma mark ==== AQTConnecting protocol methods ====

- (oneway void)ping
{
    return;
}

- (void)getServerVersionMajor:(out int32_t *)major minor:(out int32_t *)minor rev:(out int32_t *)rev
{
    *major = 2;
    *minor = 0;
    *rev = 0;
}

- (id <AQTRendering>)addAQTClient:(bycopy id)clientID name:(bycopy NSString *)name pid:(int32_t)procId
{
    AQTPlotDocument *plot = [[AQTPlotDocument alloc] init];
    [[NSDocumentController sharedDocumentController] addDocument:plot];
    [plot makeWindowControllers];
    plot.clientID = clientID;
    plot.name = name;
    plot.pid = procId;
    NSLog(@"Client added: tag=%@, name=%@, pid=%d", clientID, name, procId);
    return plot;
}


@end
