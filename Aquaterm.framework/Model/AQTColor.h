//
//  AQTColor.h
//  Aquaterm2
//
//  Created by Per Persson on 13-08-09.
//  Copyright (c) 2013 Aquaterm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AQTColor : NSObject <NSCoding>

@property float red;
@property float green;
@property float blue;
@property float alpha;
- (id)initWithRed:(float)r green:(float)g blue:(float)b alpha:(float)a;
- (id)initWithRed:(float)r green:(float)g blue:(float)b;

@end
