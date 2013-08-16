
#import <Foundation/Foundation.h>
#import "AQTGraphic.h"

@interface AQTLabel : AQTGraphic

@property NSAttributedString *string;
@property NSString *fontName;
@property float fontSize;
@property NSPoint position;
@property float angle;
@property int32_t justification;
@property float shearAngle;

- (id)initWithAttributedString:(NSAttributedString *)aString
                      position:(NSPoint)aPoint
                         angle:(float)textAngle
                    shearAngle:(float)shearAngle
                 justification:(int32_t)justify;

- (id)initWithString:(NSString *)aString
            position:(NSPoint)aPoint
               angle:(float)textAngle
          shearAngle:(float)shearAngle
       justification:(int32_t)justify;

@end
