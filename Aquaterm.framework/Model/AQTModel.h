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

-(NSUInteger)count;
-(void)addObject:(AQTGraphic *)graphic;
-(AQTGraphic *)lastObject;
@end
