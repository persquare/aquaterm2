//
//  AQTServer.h
//  Aquaterm2
//
//  Created by Per Persson on 13-08-13.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQTConnecting.h"

@interface AQTServer : NSObject <AQTConnecting>

@property NSConnection *serviceVendor;

@end
