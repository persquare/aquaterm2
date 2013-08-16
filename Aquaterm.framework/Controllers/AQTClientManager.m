//
//  AQTClientManager.m
//  AquaTerm
//
//  Created by Per Persson on Wed Nov 19 2003.
//  Copyright (c) 2003-2012 The AquaTerm Team. All rights reserved.
//

#import "AQTClientManager.h"
// #import "AQTModel.h"
#import "AQTPlotBuilder.h"

// #import "AQTEventProtocol.h"
#import "AQTConnecting.h"

#define AQUATERM_BUNDLE_ID "com.github.aquaterm.Aquaterm2"

NSString *AQUATERM_LOGLEVEL = @"AQUATERM_LOGLEVEL";
NSString *AQUATERM_PATH = @"AQUATERM_PATH";


@implementation AQTClientManager
#pragma mark ==== Error handling ====
- (void)_aqtHandlerError:(NSException *)exception
{
    // FIXME: stuff @"42:Server error" in all event buffers/handlers ?
    NSLog(@"Handler error: %@\n%@", [exception name], [exception reason]);
    errorState = YES;
    printf("AquaTerm warning: Connection to display was lost,\n");
    printf("plot commands will be discarded until a new plot is started.\n");
}
/*
 - (void)clearErrorState
 {
 BOOL serverDidDie = NO;
 
 [self logMessage:@"Trying to recover from error." logLevel:3];
 
 NS_DURING
 [_server ping];
 NS_HANDLER
 [self logMessage:@"Server not responding." logLevel:1];
 serverDidDie = YES;
 NS_ENDHANDLER
 
 if (serverDidDie) {
 [self terminateConnection];
 } else {
 [self closePlot];
 }
 errorState = NO;
 }
 */

#pragma mark ==== Init routines ====
+ (AQTClientManager *)sharedManager
{
    static AQTClientManager *sharedManager = nil;
    if (sharedManager == nil) {
        sharedManager = [[self alloc] _init];
    }
    return sharedManager;
}

- (id)init
{
    [NSException raise:@"AQTInvalidInit" format:@"Calling -init on singleton is bad, use +sharedManager instead."];
    return nil;
}

- (id)_init
{
    if(self = [super init]) {
        // Looks good, now set up some internal info:
        _env = [[NSProcessInfo processInfo] environment];
    }
    return self;
}


#pragma mark ==== Server methods ====
- (BOOL)connectToServer
{
    return [self connectToServerWithName:@"aquatermServer"];
}

- (BOOL)connectToServerWithName:(NSString *)registeredName
{
    if (![self launchAquaterm]) {
        NSLog(@"Error: Can't find Aquaterm.");
        return FALSE;
    }
    _server = [NSConnection rootProxyForConnectionWithRegisteredName:registeredName host:nil];
    if (!_server) {
        return FALSE;
    }
    @try {
        [_server setProtocolForProxy:@protocol(AQTConnecting)];
        int32_t a,b,c;
        [_server getServerVersionMajor:&a minor:&b rev:&c];
        _connected = [self checkServerVersionMajor:a minor:b];
    }
    @catch (NSException *exception) {
        NSLog(@"Server exception: %@", exception);
    }
    
    return _connected;
}

- (BOOL)checkServerVersionMajor:(int32_t)major minor:(int32_t)minor
{
    if (major < 2 ) {
        NSLog(@"Aquaterm2 required");
        [self terminateConnection];
        return FALSE;
    }
    return TRUE;
}

// Convenience method to launch Aquaterm application based on bundle ID,
// *unless* the environment variable AQUATERM_PATH is set in which case it takes
// preceedence over bundle ID.
-(BOOL)launchAquaterm
{
    if (_env[AQUATERM_PATH]) {
        return [self launchAquatermFromPath:_env[AQUATERM_PATH]];
    }
    CFStringRef aquatermBundleID = CFSTR(AQUATERM_BUNDLE_ID);
    FSRef appFileRef;
    OSStatus status = LSFindApplicationForInfo('AqT2', aquatermBundleID, NULL, &appFileRef, NULL);
    if (status == noErr) {
        return [self launchAquatermFromFSRef:appFileRef];
    }
    return FALSE;
}

// Convenience method to launch Aquaterm application from a specific path.
- (BOOL)launchAquatermFromPath:(NSString *)path
{
    FSRef appFileRef;
    CFURLGetFSRef((__bridge CFURLRef)[NSURL fileURLWithPath:path], &appFileRef);
    return [self launchAquatermFromFSRef:appFileRef];
}

