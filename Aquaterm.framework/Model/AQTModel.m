#import "AQTModel.h"

static NSString *AQTModelObjectsKey = @"AQTModelObjectsKey";
static NSString *AQTTitleKey = @"AQTTitleKey";
static NSString *AQTCanvasSizeKey = @"AQTCanvasSizeKey";
static NSString *AQTDirtyRectKey = @"AQTDirtyRectKey";
static NSString *AQTDirtyKey = @"AQTDirtyKey";

@implementation AQTModel
/**"
 *** A class representing a collection of objects making up the plot.
 "**/

-(id)initWithCanvasSize:(NSSize)size
{
    self = [super init];
    if (self) {
        _modelObjects = [[NSMutableArray alloc] initWithCapacity:1024];
        _title = @"Untitled";
        _canvasSize = size;
        self.color = [[AQTColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self setBounds:NSZeroRect];
    }
    return self;
}

-(id)init
{
    [NSException raise:@"AQTIllegalInit"
                format:@"The designated initializer is -initWithCanvasSize:"];
    return nil;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_modelObjects forKey:AQTModelObjectsKey];
    [coder encodeObject:_title forKey:AQTTitleKey];
    [coder encodeSize:_canvasSize forKey:AQTCanvasSizeKey];
    [coder encodeRect:_dirtyRect forKey:AQTDirtyRectKey];
    [coder encodeBool:_dirty forKey:AQTDirtyKey];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _modelObjects = [coder decodeObjectForKey:AQTModelObjectsKey];
        _title = [coder decodeObjectForKey:AQTTitleKey];
        _canvasSize = [coder decodeSizeForKey:AQTCanvasSizeKey];
        _dirtyRect = [coder decodeRectForKey:AQTDirtyRectKey];
        _dirty = [coder decodeBoolForKey:AQTDirtyKey];
    }
    return self;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                 objects:(__unsafe_unretained id [])buffer
                                   count:(NSUInteger)len
{
    return [_modelObjects countByEnumeratingWithState:state
                                              objects:buffer
                                                count:len];
}

-(NSUInteger)count
{
    return _modelObjects.count;
}

/**"
 *** Add any subclass of AQTGraphic to the collection of objects.
 "**/

-(void)addObject:(AQTGraphic *)graphic
{
    [_modelObjects addObject:graphic];
    _didUpdateBounds = NO;
}

-(AQTGraphic *)lastObject
{
    return [_modelObjects lastObject];
}

-(void)removeObjectsInRect:(NSRect)removeBounds
{
    [self updateBounds];
    // Make test rect just a tiny bit bigger
    removeBounds = NSInsetRect(removeBounds, -1, -1);
    // First check if whole canvas is contained in rect,
    // if not test objects one by one.
    if (NSContainsRect(removeBounds, [self clippedBounds])) {
        [_modelObjects removeAllObjects];
        [self setBounds:NSZeroRect];
    } else {
        // Build a list of objects to remove
        NSMutableArray *objectsToRemove = [NSMutableArray array];
        for (AQTGraphic *graphic in self) {
            if (NSContainsRect(removeBounds, [graphic clippedBounds])) {
                [objectsToRemove addObject:graphic];
            }
        }
        if ([objectsToRemove count]) {
            [_modelObjects removeObjectsInArray:objectsToRemove];
            _didUpdateBounds = NO;
        }

    }
}

-(NSRect)updateBounds
{
    if (!_didUpdateBounds) {
        NSRect tmpBounds = NSZeroRect;
        for (AQTGraphic *graphic in self) {
            tmpBounds = NSUnionRect(tmpBounds, [graphic updateBounds]);
        }
        [self setBounds:tmpBounds];
        
        _didUpdateBounds = YES;
    }
    return self.bounds;
}

@end
