

#import "AQTImage.h"

#import <Foundation/NSAffineTransform.h>

@interface NSAffineTransform (PortCoding)
- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder;
@end

@implementation NSAffineTransform (PortCoding)
- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
    if ([encoder isBycopy]) return self;
    return [super replacementObjectForPortCoder:encoder];
}
@end

static NSString *AQTBitmapKey = @"AQTBitmapKey";
static NSString *AQTBitmapSizeKey = @"AQTBitmapSizeKey";
static NSString *AQTTransformKey = @"AQTTransformKey";

@implementation AQTImage

@synthesize bitmap = _bitmap;
@synthesize transform;

- (id)initWithBitmap:(const char *)bytes size:(NSSize)size
{
  if (self = [super init])
  {
      self.bitmapSize = size;
      self.transform = [NSAffineTransform transform];
      // Implies RGB data
      _bitmap = [[NSData alloc] initWithBytes:bytes length:3*size.width*size.height];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_bitmap forKey:AQTBitmapKey];
    [coder encodeSize:self.bitmapSize forKey:AQTBitmapSizeKey];
    [coder encodeObject:self.transform forKey:AQTTransformKey];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _bitmap = [coder decodeObjectForKey:AQTBitmapKey];
        self.bitmapSize = [coder decodeSizeForKey:AQTBitmapSizeKey];
        self.transform = [coder decodeObjectForKey:AQTTransformKey];
    }
    return self;
}

@end