// Launch Aquaterm application *synchronously*
- (BOOL)launchAquatermFromFSRef:(FSRef)app
{
    LSApplicationParameters appParams = {
        0,    /* CFIndex version; */
        kLSLaunchDontSwitch, /* LSLaunchFlags flags; */
        &app, /* const FSRef * application; */
        NULL, /* void * asyncLaunchRefCon; */
        NULL, /* CFDictionaryRef environment; */
        NULL, /* CFArrayRef argv; */
        NULL  /* AppleEvent * initialEvent */
    };
    OSStatus status = LSOpenApplication(&appParams, NULL);
    
    return (status == noErr);
}

- (void)terminateConnection
{
    //  NSEnumerator *enumObjects = [_plots keyEnumerator];
    /*
     id key;
     
     while (key = [enumObjects nextObject]) {
     [self setActivePlotKey:key];
     [self closePlot];
     }
     */
    if([_server isProxy]) {
        // [_server release];
        _server = nil;
    }
    [self logMessage:@"Terminating connection." logLevel:1];
}

#pragma mark ==== Accessors ====
/*
 - (void)setActivePlotKey:(id)newActivePlotKey
 {
 [newActivePlotKey retain];
 [_activePlotKey release];
 _activePlotKey = newActivePlotKey;
 [self logMessage:_activePlotKey?[NSString stringWithFormat:@"Active plot: %d", [_activePlotKey integerValue]]:@"**** plot invalid ****"
 logLevel:3];
 }
 
 - (void)setErrorHandler:(void (*)(NSString *errMsg))fPtr
 {
 _errorHandler = fPtr;
 }
 
 - (void)setEventHandler:(void (*)(int32_t index, NSString *event))fPtr
 {
 _eventHandler = fPtr;
 }
 */
- (void)logMessage:(NSString *)msg logLevel:(int32_t)level
{
    // _logLimit: 0 -- output off
    //            1 -- severe errors
    //            2 -- user debug
    //            3 -- noisy, dev. debug
    //if (level > 0 && level <= _logLimit) {
    NSLog(@"\nlibaquaterm::%@", msg);
    //}
}

#pragma mark === Plot/builder methods ===

- (AQTPlotBuilder *)newPlotWithIndex:(int32_t)refNum
{
    AQTPlotBuilder *builder = nil;
    NSNumber *key = @(refNum);
    id <AQTRendering> newPlot;

    // FIXME: Verify server presence
    
    
    // Check if plot already exists. If so, just select and clear it.
    builder = [self selectPlotWithIndex:refNum];
    if (builder) {
        [builder reset];
        return builder;
    }
    
    @try {
        newPlot = [_server addAQTClient:key
                                   name:[[NSProcessInfo processInfo] processName]
                                    pid:[[NSProcessInfo processInfo] processIdentifier]];
    }
    @catch (NSException *exception) {
        [self _aqtHandlerError:exception];
        newPlot = nil;
    }

    if (newPlot) {
        builder = [[AQTPlotBuilder alloc] initWithPlot:newPlot];
        self.builders[key] = builder;
        self.activeBuilder = builder;
    }
    return builder;
}

