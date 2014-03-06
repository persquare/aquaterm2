//
//  AQTImage.h
//  AquaTerm
//
//  Created by Per Persson on Tue Feb 05 2002.
//  Copyright (c) 2001-2012 The AquaTerm Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AQTGraphic.h"


@interface AQTImage : AQTGraphic

  @property (readonly) NSData *bitmap;
  @property NSSize bitmapSize;
  @property NSAffineTransform *transform;

- (id)initWithBitmap:(const char *)bytes
                size:(NSSize)size;

@end
