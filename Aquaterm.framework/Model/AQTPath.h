#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

/*" This balances the fixed size of the objects vs. the need for dynamic allocation of storage. "*/
#define STATIC_POINT_STORAGE 24

#define MAX_PATTERN_COUNT 8
// FIXME: Base actual number on tests

@interface AQTPath : AQTGraphic 
{
    NSPointArray path;
    NSPointArray dynamicPathStore;
    NSPoint staticPathStore[STATIC_POINT_STORAGE];
    int32_t pointCount;
    
    AQTColor *_fillColor;
    
    float pattern[MAX_PATTERN_COUNT];
    int32_t patternCount;
    float patternPhase;
}

@property float linewidth;
@property int32_t lineCapStyle;
@property (readonly, getter = isClosed) BOOL closed;

- (id)initWithPoints:(NSPointArray)points pointCount:(int32_t)pointCount;
- (BOOL)hasPattern;
- (void)setLinestylePattern:(const float *)newPattern count:(int32_t)newCount phase:(float)newPhase;
- (void)closePath;
- (void)setFillColor:(AQTColor *)color;
- (AQTColor *)fillColor;
- (BOOL)filled;
- (BOOL)stroked;
@end
