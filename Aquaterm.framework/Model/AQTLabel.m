
#import "AQTLabel.h"

#define DEFAULT_FONTFACE @"Times-Roman"
#define DEFAULT_FONTSIZE 14.0

@implementation AQTLabel

static NSString *AQTStringKey = @"AQTStringKey";
static NSString *AQTFontNameKey = @"AQTFontNameKey";
static NSString *AQTFontSizeKey = @"AQTFontSizeKey";
static NSString *AQTPositionKey = @"AQTPositionKey";
static NSString *AQTAngleKey = @"AQTAngleKey";
static NSString *AQTShearAngleKey = @"AQTShearAngleKey";
static NSString *AQTJustificationKey = @"AQTJustificationKey";

-(id)initWithAttributedString:(NSAttributedString *)aString
                     position:(NSPoint)aPoint
                        angle:(float)textAngle
                   shearAngle:(float)beta
                justification:(int32_t)justify
{
    self =[super init];
    if (self) {
        self.string = [aString copy];
        self.fontName = DEFAULT_FONTFACE;
        self.fontSize = DEFAULT_FONTSIZE;
        self.position= aPoint;
        self.angle = textAngle;
        self.shearAngle = beta;
        self.justification = justify;
  }
  return self;
}

-(id)initWithString:(NSString *)aString
           position:(NSPoint)aPoint
              angle:(float)textAngle
         shearAngle:(float)beta
      justification:(int32_t)justify
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:aString];
    return [self initWithAttributedString:str
                                 position:aPoint
                                    angle:textAngle
                               shearAngle:beta
                            justification:justify];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.string forKey:AQTStringKey];
    [coder encodeObject:self.fontName forKey:AQTFontNameKey];
    [coder encodeFloat:self.fontSize forKey:AQTFontSizeKey];
    [coder encodePoint:self.position forKey:AQTPositionKey];
    [coder encodeFloat:self.angle forKey:AQTAngleKey];
    [coder encodeFloat:self.shearAngle forKey:AQTShearAngleKey];
    [coder encodeInt32:self.justification forKey:AQTJustificationKey];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.string = [coder decodeObjectForKey:AQTStringKey];
        self.fontName = [coder decodeObjectForKey:AQTFontNameKey];
        self.fontSize = [coder decodeFloatForKey:AQTFontSizeKey];
        self.position = [coder decodePointForKey:AQTPositionKey];
        self.angle = [coder decodeFloatForKey:AQTAngleKey];
        self.justification = [coder decodeInt32ForKey:AQTJustificationKey];
        self.shearAngle = [coder decodeFloatForKey:AQTShearAngleKey];
    }
    return self;
}
@end
