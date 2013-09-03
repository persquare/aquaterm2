#import "AQTPath.h"


static NSString *AQTPathKey = @"AQTPathKey";
static NSString *AQTPatternKey = @"AQTPatternKey";
static NSString *AQTPatternCountKey = @"AQTPatternCountKey";
static NSString *AQTPatternPhaseKey = @"AQTPatternPhaseKey";
static NSString *AQTLinewidthKey = @"AQTLinewidthKey";
static NSString *AQTLineCapStyleKey = @"AQTLineCapStyleKey";
static NSString *AQTFilledKey = @"AQTFilledKey";

@implementation AQTPath

-(id)initWithPoints:(NSPointArray)points pointCount:(int32_t)pc;
{
  if ((self = [super init])) {
      _path = [NSMutableArray arrayWithCapacity:STATIC_POINT_STORAGE];
      for (int32_t i = 0; i < pc; i++) {
          _path[i] = [NSValue valueWithPoint:points[i]];
      }
  }
  return self;
}

-(id)init
{
  return [self initWithPoints:nil pointCount:0];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeBool:self.filled forKey:AQTFilledKey];
    [coder encodeInt32:self.lineCapStyle forKey:AQTLineCapStyleKey];
    [coder encodeFloat:self.linewidth forKey:AQTLinewidthKey];
    [coder encodeObject:_path forKey:AQTPathKey];
    
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
        _path = [coder decodeObjectForKey:AQTPathKey];
        
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