- (AQTPlotBuilder *)selectPlotWithIndex:(int32_t)refNum
{    
    if (errorState == YES) return nil; // FIXME: Clear error state here too???
    
    NSNumber *key = @(refNum);
    AQTPlotBuilder *aBuilder = self.builders[key];
    
    if(aBuilder) {
        self.activeBuilder = aBuilder;
    }
    return aBuilder;
}
/*
- (void)renderPlot
{
    AQTPlotBuilder *pb;
    
    if (errorState == YES || _activePlotKey == nil) return;
    
    pb = [_builders objectForKey:_activePlotKey];
    if ([pb modelIsDirty]) {
        id <NSObject, AQTClientProtocol> thePlot = [_plots objectForKey:_activePlotKey];
        NS_DURING
        if ([thePlot isProxy]) {
            [thePlot appendModel:[pb model]];
            [pb removeAllParts];
        } else {
            [thePlot setModel:[pb model]];
        }
        [thePlot draw];
        NS_HANDLER
        // [localException raise];
        [self _aqtHandlerError:[localException name]];
        NS_ENDHANDLER
    }
}

- (AQTPlotBuilder *)clearPlot
{
    AQTPlotBuilder *newBuilder, *oldBuilder;
    id <NSObject, AQTClientProtocol> thePlot;
    
    if (errorState == YES || _activePlotKey == nil) return nil;
    
    newBuilder = [[AQTPlotBuilder alloc] init];
    oldBuilder = [_builders objectForKey:_activePlotKey];
    thePlot = [_plots objectForKey:_activePlotKey];
    
    [newBuilder setSize:[[oldBuilder model] canvasSize]];
    [newBuilder setTitle:[[oldBuilder model] title]];
    [newBuilder setBackgroundColor:[oldBuilder backgroundColor]];
    
    [_builders setObject:newBuilder forKey:_activePlotKey];
    NS_DURING
    [thePlot setModel:[newBuilder model]];
    [thePlot draw];
    NS_HANDLER
    // [localException raise];
    [self _aqtHandlerError:[localException name]];
    NS_ENDHANDLER
    [newBuilder release];
    return newBuilder;
}

- (void)clearPlotRect:(NSRect)aRect
{
    AQTPlotBuilder *pb;
    AQTRect aqtRect;
    id <NSObject, AQTClientProtocol> thePlot;
    
    if (errorState == YES || _activePlotKey == nil) return;
    
    pb = [_builders objectForKey:_activePlotKey];
    thePlot = [_plots objectForKey:_activePlotKey];
    
    NS_DURING
    if ([pb modelIsDirty]) {
        if ([thePlot isProxy]) {
            [thePlot appendModel:[pb model]]; // Push any pending output to the viewer, don't draw
            [pb removeAllParts];
        } else {
            [thePlot setModel:[pb model]];
        }
        
    }
    // FIXME make sure in server that this combo doesn't draw unnecessarily
    // 64 bit compatibility
    aqtRect.origin.x = aRect.origin.x;
    aqtRect.origin.y = aRect.origin.y;
    aqtRect.size.width = aRect.size.width;
    aqtRect.size.height = aRect.size.height;
    [thePlot removeGraphicsInRect:aqtRect];
    // [thePlot draw];
    NS_HANDLER
    // [localException raise];
    [self _aqtHandlerError:[localException name]];
    NS_ENDHANDLER
}

- (void)closePlot
{
    if (_activePlotKey == nil) return;
    
    NS_DURING
    [[_plots objectForKey:_activePlotKey] setClient:nil];
    [[_plots objectForKey:_activePlotKey] close];
    NS_HANDLER
    [self logMessage:@"Closing plot, discarding exception..." logLevel:2];
    NS_ENDHANDLER
    [_plots removeObjectForKey:_activePlotKey];
    [_builders removeObjectForKey:_activePlotKey];
    [self setActivePlotKey:nil];
}

#pragma mark ==== Events ====

- (void)setAcceptingEvents:(BOOL)flag
{
    if (errorState == YES || _activePlotKey == nil) return;
    NS_DURING
    [[_plots objectForKey:_activePlotKey] setAcceptingEvents:flag];
    NS_HANDLER
    [self _aqtHandlerError:[localException name]];
    NS_ENDHANDLER
}

- (NSString *)lastEvent
{
    NSString *event;
    
    if (errorState == YES) return @"42:Server error";
    if (_activePlotKey == nil) return @"43:No plot selected";
    
    event = [[[_eventBuffer objectForKey:_activePlotKey] copy] autorelease];
    [_eventBuffer setObject:@"0" forKey:_activePlotKey];
    return event;
}

#pragma mark ==== AQTEventProtocol ====
- (void)ping
{
    return;
}

- (void)processEvent:(NSString *)event sender:(id)sender
{
    NSNumber *key;
    
    NSArray *keys = [_plots allKeysForObject:sender];
    if ([keys count] == 0) return;
    key = [keys objectAtIndex:0];
    
    if (_eventHandler != nil) {
        _eventHandler([key integerValue], event);
    }
    [_eventBuffer setObject:event forKey:key];
}

#pragma mark ==== Testing methods ====
- (void)timingTestWithTag:(uint32_t)tag
{
    AQTPlotBuilder *pb;
    
    if (errorState == YES || _activePlotKey == nil) return;
    
    pb = [_builders objectForKey:_activePlotKey];
    if ([pb modelIsDirty]) {
        id <NSObject, AQTClientProtocol> thePlot = [_plots objectForKey:_activePlotKey];
        NS_DURING
        if ([thePlot isProxy]) {
            [thePlot appendModel:[pb model]];
            [pb removeAllParts];
        } else {
            [thePlot setModel:[pb model]];
        }
        [thePlot timingTestWithTag:tag];
        NS_HANDLER
        // [localException raise];
        [self _aqtHandlerError:[localException name]];
        NS_ENDHANDLER
    }
}
*/
@end
