#import "AQTPath.h"


static NSString *AQTPathKey = @"AQTPathKey";
static NSString *AQTPatternKey = @"AQTPatternKey";
static NSString *AQTPatternPhaseKey = @"AQTPatternPhaseKey";
static NSString *AQTLinewidthKey = @"AQTLinewidthKey";
static NSString *AQTLineCapStyleKey = @"AQTLineCapStyleKey";
static NSString *AQTFilledKey = @"AQTFilledKey";

@implementation AQTPath

-(id)initWithPoints:(NSPointArray)points pointCount:(int32_t)pc;
{
  if ((self = [super init])) {
      _path = [NSMutableArray arrayWithCapacity:INITIAL_POINT_STORAGE];
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
    
    [coder encodeObject:_pattern forKey:AQTPatternKey];
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
        
        _pattern = [coder decodeObjectForKey:AQTPatternKey];
        patternPhase = [coder decodeFloatForKey:AQTPatternPhaseKey];
    }
    return self;
}
- (void)appendPoint:(NSPoint)point
{
    [_path addObject:[NSValue valueWithPoint:point]];
}

- (void)setLinestylePattern:(NSArray *)newPattern phase:(float)newPhase
{
    _pattern = newPattern;
    patternPhase = newPhase;
    
}

- (BOOL)hasPattern
{
   return (_pattern && _pattern.count > 0) ;
}
@end
