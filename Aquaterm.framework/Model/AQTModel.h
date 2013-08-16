#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

@interface AQTModel : AQTGraphic <NSFastEnumeration>
{
   NSMutableArray *_modelObjects;
}

@property NSSize canvasSize;
@property NSString *title;
@property (readonly) NSRect dirtyRect;
@property (readonly) BOOL dirty;

-(id)initWithCanvasSize:(NSSize)canvasSize;

-(int32_t)count;
-(void)addObject:(AQTGraphic *)graphic;
-(void)addObjectsFromArray:(NSArray *)graphics;
-(NSArray *)modelObjects;
-(void)removeAllObjects;
-(void)removeObjectAtIndex:(uint32_t)i;

@end
