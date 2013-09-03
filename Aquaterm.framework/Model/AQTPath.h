#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

/*" This balances the fixed size of the objects vs. the need for dynamic allocation of storage. "*/
#define STATIC_POINT_STORAGE 24

#define MAX_PATTERN_COUNT 8
// FIXME: Base actual number on tests

@interface AQTPath : AQTGraphic 
{
    NSMutableArray *_path;
    
    float pattern[MAX_PATTERN_COUNT];
    int32_t patternCount;
    float patternPhase;
}

@property float linewidth;
@property int32_t lineCapStyle;
@property BOOL filled;

- (id)initWithPoints:(NSPointArray)points pointCount:(int32_t)pointCount;
- (BOOL)hasPattern;
- (void)setLinestylePattern:(const float *)newPattern count:(int32_t)newCount phase:(float)newPhase;
@end
