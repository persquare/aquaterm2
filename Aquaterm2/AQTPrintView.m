//
//  AQTPrintView.m
//  Aquaterm2
//
//  Created by Per Persson on 2014-01-13.
//  Copyright (c) 2014 Aquaterm. All rights reserved.
//

#import "AQTPrintView.h"
#import "AQTModel.h"
#import "AQTGraphicDrawingMethods.h"

@implementation AQTPrintView

+ (NSData *)dataOfType:(NSString *)dataType fromModel:(AQTModel *)model
{
    NSDictionary *bitmapTypes = @{@"public.png"         : @(NSPNGFileType),
                                  @"public.jpeg"        : @(NSJPEGFileType),
                                  @"public.jpeg-2000"   : @(NSJPEG2000FileType),
                                  @"public.tiff"        : @(NSTIFFFileType),
                                  @"com.compuserve.gif" : @(NSGIFFileType),
                                  @"com.microsoft.bmp"  : @(NSBMPFileType)};
    
    NSRect modelFrame = NSMakeRect(0, 0, model.canvasSize.width, model.canvasSize.height);
    AQTPrintView *view = [[AQTPrintView alloc] initWithFrame:modelFrame model:model];
    
    NSData *data = nil;
    
    if ([dataType isEqualToString:@"com.adobe.pdf"]) {
        data = [view dataWithPDFInsideRect:modelFrame];
    } else if ([dataType isEqualToString:@"com.adobe.encapsulated-postscript"]) {
        data = [view dataWithEPSInsideRect:modelFrame];
    } else {
        // Construct a bitmap
        // http://stackoverflow.com/questions/17507170/how-to-save-png-file-from-nsimage-retina-issues
        NSNumber *type = bitmapTypes[dataType];
        if (type) {
            NSBitmapImageFileType fileType = [type integerValue];

            data = [view dataWithPDFInsideRect:modelFrame];
            NSImage *image = [[NSImage alloc] initWithData:data];
            CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                                     context:nil
                                                       hints:nil];
            NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
            [newRep setSize:[image size]];   // if you want the same resolution
            data = [newRep representationUsingType:fileType properties:nil];
        }
    }

    return data;
}

+ (NSPrintOperation *)printOperationFromModel:(AQTModel *)model printInfo:(NSPrintInfo *)pi
{
    NSRect modelFrame = NSMakeRect(0, 0, model.canvasSize.width, model.canvasSize.height);
    AQTPrintView *view = [[AQTPrintView alloc] initWithFrame:modelFrame model:model];
    
    return [NSPrintOperation printOperationWithView:view  printInfo:pi];
}

- (id)initWithFrame:(NSRect)frame model:(AQTModel *)model
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    [_model renderInRect:dirtyRect]; // expects aRect in canvas coords, _not_ view coords
}

@end
