//
//  AQTConnecting.h
//  Aquaterm2
//
//  Created by Per Persson on 13-08-13.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AQTRendering;

@protocol AQTConnecting <NSObject>
- (oneway void)ping;
- (void)getServerVersionMajor:(out int32_t *)major minor:(out int32_t *)minor rev:(out int32_t *)rev;
// FIXME: Specify protocol for return value, make client parameter a string (key).
- (id <AQTRendering>)addAQTClient:(bycopy id)client name:(bycopy NSString *)name pid:(int32_t)procId;
@end
