#import "AQTPath.h"


static NSString *AQTPathKey = @"AQTPathKey";
static NSString *AQTPointCountKey = @"AQTPointCountKey";
static NSString *AQTPatternKey = @"AQTPatternKey";
static NSString *AQTPatternCountKey = @"AQTPatternCountKey";
static NSString *AQTPatternPhaseKey = @"AQTPatternPhaseKey";
static NSString *AQTLinewidthKey = @"AQTLinewidthKey";
static NSString *AQTLineCapStyleKey = @"AQTLineCapStyleKey";
static NSString *AQTFilledKey = @"AQTFilledKey";

@implementation AQTPath

-(int32_t)aqtSetupPathStoreForPointCount:(int32_t)pc
{
    // Use static store as default for up to STATIC_POINT_STORAGE points,
    // switch to heap for longer paths. Fallback to static store and truncate
    // path if malloc fails.
    if (pc > STATIC_POINT_STORAGE) {
        dynamicPathStore = malloc(pc * sizeof(NSPoint));
        if (!dynamicPathStore) {
            // Failed to allocate memory, fallback to static store and truncate
            NSLog(@"Error: Couldn't allocate memory, path clipped to %d points", STATIC_POINT_STORAGE);
            pc = STATIC_POINT_STORAGE;
        }
    }
    path = (dynamicPathStore)?dynamicPathStore:staticPathStore;

    return pc;
}

-(id)initWithPoints:(NSPointArray)points pointCount:(int32_t)pc;
{
  int32_t i;
  if ((self = [super init])) {
      pointCount = [self aqtSetupPathStoreForPointCount:pc];
      for (i = 0; i < pointCount; i++) {
          path[i] = points[i];
      }
  }
  return self;
}

-(id)init
{
  return [self initWithPoints:nil pointCount:0];
}

-(void)dealloc
{
  if (path == dynamicPathStore) {
     free(dynamicPathStore);
  }
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeBool:self.filled forKey:AQTFilledKey];
    [coder encodeInt32:self.lineCapStyle forKey:AQTLineCapStyleKey];
    [coder encodeFloat:self.linewidth forKey:AQTLinewidthKey];
    [coder encodeInt32:pointCount forKey:AQTPointCountKey];
    [coder encodeBytes:(uint8_t *)path length:pointCount*sizeof(NSPoint) forKey:AQTPathKey];
    [coder encodeInt32:patternCount forKey:AQTPatternCountKey];
    for(int i = 0; i < patternCount; i++) {
        [coder encodeFloat:pattern[i] forKey:[NSString stringWithFormat:@"%@%d", AQTPatternKey, i]];
    }
    [coder encodeFloat:patternPhase forKey:AQTPatternPhaseKey];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.filled = [coder decodeBoolForKey:AQTFilledKey];
        self.lineCapStyle = [coder decodeInt32ForKey:AQTLineCapStyleKey];
        self.linewidth = [coder decodeFloatForKey:AQTLinewidthKey];
        pointCount = [coder decodeInt32ForKey:AQTPointCountKey];
        [self aqtSetupPathStoreForPointCount:pointCount];
        NSUInteger rpc;
        const uint8_t *tmpBuffer = [coder decodeBytesForKey:AQTPathKey returnedLength:&rpc];
        memcpy(path, tmpBuffer, rpc);
        patternCount = [coder decodeInt32ForKey:AQTPatternCountKey];
        for(int i = 0; i < patternCount; i++) {
            pattern[i] = [coder decodeFloatForKey:[NSString stringWithFormat:@"%@%d", AQTPatternKey, i]];
        }
    }
    return self;
}

- (void)setLinestylePattern:(const float *)newPattern count:(int32_t)newCount phase:(float)newPhase 
{
    // Create a local copy of the pattern.
    if (newCount < 0) // Sanity check
        return;
    // constrain count to MAX_PATTERN_COUNT
    newCount = (newCount>MAX_PATTERN_COUNT)?MAX_PATTERN_COUNT:newCount;
    for (int32_t i=0; i<newCount; i++) {
        pattern[i] = newPattern[i];
    }
    patternCount = newCount;
    patternPhase = newPhase;
}

- (BOOL)hasPattern
{
   return (patternCount > 0) ;
}
@end
