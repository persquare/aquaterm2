#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

/*" This balances the fixed size of the objects vs. the need for dynamic allocation of storage. "*/
#define INITIAL_POINT_STORAGE 24

#define INITIAL_PATTERN_STORAGE 8

@interface AQTPath : AQTGraphic 
{
    NSMutableArray *_path;
    NSMutableArray *_pattern;
    float patternPhase;
}

@property float linewidth;
@property int32_t lineCapStyle;
@property BOOL filled;

- (id)initWithPoints:(NSPointArray)points pointCount:(int32_t)pointCount;
- (BOOL)hasPattern;
- (void)setLinestylePattern:(const float *)newPattern count:(int32_t)newCount phase:(float)newPhase;
@end
